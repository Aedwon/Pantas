// Cloud Functions entry point. Pub/Sub delivers each message as a CloudEvent.
import functions from '@google-cloud/functions-framework';
import {cloudBilling, handle} from './cutoff.mjs';

const billing = cloudBilling();
functions.cloudEvent('stopBilling', event => handle(event.data?.message, process.env, billing));
