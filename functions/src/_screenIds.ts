/**
 * The closed set of screen names used by usage telemetry: the usage record (`usageVisit.ts`) and
 * the optional screen counts in the speed and error report (`clientTelemetry.ts`) both use it. It
 * lives here so neither file copies it. It must match `lib/core/telemetry/screen_ids.dart` (a
 * Flutter test compares the two).
 */

export const SCREEN_IDS = [
  'home', 'performance', 'performance_topic', 'plan', 'plan_day', 'plan_history', 'plan_week',
  'record', 'tendencies', 'assessment', 'assessment_results', 'lesson',
  'quiz', 'quiz_all', 'quiz_debrief', 'quiz_flagged', 'quiz_flagged_question', 'quiz_inline',
  'quiz_practice', 'quiz_practice_run', 'quiz_quick', 'quiz_resume', 'quiz_retake', 'quiz_today',
  'quiz_viewer', 'study', 'study_ending',
  'mock_results', 'mock_review', 'mock_custom_setup', 'mock_resume', 'mock_setup',
  'legal', 'pro',
  'settings', 'settings_about', 'settings_accessibility', 'settings_account',
  'settings_adult_check', 'settings_delete_account', 'settings_account_name', 'settings_appearance',
  'settings_backup', 'settings_beta_feedback', 'settings_beta_feedback_sent',
  'settings_beta_survey', 'settings_exam', 'settings_exam_change', 'settings_exam_custom_name',
  'settings_exam_custom_subjects', 'settings_exam_included', 'settings_exam_transfer',
  'settings_exam_upgrade', 'settings_practice',
  'auth_email_link', 'beta', 'guardian', 'guardian_contact', 'guardian_manage',
  'guardian_waiting', 'guardian_withdrawn', 'onboarding', 'onboarding_custom_name',
  'onboarding_custom_subjects', 'update_required', 'wrapped', 'other',
] as const;
