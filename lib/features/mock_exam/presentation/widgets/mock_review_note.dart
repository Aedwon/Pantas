import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/button_pair.dart';
import 'package:pantas/core/ui/components/floating_bar.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/mock_exam/domain/mock_results.dart';

@immutable
class MockReviewNoteValue {
  const MockReviewNoteValue({this.missReason, this.blankReason, this.reasonNote});
  final MissReason? missReason;
  final BlankReason? blankReason;
  final String? reasonNote;
}

class MockReviewNote extends StatefulWidget {
  const MockReviewNote({required this.blank, required this.onCancel,
    required this.onSave, this.initial, super.key});
  final bool blank;
  final MockAnswer? initial;
  final VoidCallback onCancel;
  final Future<void> Function(MockReviewNoteValue) onSave;
  @override
  State<MockReviewNote> createState() => _MockReviewNoteState();
}
class _MockReviewNoteState extends State<MockReviewNote> {
  int? _selected;
  late final TextEditingController _text;
  bool _busy = false;
  MockReviewNoteValue? _failed;
  @override
  void initState() {
    super.initState();
    _selected = widget.blank ? widget.initial?.blankReason?.index : widget.initial?.missReason?.index;
    _text = TextEditingController(text: widget.initial?.reasonNote ?? '');
  }
  @override
  void dispose() { _text.dispose(); super.dispose(); }
  Future<void> _save([MockReviewNoteValue? retry]) async {
    if (_busy || _selected == null) return;
    final value = retry ?? MockReviewNoteValue(
      missReason: widget.blank ? null : MissReason.values[_selected!],
      blankReason: widget.blank ? BlankReason.values[_selected!] : null,
      reasonNote: _selected == 3 ? _text.text.trim() : null);
    setState(() { _busy = true; _failed = null; });
    try { await widget.onSave(value); }
    catch (_) { if (mounted) setState(() => _failed = value); }
    finally { if (mounted) setState(() => _busy = false); }
  }
  @override
  Widget build(BuildContext context) {
    final labels = widget.blank
      ? ['I ran out of time', 'I skipped it to come back later', "I didn't know it", 'Type my own']
      : ['I misread it', 'I knew it, I just slipped', "I didn't know it", 'Type my own'];
    return ConstrainedBox(constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .8),
      child: DecoratedBox(decoration: BoxDecoration(borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.colors.destructive.withValues(alpha: .26))),
      child: FloatingBar.content(radius: 24, inset: 18, child: SingleChildScrollView(child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
          Text(widget.blank ? 'Why did you leave it blank?' : 'Why did you miss it?', style: context.type.emphasized.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          for (var i = 0; i < labels.length; i++) Semantics(checked: _selected == i,
            inMutuallyExclusiveGroup: true, child: InkWell(onTap: _busy || _failed != null ? null : () => setState(() => _selected = i),
              child: Container(constraints: const BoxConstraints(minHeight: 46),
                decoration: BoxDecoration(border: i < labels.length - 1 ? Border(bottom: BorderSide(color: context.colors.separator, width: .5)) : null),
                child: Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [
                  Container(width: 22, height: 22, decoration: BoxDecoration(shape: BoxShape.circle,
                    color: _selected == i ? context.colors.accentFill : null,
                    border: _selected == i ? null : Border.all(color: context.colors.controlOutline, width: 1.5)),
                    child: _selected == i ? Icon(PantasIcons.check, size: 13, color: context.colors.onAccent) : null),
                  const SizedBox(width: 12), Expanded(child: Text(labels[i], style: context.type.body.copyWith(fontSize: 16))),
                ]))))),
          if (_selected == 3) TextField(controller: _text, enabled: !_busy && _failed == null,
            minLines: 2, maxLines: 4, style: context.type.subhead),
          const SizedBox(height: 12),
          ButtonPair(primary: PantasButton(label: _failed == null ? 'Add Note' : 'Try Again', height: 44, radius: 99, fontSize: 16,
              busy: _busy, onPressed: _selected == null || (_selected == 3 && _text.text.trim().isEmpty) ? null : () => _save(_failed)),
            secondary: PantasButton(label: 'Cancel', height: 44, radius: 99, fontSize: 16,
              variant: PantasButtonVariant.secondary, onPressed: _busy ? null : widget.onCancel)),
        ])))));
  }
}
