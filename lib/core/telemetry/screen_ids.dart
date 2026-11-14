/// The closed set of screen names used by usage telemetry, and the one
/// function that turns an address into a name.
///
/// A name comes from a route template, never from the address itself, so no
/// lesson id, attempt id, date or other value a student produced can reach a
/// record. An address that matches no template is `other`.
///
/// `functions/src/usageVisit.ts` holds the same list for the server. A test
/// compares the two.
const _templates = <String, String>{
  '/home': 'home',
  '/performance': 'performance',
  '/performance/topic/:topicId': 'performance_topic',
  '/plan': 'plan',
  '/plan/day/:date': 'plan_day',
  '/plan/history': 'plan_history',
  '/plan/week/:start': 'plan_week',
  '/record': 'record',
  '/tendencies': 'tendencies',
  '/assessment/:examId': 'assessment',
  '/assessment/:examId/results': 'assessment_results',
  '/lesson/:lessonId': 'lesson',
  '/quiz': 'quiz',
  '/quiz/all/:attemptId': 'quiz_all',
  '/quiz/debrief/:attemptId': 'quiz_debrief',
  '/quiz/flagged/:examId': 'quiz_flagged',
  '/quiz/flagged/:examId/view/:questionId': 'quiz_flagged_question',
  '/quiz/inline/:examId/:lessonId': 'quiz_inline',
  '/quiz/practice/:examId': 'quiz_practice',
  '/quiz/practice/:examId/run': 'quiz_practice_run',
  '/quiz/quick/:examId': 'quiz_quick',
  '/quiz/resume/:examId': 'quiz_resume',
  '/quiz/retake/:examId': 'quiz_retake',
  '/quiz/today/:examId': 'quiz_today',
  '/quiz/viewer/:attemptId': 'quiz_viewer',
  '/study': 'study',
  '/study/ending/:topicId': 'study_ending',
  '/mock/results/:attemptId': 'mock_results',
  '/mock/review/:attemptId': 'mock_review',
  '/quiz/mock/custom-setup': 'mock_custom_setup',
  '/quiz/mock/resume/:attemptId': 'mock_resume',
  '/quiz/mock/setup': 'mock_setup',
  '/legal/:doc': 'legal',
  '/pro': 'pro',
  '/settings': 'settings',
  '/settings/about': 'settings_about',
  '/settings/accessibility': 'settings_accessibility',
  '/settings/account': 'settings_account',
  '/settings/account/adult-check': 'settings_adult_check',
  '/settings/account/delete': 'settings_delete_account',
  '/settings/account/name': 'settings_account_name',
  '/settings/appearance': 'settings_appearance',
  '/settings/backup': 'settings_backup',
  '/settings/beta-feedback': 'settings_beta_feedback',
  '/settings/beta-feedback/sent/:id': 'settings_beta_feedback_sent',
  '/settings/beta-feedback/survey': 'settings_beta_survey',
  '/settings/exam': 'settings_exam',
  '/settings/exam/change': 'settings_exam_change',
  '/settings/exam/custom/name': 'settings_exam_custom_name',
  '/settings/exam/custom/subjects': 'settings_exam_custom_subjects',
  '/settings/exam/included': 'settings_exam_included',
  '/settings/exam/transfer': 'settings_exam_transfer',
  '/settings/exam/upgrade': 'settings_exam_upgrade',
  '/settings/practice': 'settings_practice',
  '/settings/pro': 'pro',
  '/auth/email-link': 'auth_email_link',
  '/beta': 'beta',
  '/guardian': 'guardian',
  '/guardian/contact': 'guardian_contact',
  '/guardian/manage': 'guardian_manage',
  '/guardian/waiting': 'guardian_waiting',
  '/guardian/withdrawn': 'guardian_withdrawn',
  '/onboarding': 'onboarding',
  '/onboarding/custom/name': 'onboarding_custom_name',
  '/onboarding/custom/subjects': 'onboarding_custom_subjects',
  '/startup': 'startup',
  '/update-required': 'update_required',
  '/wrapped/:artifactId': 'wrapped',
};

/// The name for an address that matches no template.
const otherScreenId = 'other';

/// The loading screen shown while the app decides where to go. It has a name
/// so [screenIdFor] is total, but it is not a screen a person opens, so it is
/// never recorded.
const startupScreenId = 'startup';

final Set<String> screenIdSet = {..._templates.values, otherScreenId};

/// Every id that can be recorded. This is the list the server accepts.
final List<String> trackedScreenIds = [
  for (final id in screenIdSet)
    if (id != startupScreenId) id,
];

final List<(List<String>, String)> _compiled = [
  for (final entry in _templates.entries)
    (entry.key.split('/').where((s) => s.isNotEmpty).toList(), entry.value),
];

/// The screen name for [location], an address such as `/lesson/abc?x=1`.
String screenIdFor(String location) {
  final path = Uri.tryParse(location)?.path ?? '';
  final segments = path.split('/').where((s) => s.isNotEmpty).toList();
  if (segments.isEmpty) return otherScreenId;
  var best = otherScreenId;
  var bestStatic = -1;
  for (final (template, id) in _compiled) {
    if (template.length != segments.length) continue;
    var statics = 0;
    var matches = true;
    for (var i = 0; i < template.length; i++) {
      if (template[i].startsWith(':')) continue;
      if (template[i] != segments[i]) {
        matches = false;
        break;
      }
      statics++;
    }
    if (matches && statics > bestStatic) {
      best = id;
      bestStatic = statics;
    }
  }
  return best;
}
