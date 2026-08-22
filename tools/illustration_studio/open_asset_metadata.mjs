// Open asset metadata stamping, PNG chunk parsing, and manifest validation.
import { posix } from 'node:path';
import zlib from 'node:zlib';

export const DEFAULT_FOUNDER_COPYRIGHT = `© ${new Date().getFullYear()} Pantas. All rights reserved.`;

export const APPROVED_SOURCE_FAMILIES = [
  { name: 'OpenStax / Rice', match: (url) => /^https:\/\/([a-z0-9-]+\.)*(openstax\.org|cnx\.org|rice\.edu)(\/|$)/i.test(url) },
  { name: 'USGS', match: (url) => /^https:\/\/([a-z0-9-]+\.)*usgs\.gov(\/|$)/i.test(url) },
  { name: 'NASA / JPL', match: (url) => /^https:\/\/([a-z0-9-]+\.)*(nasa\.gov|jpl\.nasa\.gov)(\/|$)/i.test(url) },
  { name: 'NOAA', match: (url) => /^https:\/\/([a-z0-9-]+\.)*noaa\.gov(\/|$)/i.test(url) },
  {
    name: 'Wikimedia Commons',
    match: (url) => {
      if (typeof url !== 'string' || !url.startsWith('https://')) return false;
      if (/^https:\/\/upload\.wikimedia\.org\//i.test(url)) {
        return /^https:\/\/upload\.wikimedia\.org\/wikipedia\/commons(\/|$)/i.test(url);
      }
      if (/wikipedia\.org/i.test(url)) return false;
      return /^https:\/\/commons\.wikimedia\.org(\/|$)/i.test(url);
    },
  },
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
  const normalized = license.trim();
  if (/^CC\s+BY(\s*-\s*SA)?\s+[1-4]\.[0-9]$/i.test(normalized)) return true;
  if (/^Public Domain/i.test(normalized)) return true;
  if (/^CC0(\s+1\.0)?/i.test(normalized)) return true;
  return false;
}

/**
 * Parses strategy.tsv and returns a Set of target_file paths designated as 'founder'.
 * Throws if required columns 'target_file' or 'strategy' are missing from the header.
 * @param {string} rawTsv
 * @returns {Set<string>}
 */
