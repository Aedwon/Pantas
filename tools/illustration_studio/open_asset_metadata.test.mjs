import { describe, it } from 'node:test';
import assert from 'node:assert/strict';
import zlib from 'node:zlib';
import {
  validateOpenAssetManifest,
  readPngTextChunks,
  stampPngMetadata,
  parseFounderTargets,
  crc32,
  DEFAULT_FOUNDER_COPYRIGHT,
  APPROVED_SOURCE_FAMILIES,
  APPROVED_LICENSES,
} from './open_asset_metadata.mjs';

// Syntactically valid PNG generator with correct CRCs for all chunks
function createValidPng(extraChunks = []) {
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
  const ihdrTypeAndData = Buffer.concat([ihdrType, ihdrData]);
  const ihdrCrc = Buffer.alloc(4);
  ihdrCrc.writeUInt32BE(crc32(ihdrTypeAndData));

  const iendLength = Buffer.alloc(4);
  const iendType = Buffer.from('IEND', 'latin1');
  const iendCrc = Buffer.alloc(4);
  iendCrc.writeUInt32BE(crc32(iendType));

  return Buffer.concat([
    signature,
    ihdrLength, ihdrType, ihdrData, ihdrCrc,
    ...extraChunks,
    iendLength, iendType, iendCrc,
  ]);
}

function makeTextChunk(keyword, text) {
  const data = Buffer.from(`${keyword}\0${text}`, 'latin1');
  const type = Buffer.from('tEXt', 'latin1');
  const typeAndData = Buffer.concat([type, data]);
  const length = Buffer.alloc(4);
  length.writeUInt32BE(data.length);
  const crc = Buffer.alloc(4);
  crc.writeUInt32BE(crc32(typeAndData));
  return Buffer.concat([length, type, data, crc]);
}

function makeZTxtChunk(keyword, text, compressionMethod = 0) {
  const keyBuf = Buffer.from(`${keyword}\0`, 'latin1');
  const methodBuf = Buffer.from([compressionMethod]);
  const compressed = zlib.deflateSync(Buffer.from(text, 'latin1'));
  const data = Buffer.concat([keyBuf, methodBuf, compressed]);
  const type = Buffer.from('zTXt', 'latin1');
  const typeAndData = Buffer.concat([type, data]);
  const length = Buffer.alloc(4);
  length.writeUInt32BE(data.length);
  const crc = Buffer.alloc(4);
  crc.writeUInt32BE(crc32(typeAndData));
  return Buffer.concat([length, type, data, crc]);
}

