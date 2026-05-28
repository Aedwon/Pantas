import 'package:cse_cet_reviewer/features/wrapped/domain/wrapped_payload.dart';
import 'package:cse_cet_reviewer/features/wrapped/domain/wrapped_trigger_event.dart';

class WrappedArchetypeSnapshot {
  const WrappedArchetypeSnapshot({
    required this.id,
    required this.label,
    required this.synthesizedCopy,
  });

  final String id;
  final String label;
  final String synthesizedCopy;
}

class WrappedComposer {
  const WrappedComposer();

  WrappedPayload? compose({
    required WrappedTriggerEvent trigger,
    required WrappedArchetypeSnapshot? archetype,
    required String shareId,
  }) {
    if (archetype == null) return null;
    return WrappedPayload(
      title: _title(trigger.artifactId),
      archetypeId: archetype.id,
      shareId: shareId,
      slides: [
        WrappedSlide(title: 'Your moment', body: _title(trigger.artifactId)),
        WrappedSlide(title: archetype.label, body: archetype.synthesizedCopy),
      ],
    );
  }

  String _title(String artifactId) {
    if (artifactId.startsWith('post_mock_recap')) return 'Mock recap';
    if (artifactId.startsWith('streak_milestone')) return 'Streak milestone';
    if (artifactId.startsWith('mastery_crossing')) return 'Mastery unlocked';
    if (artifactId.startsWith('post_exam_debrief')) return 'Exam debrief';
    if (artifactId.startsWith('milestone_batch')) return 'Milestones';
    return 'Wrapped';
  }
}
