import { describe, it } from 'node:test';
import assert from 'node:assert/strict';
import {
  validateOpenAssetManifest,
  readPngTextChunks,
  stampPngMetadata,
  DEFAULT_FOUNDER_COPYRIGHT,
  APPROVED_SOURCE_FAMILIES,
  APPROVED_LICENSES,
} from './open_asset_metadata.mjs';

// Minimal 1x1 valid PNG buffer for testing metadata stamping
// 8-byte signature + IHDR chunk (13 bytes data) + IEND chunk
function createMinimalPng() {
  const signature = Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);
  // IHDR: 1x1, 8-bit truecolor with alpha (6), def compression (0), def filter (0), no interlace (0)
  const ihdrData = Buffer.from([
    0x00, 0x00, 0x00, 0x01, // width: 1
    0x00, 0x00, 0x00, 0x01, // height: 1
    0x08, // bit depth: 8
    0x06, // color type: RGBA
    0x00, // compression
    0x00, // filter
    0x00, // interlace
  ]);
  const ihdrLength = Buffer.alloc(4);
  ihdrLength.writeUInt32BE(ihdrData.length);
  const ihdrType = Buffer.from('IHDR', 'latin1');
  const ihdrCrc = Buffer.alloc(4);
  ihdrCrc.writeUInt32BE(0x3775086d); // precomputed CRC for 1x1 RGBA IHDR

  const iendLength = Buffer.alloc(4);
  const iendType = Buffer.from('IEND', 'latin1');
  const iendCrc = Buffer.alloc(4);
  iendCrc.writeUInt32BE(0xae426082);

  return Buffer.concat([
    signature,
    ihdrLength, ihdrType, ihdrData, ihdrCrc,
    iendLength, iendType, iendCrc,
  ]);
}

const validSampleManifest = {
  version: 1,
  assets: [
    {
      key: 'science/biology/cell-biology#1',
      sourcePage: 'https://commons.wikimedia.org/wiki/File:Animal_cell_structure_en.svg',
      directUrl: 'https://upload.wikimedia.org/wikipedia/commons/4/48/Animal_cell_structure_en.svg',
      license: 'CC BY-SA 4.0',
      creator: 'LadyofHats',
      credit: 'Mariana Ruiz Villarreal (LadyofHats) / Wikimedia Commons / CC BY-SA 4.0',
      target: 'content/illustrations/science/biology/cell-biology/01-generalized-cell-nucleus-mitochondria.png',
      sha256: 'a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2',
    },
    {
      key: 'science/physics/thermodynamics#1',
      sourcePage: 'https://openstax.org/books/physics/pages/1-introduction',
      directUrl: 'https://openstax.org/resources/test-image.png',
      license: 'CC BY 4.0',
      creator: 'OpenStax',
      credit: 'OpenStax / Rice University / CC BY 4.0',
      target: 'content/illustrations/science/physics/thermodynamics/01-conduction-heat-moving-through.png',
      sha256: '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
    },
  ],
};

describe('open_asset_metadata', () => {
  describe('PNG tEXt chunk reading and stamping', () => {
    it('stamps and reads open asset metadata (Credit, License, Source)', () => {
      const png = createMinimalPng();
      const stamped = stampPngMetadata(png, {
        Credit: 'OpenStax / Rice University / CC BY 4.0',
        License: 'CC BY 4.0',
        Source: 'https://openstax.org/books/physics/pages/1-introduction',
      });

      const chunks = readPngTextChunks(stamped);
      assert.equal(chunks.Credit, 'OpenStax / Rice University / CC BY 4.0');
      assert.equal(chunks.License, 'CC BY 4.0');
      assert.equal(chunks.Source, 'https://openstax.org/books/physics/pages/1-introduction');
      assert.equal(chunks.Copyright, undefined);
    });

    it('rejects Pantas copyright on open asset stamping', () => {
      const png = createMinimalPng();
      assert.throws(() => {
        stampPngMetadata(png, {
          Credit: 'OpenStax / CC BY 4.0',
          License: 'CC BY 4.0',
          Source: 'https://openstax.org',
          Copyright: '© 2026 Pantas. All rights reserved.',
        });
      }, /Pantas copyright is not allowed on open assets/);
    });

    it('preserves founder default copyright when explicitly requested', () => {
      const png = createMinimalPng();
      const stamped = stampPngMetadata(png, {
        Copyright: DEFAULT_FOUNDER_COPYRIGHT,
      }, { isFounder: true });

      const chunks = readPngTextChunks(stamped);
      assert.match(chunks.Copyright, /Pantas\. All rights reserved\./);
      assert.equal(chunks.Credit, undefined);
    });
  });

  describe('validateOpenAssetManifest', () => {
    it('validates a correct manifest with 0 errors', () => {
      const errors = validateOpenAssetManifest(validSampleManifest);
      assert.deepEqual(errors, []);
    });

    it('rejects missing fields', () => {
      const bad = {
        version: 1,
        assets: [
          {
            key: 'science/biology/cell-biology#1',
            sourcePage: 'https://commons.wikimedia.org/wiki/File:Test.png',
            // missing directUrl, license, creator, credit, target, sha256
          },
        ],
      };
      const errors = validateOpenAssetManifest(bad);
      assert.ok(errors.length >= 6, `Expected at least 6 errors, got: ${errors.join(', ')}`);
    });

    it('rejects duplicate keys', () => {
      const bad = {
        version: 1,
        assets: [
          { ...validSampleManifest.assets[0] },
          { ...validSampleManifest.assets[0], target: 'content/illustrations/other.png' },
        ],
      };
      const errors = validateOpenAssetManifest(bad);
      assert.ok(errors.some((e) => e.includes('Duplicate key')));
    });

    it('rejects duplicate targets', () => {
      const bad = {
        version: 1,
        assets: [
          { ...validSampleManifest.assets[0] },
          { ...validSampleManifest.assets[1], target: validSampleManifest.assets[0].target },
        ],
      };
      const errors = validateOpenAssetManifest(bad);
      assert.ok(errors.some((e) => e.includes('Duplicate target')));
    });

    it('rejects bad SHA-256 digest', () => {
      const bad = {
        version: 1,
        assets: [
          {
            ...validSampleManifest.assets[0],
            sha256: 'INVALID_SHA',
          },
        ],
      };
      const errors = validateOpenAssetManifest(bad);
      assert.ok(errors.some((e) => e.includes('sha256')));
    });

    it('rejects non-approved source family', () => {
      const bad = {
        version: 1,
        assets: [
          {
            ...validSampleManifest.assets[0],
            sourcePage: 'https://example.com/unapproved-source.html',
          },
        ],
      };
      const errors = validateOpenAssetManifest(bad);
      assert.ok(errors.some((e) => e.includes('sourcePage')));
    });

    it('rejects non-commercial or restrictive licenses', () => {
      const bad = {
        version: 1,
        assets: [
          {
            ...validSampleManifest.assets[0],
            license: 'CC BY-NC 4.0',
          },
        ],
      };
      const errors = validateOpenAssetManifest(bad);
      assert.ok(errors.some((e) => e.includes('license')));
    });

    it('rejects non-HTTPS URLs', () => {
      const bad = {
        version: 1,
        assets: [
          {
            ...validSampleManifest.assets[0],
            sourcePage: 'http://commons.wikimedia.org/wiki/File:Animal_cell_structure_en.svg',
          },
        ],
      };
      const errors = validateOpenAssetManifest(bad);
      assert.ok(errors.some((e) => e.includes('HTTPS')));
    });
  });
});
