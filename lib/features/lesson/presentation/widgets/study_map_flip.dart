import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Slides [child] from where it stood to where layout now puts it.
///
/// The wide Study map changes its columns when a topic opens or closes, and
/// each subject lands somewhere else at once. Call [RenderStudyMapFlip.capture]
/// before that rebuild. Then [progress] (0 to 1, already eased) walks the child
/// from the captured spot to its new one.
///
/// Only the paint offset moves, so no text is laid out again while it slides.
/// Give the child its own repaint boundary and it is not drawn again either.
/// The slide is read from the child's place in the window, so a scroll
/// position that differs between the two layouts is part of the slide.
class StudyMapFlip extends SingleChildRenderObjectWidget {
  const StudyMapFlip({required this.progress, super.child, super.key});

  final Animation<double> progress;

  @override
  RenderStudyMapFlip createRenderObject(BuildContext context) =>
      RenderStudyMapFlip(progress);

  @override
  void updateRenderObject(
    BuildContext context,
    RenderStudyMapFlip renderObject,
  ) =>
      renderObject.progress = progress;
}

class RenderStudyMapFlip extends RenderProxyBox {
  RenderStudyMapFlip(this._progress);

  Animation<double> _progress;
  Offset? _from;
  Offset _shift = Offset.zero;

  /// How far the child is drawn from its laid-out place right now.
  Offset get shift => _shift;

  Animation<double> get progress => _progress;
  set progress(Animation<double> value) {
    if (value == _progress) return;
    if (attached) _progress.removeListener(markNeedsPaint);
    _progress = value;
    if (attached) _progress.addListener(markNeedsPaint);
    markNeedsPaint();
  }

  /// Remembers where the child is drawn now, in the window. Call it before
  /// the rebuild that moves it.
  void capture() {
    if (!attached || !hasSize) return;
    _from = localToGlobal(Offset.zero) + _shift;
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _progress.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _progress.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final from = _from;
    final child = this.child;
    if (child == null) return;
    if (from == null || _progress.value >= 1) {
      _from = null;
      _shift = Offset.zero;
      context.paintChild(child, offset);
      return;
    }
    _shift = (from - localToGlobal(Offset.zero)) * (1 - _progress.value);
    context.paintChild(child, offset + _shift);
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    transform.translateByDouble(_shift.dx, _shift.dy, 0, 1);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      result.addWithPaintOffset(
        offset: _shift,
        position: position,
        hitTest: (result, transformed) =>
            child?.hitTest(result, position: transformed) ?? false,
      );
}
