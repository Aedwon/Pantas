// Open asset metadata stamping, PNG tEXt chunk parsing, and manifest validation.

export const DEFAULT_FOUNDER_COPYRIGHT = `© ${new Date().getFullYear()} Pantas. All rights reserved.`;

export const APPROVED_SOURCE_FAMILIES = [
  { name: 'OpenStax / Rice', match: (url) => /^https:\/\/([a-z0-9-]+\.)*(openstax\.org|cnx\.org|rice\.edu)(\/|$)/i.test(url) },
  { name: 'USGS', match: (url) => /^https:\/\/([a-z0-9-]+\.)*usgs\.gov(\/|$)/i.test(url) },
  { name: 'NASA / JPL', match: (url) => /^https:\/\/([a-z0-9-]+\.)*(nasa\.gov|jpl\.nasa\.gov)(\/|$)/i.test(url) },
  { name: 'NOAA', match: (url) => /^https:\/\/([a-z0-9-]+\.)*noaa\.gov(\/|$)/i.test(url) },
  { name: 'Wikimedia Commons', match: (url) => /^https:\/\/([a-z0-9-]+\.)*(wikimedia\.org|wikipedia\.org)(\/|$)/i.test(url) },
];

export const APPROVED_LICENSES = new Set([
  'Public Domain',
  'Public domain',
  'CC0',
  'CC0 1.0',
  'CC0 1.0 Universal',
  'CC BY 2.0',
  'CC BY 2.5',
  'CC BY 3.0',
  'CC BY 4.0',
  'CC BY-SA 2.0',
  'CC BY-SA 2.5',
  'CC BY-SA 3.0',
  'CC BY-SA 4.0',
  'US Government Public Domain',
  'NASA Public Domain',
  'USGS Public Domain',
  'NOAA Public Domain',
]);

export function isApprovedSourceUrl(url) {
  if (typeof url !== 'string' || !url.startsWith('https://')) return false;
  return APPROVED_SOURCE_FAMILIES.some((family) => family.match(url));
}

export function isApprovedLicense(license) {
  if (typeof license !== 'string') return false;
  if (APPROVED_LICENSES.has(license.trim())) return true;
  // Also check standard patterns like CC BY x.x or CC BY-SA x.x or Public Domain
  const normalized = license.trim();
  if (/^CC\s+BY(\s*-\s*SA)?\s+[1-4]\.[0-9]$/i.test(normalized)) return true;
  if (/^Public Domain/i.test(normalized)) return true;
  if (/^CC0(\s+1\.0)?/i.test(normalized)) return true;
  return false;
}

export function crc32(buf) {
  let crc = 0xffffffff;
  for (const byte of buf) {
    crc ^= byte;
    for (let k = 0; k < 8; k++) crc = crc & 1 ? 0xedb88320 ^ (crc >>> 1) : crc >>> 1;
  }
  return (crc ^ 0xffffffff) >>> 0;
}

const PNG_SIGNATURE = Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);

/**
 * Reads all tEXt chunks from a PNG buffer.
 * @param {Buffer} png
 * @returns {Record<string, string>}
 */
export function readPngTextChunks(png) {
  if (!Buffer.isBuffer(png) || png.length < 8 || !png.subarray(0, 8).equals(PNG_SIGNATURE)) {
    throw new Error('Not a valid PNG buffer');
  }
  const chunks = {};
  let offset = 8;
  while (offset + 8 <= png.length) {
    const length = png.readUInt32BE(offset);
    const type = png.toString('latin1', offset + 4, offset + 8);
    const dataStart = offset + 8;
    const dataEnd = dataStart + length;
    if (dataEnd + 4 > png.length) break;

    if (type === 'tEXt') {
      const data = png.subarray(dataStart, dataEnd);
      const nullIdx = data.indexOf(0x00);
      if (nullIdx !== -1) {
        const keyword = data.toString('latin1', 0, nullIdx);
        const text = data.toString('latin1', nullIdx + 1);
        chunks[keyword] = text;
      }
    } else if (type === 'IEND') {
      break;
    }
    offset = dataEnd + 4; // skip data + crc
  }
  return chunks;
}

/**
 * Stamps tEXt metadata chunks into a PNG buffer right after the IHDR chunk.
 * @param {Buffer} png
 * @param {Record<string, string>} metadata
 * @param {{ isFounder?: boolean }} options
 * @returns {Buffer}
 */
