import {queries} from './queries.mjs';

const required = ['SANITY_PROJECT_ID', 'SANITY_DATASET', 'SANITY_READ_TOKEN'];
const missing = required.filter((key) => !process.env[key]);

if (missing.length > 0) {
  console.error(`Missing required environment variables: ${missing.join(', ')}`);
  process.exit(1);
}

const {createClient} = await import('@sanity/client');

const client = createClient({
  projectId: process.env.SANITY_PROJECT_ID,
  dataset: process.env.SANITY_DATASET,
  apiVersion: '2024-01-01',
  token: process.env.SANITY_READ_TOKEN,
  useCdn: false,
});

const result = {};
for (const [doctype, query] of Object.entries(queries)) {
  result[doctype] = await client.fetch(query);
}

process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);
