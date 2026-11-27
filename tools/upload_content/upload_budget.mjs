// The upload tool's read budget. Before a hosted run reads anything, the tool reads the project's Firestore
// reads for the current quota day, adds the reads the run will make, and refuses to start if the total
// passes the budget. There is no override. Written rule 7, docs/workflow/process-improvement.md.
import {firestoreReadsToday} from '../../tool/checks/free_tier_live.mjs';

// Manager's ruling (CSE release lead r10, Nov 28, 2026): staging 40,000 reads a day, the budget set on Nov 16
// (80% of the 50,000 free quota). Prod's tool runs get 40,000 minus a reserve for real users, 15,000, so 25,000
// used-plus-expected. Why 15,000: prod real users read about 10,000 on the opening night with almost no
// sign-ups; 15,000 keeps headroom as sign-ups grow. The free quota is 50,000 a day; only users may cost money.
export const PROD_REAL_USER_RESERVE = 15000;
export const BUDGETS = {staging: 40000, prod: 40000 - PROD_REAL_USER_RESERVE};

/** The budget for a project id, or null when the project is neither staging nor prod. */
export function budgetFor(project) {
  if (/staging/.test(project)) return BUDGETS.staging;
  if (/^pantas-prod$/.test(project)) return BUDGETS.prod;
  return null;
}

/** Pure: allowed only when used plus expected stays within the budget. */
export function decideBudget({used, expected, budget}) {
  const ok = used + expected <= budget;
  return {ok, line: `${ok ? 'Within budget' : 'Refusing to run'}: used ${used}, expected ${expected}, budget ${budget} reads today.`};
}

/**
 * Exit code for the start of a run: 0 to go on, 75 to stop. Only a hosted run (`--live`, no emulator, no
 * `--out-dir`) is checked. If usage cannot be read, or the project has no budget, it refuses: unknown is not zero.
 */
export async function guardLiveRun({live, emulator, outDir, project, expected, readUsage = firestoreReadsToday, log = console.error}) {
  if (!live || emulator || outDir) return 0;
  const budget = budgetFor(project);
  if (budget === null) {
    log(`Refusing to run: no read budget is set for project ${project}.`);
    return 75;
  }
  let used;
  try {
    used = await readUsage(project);
  } catch (error) {
    log(`Refusing to run: could not read today's Firestore reads for ${project} (${error.message}). Unknown is not zero.`);
    return 75;
  }
  const decision = decideBudget({used, expected, budget});
  if (!decision.ok) log(decision.line);
  return decision.ok ? 0 : 75;
}
