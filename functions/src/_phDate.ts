/**
 * The Dart engine reads every date as a local calendar value. Students are in the Philippines
 * (UTC+8, no daylight saving), and a Cloud Function runs in UTC, so a raw instant would put the
 * evening in the wrong day. Always convert here and pass the strings, never a UTC instant.
 */
const OFFSET_MS = 8 * 3_600_000;

/** `YYYY-MM-DD` of the Philippine calendar day that contains the instant. */
export const phDay = (ms: number): string => new Date(ms + OFFSET_MS).toISOString().slice(0, 10);

/** `YYYY-MM-DDTHH:MM:SS` of the instant on a Philippine wall clock. */
export const phStamp = (ms: number): string => new Date(ms + OFFSET_MS).toISOString().slice(0, 19);