export function parseFounderTargets(rawTsv) {
  if (typeof rawTsv !== 'string') {
    throw new Error('strategy.tsv content must be a string.');
  }
  const lines = rawTsv.trim().split('\n');
  const header = lines.shift().split('\t');
  const targetIdx = header.indexOf('target_file');
  const stratIdx = header.indexOf('strategy');
  if (targetIdx === -1 || stratIdx === -1) {
    throw new Error(`Invalid strategy.tsv: missing required columns (target_file=${targetIdx}, strategy=${stratIdx}).`);
  }
  const founderTargets = new Set();
  for (const line of lines) {
    const cols = line.split('\t');
    if (cols[stratIdx] === 'founder' && cols[targetIdx]) {
      founderTargets.add(cols[targetIdx]);
    }
  }
  return founderTargets;
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
 * Low-level parser that verifies PNG signature, chunk boundaries, ordering, and CRCs.
 * @param {Buffer} png
 * @returns {Array<{ type: string, data: Buffer, offset: number, length: number }>}
 */
export function readPngChunks(png) {
  if (!Buffer.isBuffer(png) || png.length < 8 || !png.subarray(0, 8).equals(PNG_SIGNATURE)) {
    throw new Error('Not a valid PNG buffer: missing or invalid PNG signature.');
  }

  let offset = 8;
  let seenIhdr = false;
  let seenIend = false;
  const chunks = [];

  while (offset < png.length) {
    if (seenIend) {
      throw new Error('Invalid PNG ordering: data found after IEND chunk.');
    }
    if (offset + 8 > png.length) {
      throw new Error('Truncated PNG: incomplete chunk header.');
    }

    const length = png.readUInt32BE(offset);
    const type = png.toString('latin1', offset + 4, offset + 8);
    const dataStart = offset + 8;
    const dataEnd = dataStart + length;

    if (dataEnd + 4 > png.length) {
      throw new Error(`Truncated PNG: chunk ${type} data or CRC truncated.`);
    }

    if (!seenIhdr) {
      if (type !== 'IHDR') {
        throw new Error(`Invalid PNG ordering: first chunk must be IHDR, got ${type}.`);
      }
      seenIhdr = true;
    }

    const expectedCrc = png.readUInt32BE(dataEnd);
    const actualCrc = crc32(png.subarray(offset + 4, dataEnd));
    if (expectedCrc !== actualCrc) {
      throw new Error(`Bad CRC for chunk ${type}: expected ${expectedCrc.toString(16)}, got ${actualCrc.toString(16)}.`);
    }

    const chunkData = png.subarray(dataStart, dataEnd);
    chunks.push({ type, data: chunkData, offset, length });

    if (type === 'IEND') {
      seenIend = true;
    }

    offset = dataEnd + 4;
  }

  if (!seenIend) {
    throw new Error('Invalid PNG: missing IEND chunk.');
  }

  return chunks;
}

/**
 * Reads all textual metadata (tEXt, iTXt, zTXt) from a PNG buffer.
 * tEXt and zTXt decode as ISO-8859-1 (latin1); iTXt decodes as UTF-8.
 * @param {Buffer} png
 * @returns {Record<string, string>}
 */
export function readPngTextChunks(png) {
  const chunks = readPngChunks(png);
  const result = {};

  for (const chunk of chunks) {
    if (chunk.type === 'tEXt') {
      const nullIdx = chunk.data.indexOf(0x00);
      if (nullIdx === -1) {
        throw new Error('Malformed tEXt chunk: missing null separator.');
      }
      if (nullIdx < 1 || nullIdx > 79) {
        throw new Error('Malformed tEXt chunk: invalid keyword length.');
      }
      const keyword = chunk.data.toString('latin1', 0, nullIdx);
      const text = chunk.data.toString('latin1', nullIdx + 1);
      result[keyword] = text;
    } else if (chunk.type === 'zTXt') {
      const nullIdx = chunk.data.indexOf(0x00);
      if (nullIdx === -1) {
        throw new Error('Malformed zTXt chunk: missing null separator.');
      }
      if (nullIdx < 1 || nullIdx > 79) {
        throw new Error('Malformed zTXt chunk: invalid keyword length.');
      }
      if (chunk.data.length < nullIdx + 2) {
        throw new Error('Malformed zTXt chunk: truncated compression method.');
      }
      const compressionMethod = chunk.data[nullIdx + 1];
      if (compressionMethod !== 0) {
        throw new Error(`Malformed zTXt chunk: unsupported compression method ${compressionMethod}.`);
      }
      const compressedData = chunk.data.subarray(nullIdx + 2);
      const decompressed = zlib.inflateSync(compressedData);
      const keyword = chunk.data.toString('latin1', 0, nullIdx);
      result[keyword] = decompressed.toString('latin1');
    } else if (chunk.type === 'iTXt') {
      const nullIdx1 = chunk.data.indexOf(0x00);
      if (nullIdx1 === -1) {
        throw new Error('Malformed iTXt chunk: missing null separator after keyword.');
      }
      if (nullIdx1 < 1 || nullIdx1 > 79) {
        throw new Error('Malformed iTXt chunk: invalid keyword length.');
      }
      if (chunk.data.length < nullIdx1 + 3) {
        throw new Error('Malformed iTXt chunk: truncated header.');
      }
      const compressionFlag = chunk.data[nullIdx1 + 1];
      if (compressionFlag !== 0 && compressionFlag !== 1) {
        throw new Error(`Malformed iTXt chunk: invalid compression flag ${compressionFlag}.`);
      }
      const compressionMethod = chunk.data[nullIdx1 + 2];
      if (compressionMethod !== 0) {
        throw new Error(`Malformed iTXt chunk: invalid compression method ${compressionMethod}.`);
      }
      const nullIdx2 = chunk.data.indexOf(0x00, nullIdx1 + 3);
      if (nullIdx2 === -1) {
        throw new Error('Malformed iTXt chunk: missing null separator after language tag.');
      }
      const nullIdx3 = chunk.data.indexOf(0x00, nullIdx2 + 1);
      if (nullIdx3 === -1) {
        throw new Error('Malformed iTXt chunk: missing null separator after translated keyword.');
      }
      const textData = chunk.data.subarray(nullIdx3 + 1);
      const keyword = chunk.data.toString('latin1', 0, nullIdx1);
      if (compressionFlag === 0) {
        result[keyword] = textData.toString('utf8');
      } else {
        result[keyword] = zlib.inflateSync(textData).toString('utf8');
      }
    }
  }

  return result;
}

/**
 * Stamps textual metadata chunks into a PNG buffer right after the IHDR chunk.
 * Preserves Unicode without corruption using iTXt chunks.
 * @param {Buffer} png
 * @param {Record<string, string>} metadata
 * @param {{ isFounder?: boolean }} options
 * @returns {Buffer}
 */
export function stampPngMetadata(png, metadata, options = {}) {
  // Validate PNG structure first
  readPngChunks(png);

  // Check existing metadata in the input PNG
  const existingMetadata = readPngTextChunks(png);

  if (options.isFounder) {
    // Founder mode must require exactly one field, Copyright, equal byte-for-byte to DEFAULT_FOUNDER_COPYRIGHT
    const keys = Object.keys(metadata);
    if (keys.length === 0) {
      throw new Error('Founder mode requires metadata with exactly one Copyright field.');
    }
    if (keys.length !== 1 || !('Copyright' in metadata)) {
      throw new Error('Founder mode only allows the Copyright field.');
    }
    if (metadata.Copyright !== DEFAULT_FOUNDER_COPYRIGHT) {
      throw new Error(`Founder mode only accepts the exact Pantas founder copyright: "${DEFAULT_FOUNDER_COPYRIGHT}".`);
    }
  } else {
    // Open assets must NEVER carry Pantas copyright, whether existing or new
    if (existingMetadata.Copyright && /Pantas/i.test(existingMetadata.Copyright)) {
      throw new Error('Pantas copyright is not allowed on open assets (found existing Pantas copyright in input PNG).');
    }
    if (metadata.Copyright && /Pantas/i.test(metadata.Copyright)) {
      throw new Error('Pantas copyright is not allowed on open assets.');
    }
    if (metadata.Copyright) {
      throw new Error('Copyright metadata chunk is not allowed on open assets.');
    }
  }

  const ihdrLength = png.readUInt32BE(8);
  const insertAt = 8 + 4 + 4 + ihdrLength + 4; // signature + IHDR (length, type, data, crc)

  const chunkBuffers = [];
  for (const [key, value] of Object.entries(metadata)) {
    if (value === undefined || value === null) continue;
    const keyBuf = Buffer.from(key, 'latin1');
    const valBuf = Buffer.from(String(value), 'utf8');
    // iTXt header: null (1) + compFlag(0) (1) + compMethod(0) (1) + null lang (1) + null transKey (1)
    const headerBuf = Buffer.from([0x00, 0x00, 0x00, 0x00, 0x00]);
    const data = Buffer.concat([keyBuf, headerBuf, valBuf]);
    const typeAndData = Buffer.concat([Buffer.from('iTXt', 'latin1'), data]);
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

      const target = item.target;
      const isAbsolute = target.startsWith('/') || /^[a-zA-Z]:/.test(target);
      const hasBackslash = target.includes('\\');
      const segments = target.split('/');
      const hasTraversal = segments.some((s) => s === '..' || s === '.' || s === '');
      const normalized = posix.normalize(target);
      const escapesRoot = !normalized.startsWith('content/illustrations/') || normalized !== target;

      if (isAbsolute || hasBackslash || hasTraversal || escapesRoot || !target.endsWith('.png')) {
        errors.push(`${prefix} target must be a valid relative path under content/illustrations/*.png without backslashes or directory traversal: "${target}"`);
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
