import 'package:pantas/core/ui/components/choice_row.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/lesson_text_scale.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

/// The Text Size preview (board TS_A, chosen option A): one lesson sentence,
/// one quiz stem and two answer choices, set at the lesson text scale the
/// reader and the quiz use, so it shows what lessons and questions will look
/// like and follows the slider as it moves.
///
/// It is a picture of the setting: the choices are the real answer option
/// component, not tappable, and the whole sample is hidden from screen
/// readers (the board marks it `aria-hidden`). The stem uses straight quotes,
/// the Settings rule (QA 5Q-4), where the board drew curly ones.
class TextSizeSample extends StatelessWidget {
  const TextSizeSample({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = context.wideWeb;
    final c = context.colors;
    final sentence =
        (wide ? PantasType.webReaderBody : PantasType.phoneReaderBody)
            .copyWith(color: c.readerBody);
    final stem = (wide ? PantasType.webQuestion : PantasType.phoneQuestion)
        .copyWith(color: c.textPrimary);
    return ExcludeSemantics(
      child: IgnorePointer(
        child: LessonTextScale(
          child: Column(
            key: const ValueKey('text-size-sample'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'A synonym is a word that means nearly the same as another '
                'word.',
                style: sentence,
              ),
              const SizedBox(height: PantasSpace.s12),
              Text('Which word means the same as "rapid"?', style: stem),
              const SizedBox(height: PantasSpace.s12),
              const ChoiceRow(letter: 'A', text: 'Fast'),
              const SizedBox(height: PantasSpace.s12),
              const ChoiceRow(letter: 'B', text: 'Quiet'),
            ],
          ),
        ),
      ),
    );
  }
}