export function stampPngMetadata(png, metadata, options = {}) {
  if (!Buffer.isBuffer(png) || png.length < 33 || !png.subarray(0, 8).equals(PNG_SIGNATURE)) {
    throw new Error('Not a valid PNG buffer');
  }

  // Safety check: Open assets must NEVER carry Pantas copyright
  if (!options.isFounder) {
    if (metadata.Copyright && /Pantas/i.test(metadata.Copyright)) {
      throw new Error('Pantas copyright is not allowed on open assets.');
    }
  }

  const ihdrLength = png.readUInt32BE(8);
  const insertAt = 8 + 4 + 4 + ihdrLength + 4; // signature + IHDR (len, type, data, crc)

  const chunkBuffers = [];
  for (const [key, value] of Object.entries(metadata)) {
    if (value === undefined || value === null) continue;
    const data = Buffer.from(`${key}\0${value}`, 'latin1');
    const typeAndData = Buffer.concat([Buffer.from('tEXt', 'latin1'), data]);
    const lengthBytes = Buffer.alloc(4);
    lengthBytes.writeUInt32BE(data.length);
    const crcBytes = Buffer.alloc(4);
    crcBytes.writeUInt32BE(crc32(typeAndData));
    chunkBuffers.push(lengthBytes, typeAndData, crcBytes);
  }

  if (chunkBuffers.length === 0) return png;

  return Buffer.concat([
    png.subarray(0, insertAt),
    ...chunkBuffers,
    png.subarray(insertAt),
  ]);
}

/**
 * Validates an open asset manifest object.
 * Returns an array of error messages (empty if valid).
 * @param {any} manifest
 * @returns {string[]}
 */
export function validateOpenAssetManifest(manifest) {
  const errors = [];
  if (!manifest || typeof manifest !== 'object') {
    return ['Manifest must be an object.'];
  }
  if (manifest.version !== 1) {
    errors.push(`Manifest version must be 1, got ${manifest.version}`);
  }
  if (!Array.isArray(manifest.assets) || manifest.assets.length === 0) {
    errors.push('Manifest must contain a non-empty assets array.');
    return errors;
  }

  const seenKeys = new Set();
  const seenTargets = new Set();

  for (let i = 0; i < manifest.assets.length; i++) {
    const item = manifest.assets[i];
    const prefix = `Asset[${i}] (${item.key || 'no key'}):`;

    if (!item.key || typeof item.key !== 'string') {
      errors.push(`${prefix} missing key`);
    } else {
      if (seenKeys.has(item.key)) {
        errors.push(`${prefix} Duplicate key "${item.key}"`);
      }
      seenKeys.add(item.key);
      if (!/^[a-z0-9-]+(\/[a-z0-9-]+)*#[0-9]+$/.test(item.key)) {
        errors.push(`${prefix} invalid key format "${item.key}"`);
      }
    }

    if (!item.target || typeof item.target !== 'string') {
      errors.push(`${prefix} missing target`);
    } else {
      if (seenTargets.has(item.target)) {
        errors.push(`${prefix} Duplicate target "${item.target}"`);
      }
      seenTargets.add(item.target);
      if (!item.target.startsWith('content/illustrations/') || !item.target.endsWith('.png')) {
        errors.push(`${prefix} target must be under content/illustrations/*.png`);
      }
    }

    if (!item.sourcePage || typeof item.sourcePage !== 'string') {
      errors.push(`${prefix} missing sourcePage`);
    } else {
      if (!item.sourcePage.startsWith('https://')) {
        errors.push(`${prefix} sourcePage must be HTTPS URL`);
      }
      if (!isApprovedSourceUrl(item.sourcePage)) {
        errors.push(`${prefix} sourcePage domain is not in approved families (OpenStax/Rice, USGS, NASA/JPL, NOAA, Wikimedia Commons): ${item.sourcePage}`);
      }
    }

    if (!item.directUrl || typeof item.directUrl !== 'string') {
      errors.push(`${prefix} missing directUrl`);
    } else {
      if (!item.directUrl.startsWith('https://')) {
        errors.push(`${prefix} directUrl must be HTTPS URL`);
      }
      if (!isApprovedSourceUrl(item.directUrl)) {
        errors.push(`${prefix} directUrl domain is not in approved families: ${item.directUrl}`);
      }
    }

    if (!item.license || typeof item.license !== 'string') {
      errors.push(`${prefix} missing license`);
    } else if (!isApprovedLicense(item.license)) {
      errors.push(`${prefix} unapproved license "${item.license}" - must allow commercial modification and redistribution`);
    }

    if (!item.creator || typeof item.creator !== 'string' || item.creator.trim().length === 0) {
      errors.push(`${prefix} missing creator`);
    }

    if (!item.credit || typeof item.credit !== 'string' || item.credit.trim().length === 0) {
      errors.push(`${prefix} missing credit`);
    }

    if (!item.sha256 || typeof item.sha256 !== 'string') {
      errors.push(`${prefix} missing sha256`);
    } else if (!/^[a-f0-9]{64}$/.test(item.sha256)) {
      errors.push(`${prefix} sha256 must be 64-character lowercase hex, got "${item.sha256}"`);
    }
  }

  return errors;
}