function makeITXtChunkRaw(keyword, compFlag, compMethod, langTag, transKey, text) {
  const keyBuf = Buffer.from(`${keyword}\0`, 'latin1');
  const flags = Buffer.from([compFlag, compMethod]);
  const langBuf = Buffer.from(`${langTag}\0`, 'latin1');
  const transBuf = Buffer.from(`${transKey}\0`, 'utf8');
  const textBuf = compFlag === 1 ? zlib.deflateSync(Buffer.from(text, 'utf8')) : Buffer.from(text, 'utf8');
  const data = Buffer.concat([keyBuf, flags, langBuf, transBuf, textBuf]);
  const type = Buffer.from('iTXt', 'latin1');
  const typeAndData = Buffer.concat([type, data]);
  const length = Buffer.alloc(4);
  length.writeUInt32BE(data.length);
  const crc = Buffer.alloc(4);
  crc.writeUInt32BE(crc32(typeAndData));
  return Buffer.concat([length, type, data, crc]);
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
  describe('PNG metadata chunk reading and stamping', () => {
    it('stamps and reads open asset metadata (Credit, License, Source)', () => {
      const png = createValidPng();
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

    it('round-trips Unicode metadata without corruption or loss', () => {
      const png = createValidPng();
      const unicodeCredit = 'László Németh & Mikael Häggström (日本語 / Tagalog / 🔬 🌟) / CC BY-SA 4.0';
      const stamped = stampPngMetadata(png, {
        Credit: unicodeCredit,
        License: 'CC BY-SA 4.0',
        Source: 'https://commons.wikimedia.org/wiki/File:Freytag%27s_Pyramid_with_English_text.svg',
      });

      const chunks = readPngTextChunks(stamped);
      assert.equal(chunks.Credit, unicodeCredit);
      assert.equal(chunks.License, 'CC BY-SA 4.0');
    });

    it('decodes legacy ISO-8859-1 tEXt and zTXt chunks containing non-ASCII Latin-1 characters', () => {
      // "Mikael Häggström" encoded in ISO-8859-1
      const textChunk = makeTextChunk('Author', 'Mikael H\xE4ggstr\xF6m');
      const ztxtChunk = makeZTxtChunk('Description', 'Diagram by Mikael H\xE4ggstr\xF6m');
      const png = createValidPng([textChunk, ztxtChunk]);

      const chunks = readPngTextChunks(png);
      assert.equal(chunks.Author, 'Mikael Häggström');
      assert.equal(chunks.Description, 'Diagram by Mikael Häggström');
    });

    it('rejects Pantas copyright in new metadata on open asset stamping', () => {
      const png = createValidPng();
      assert.throws(() => {
        stampPngMetadata(png, {
          Credit: 'OpenStax / CC BY 4.0',
          License: 'CC BY 4.0',
          Source: 'https://openstax.org',
          Copyright: '© 2026 Pantas. All rights reserved.',
        });
      }, /Pantas copyright is not allowed on open assets/);
    });

    it('rejects input PNG that already contains a Pantas copyright when stamping open asset', () => {
      const taintedPng = createValidPng([makeTextChunk('Copyright', '© 2026 Pantas. All rights reserved.')]);
      assert.throws(() => {
        stampPngMetadata(taintedPng, {
          Credit: 'OpenStax / CC BY 4.0',
          License: 'CC BY 4.0',
          Source: 'https://openstax.org',
        }, { isFounder: false });
      }, /Pantas copyright is not allowed on open assets/);
    });

    it('founder mode accepts ONLY exact DEFAULT_FOUNDER_COPYRIGHT and requires exactly that one field', () => {
      const png = createValidPng();
      const stamped = stampPngMetadata(png, {
        Copyright: DEFAULT_FOUNDER_COPYRIGHT,
      }, { isFounder: true });

      const chunks = readPngTextChunks(stamped);
      assert.equal(chunks.Copyright, DEFAULT_FOUNDER_COPYRIGHT);

      // Rejects empty metadata
      assert.throws(() => {
        stampPngMetadata(png, {}, { isFounder: true });
      }, /Founder mode requires metadata with exactly one Copyright field/);

      // Rejects extra fields in founder mode
      assert.throws(() => {
        stampPngMetadata(png, {
          Copyright: DEFAULT_FOUNDER_COPYRIGHT,
          Credit: 'Some Author',
        }, { isFounder: true });
      }, /Founder mode only allows the Copyright field/);

      // Rejects different year
      assert.throws(() => {
        stampPngMetadata(png, {
          Copyright: '© 2025 Pantas. All rights reserved.',
        }, { isFounder: true });
      }, /Founder mode only accepts the exact Pantas founder copyright/);

      // Rejects arbitrary copyright string
      assert.throws(() => {
        stampPngMetadata(png, {
          Copyright: 'Arbitrary Studio Copyright 2026',
        }, { isFounder: true });
      }, /Founder mode only accepts the exact Pantas founder copyright/);
    });
  });

  describe('Robust PNG Chunk Parsing & Validation', () => {
    it('rejects invalid signature', () => {
      const badSig = Buffer.from([0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]);
      assert.throws(() => readPngTextChunks(badSig), /valid PNG/);
    });

    it('rejects truncated chunk header', () => {
      const png = createValidPng();
      const truncated = png.subarray(0, 12); // cut inside IHDR length/type
      assert.throws(() => readPngTextChunks(truncated), /Truncated|incomplete/i);
    });

    it('rejects truncated chunk data', () => {
      const png = createValidPng();
      const truncated = png.subarray(0, 20); // cut inside IHDR data
      assert.throws(() => readPngTextChunks(truncated), /Truncated/i);
    });

    it('rejects chunk with bad CRC', () => {
      const png = createValidPng();
      const corrupted = Buffer.from(png);
      corrupted[29] = corrupted[29] ^ 0xff; // corrupt IHDR CRC byte
      assert.throws(() => readPngTextChunks(corrupted), /CRC/i);
    });

    it('rejects invalid ordering where first chunk is not IHDR', () => {
      const signature = Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);
      const badOrder = Buffer.concat([signature, makeTextChunk('Credit', 'test')]);
      assert.throws(() => readPngTextChunks(badOrder), /first chunk must be IHDR|invalid ordering/i);
    });

    it('rejects PNG missing IEND chunk', () => {
      const signature = Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);
      const ihdrData = Buffer.from([0,0,0,1, 0,0,0,1, 8, 6, 0, 0, 0]);
      const ihdrLen = Buffer.alloc(4); ihdrLen.writeUInt32BE(13);
      const ihdrType = Buffer.from('IHDR', 'latin1');
      const ihdrCrc = Buffer.alloc(4); ihdrCrc.writeUInt32BE(crc32(Buffer.concat([ihdrType, ihdrData])));
      const missingIend = Buffer.concat([signature, ihdrLen, ihdrType, ihdrData, ihdrCrc]);
      assert.throws(() => readPngTextChunks(missingIend), /missing IEND/i);
    });

    it('rejects trailing data after IEND chunk', () => {
      const png = createValidPng();
      const withTrailing = Buffer.concat([png, Buffer.from([0x01, 0x02, 0x03])]);
      assert.throws(() => readPngTextChunks(withTrailing), /data found after IEND|invalid ordering/i);
    });

    it('rejects malformed tEXt chunk without null separator', () => {
      const badData = Buffer.from('NoNullSeparatorHere', 'latin1');
      const type = Buffer.from('tEXt', 'latin1');
      const typeAndData = Buffer.concat([type, badData]);
      const len = Buffer.alloc(4); len.writeUInt32BE(badData.length);
      const crc = Buffer.alloc(4); crc.writeUInt32BE(crc32(typeAndData));
      const chunk = Buffer.concat([len, type, badData, crc]);
      const png = createValidPng([chunk]);
      assert.throws(() => readPngTextChunks(png), /malformed tEXt/i);
    });

    it('rejects malformed zTXt chunk with invalid compression method or missing separator', () => {
      const badZtxt = makeZTxtChunk('Keyword', 'Some text', 1); // compression method 1 is invalid
      const png = createValidPng([badZtxt]);
      assert.throws(() => readPngTextChunks(png), /compression method/i);
    });

    it('rejects malformed iTXt chunk with invalid compression flag, method, or missing separators', () => {
      const badFlagChunk = makeITXtChunkRaw('Key', 2, 0, '', '', 'text'); // flag 2 invalid
      assert.throws(() => readPngTextChunks(createValidPng([badFlagChunk])), /compression flag/i);

      const badMethodChunk = makeITXtChunkRaw('Key', 0, 1, '', '', 'text'); // method 1 invalid
      assert.throws(() => readPngTextChunks(createValidPng([badMethodChunk])), /compression method/i);
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

    it('accepts Wikimedia Commons and upload.wikimedia.org/wikipedia/commons/ but rejects other upload paths and wikipedia.org pages', () => {
      const commonsAsset = {
        ...validSampleManifest.assets[0],
        sourcePage: 'https://commons.wikimedia.org/wiki/File:Test.svg',
        directUrl: 'https://upload.wikimedia.org/wikipedia/commons/1/12/Test.jpg',
      };
      assert.deepEqual(validateOpenAssetManifest({ version: 1, assets: [commonsAsset] }), []);

      const badUploadAsset = {
        ...validSampleManifest.assets[0],
        sourcePage: 'https://commons.wikimedia.org/wiki/File:Test.svg',
        directUrl: 'https://upload.wikimedia.org/wikipedia/en/1/12/Test.jpg',
      };
      const badUploadErrors = validateOpenAssetManifest({ version: 1, assets: [badUploadAsset] });
      assert.ok(badUploadErrors.some((e) => e.includes('directUrl')));

      const wikipediaAsset = {
        ...validSampleManifest.assets[0],
        sourcePage: 'https://en.wikipedia.org/wiki/File:Test.svg',
      };
      const wikiErrors = validateOpenAssetManifest({ version: 1, assets: [wikipediaAsset] });
      assert.ok(wikiErrors.some((e) => e.includes('approved families')));

      const nonCommonsWikimediaAsset = {
        ...validSampleManifest.assets[0],
        sourcePage: 'https://meta.wikimedia.org/wiki/File:Test.svg',
      };
      const nonCommonsErrors = validateOpenAssetManifest({
        version: 1,
        assets: [nonCommonsWikimediaAsset],
      });
      assert.ok(nonCommonsErrors.some((e) => e.includes('approved families')));
    });

    it('rejects target paths with absolute paths, traversal, backslashes, or normalized escape', () => {
      const makeBadTarget = (target) => ({
        version: 1,
        assets: [{ ...validSampleManifest.assets[0], target }],
      });

      assert.ok(validateOpenAssetManifest(makeBadTarget('/content/illustrations/test.png')).length > 0);
      assert.ok(validateOpenAssetManifest(makeBadTarget('content/illustrations/../test.png')).length > 0);
      assert.ok(validateOpenAssetManifest(makeBadTarget('content/illustrations/../../etc/passwd')).length > 0);
      assert.ok(validateOpenAssetManifest(makeBadTarget('content\\illustrations\\test.png')).length > 0);
      assert.ok(validateOpenAssetManifest(makeBadTarget('content/illustrations\\..\\test.png')).length > 0);
      assert.ok(validateOpenAssetManifest(makeBadTarget('other/illustrations/test.png')).length > 0);
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

  describe('parseFounderTargets', () => {
    it('correctly parses founder target paths from strategy.tsv content', () => {
      const sampleTsv = `subject\ttopic\tlesson\tseq\ttarget_file\tdescription\tstrategy\tbatch
reading-comprehension\ttext-types\tvisual-media\t1\tcontent/illustrations/reading-comprehension/text-types/visual-media/01.png\tdesc1\tfounder\tfounder
science\tbiology\tbotany\t1\tcontent/illustrations/science/biology/botany/01.png\tdesc2\topen\topen-a
reading-comprehension\ttext-types\tvisual-media\t2\tcontent/illustrations/reading-comprehension/text-types/visual-media/02.png\tdesc3\tfounder\tfounder`;

      const founderSet = parseFounderTargets(sampleTsv);
      assert.equal(founderSet.size, 2);
      assert.ok(founderSet.has('content/illustrations/reading-comprehension/text-types/visual-media/01.png'));
      assert.ok(founderSet.has('content/illustrations/reading-comprehension/text-types/visual-media/02.png'));
      assert.ok(!founderSet.has('content/illustrations/science/biology/botany/01.png'));
    });

    it('throws error when target_file or strategy column is missing from header', () => {
      const badHeader1 = 'subject\ttopic\tlesson\tseq\tdescription\tstrategy\tbatch\nfoo\tbar';
      assert.throws(() => parseFounderTargets(badHeader1), /missing required columns/i);

      const badHeader2 = 'subject\ttopic\tlesson\tseq\ttarget_file\tdescription\tbatch\nfoo\tbar';
      assert.throws(() => parseFounderTargets(badHeader2), /missing required columns/i);
    });
  });
});
