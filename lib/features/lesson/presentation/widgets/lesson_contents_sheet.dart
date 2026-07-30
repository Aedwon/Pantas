import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/lesson/application/reader_providers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Future<void> showLessonContentsSheet(
  BuildContext context, {
  required ReaderContext reader,
  void Function(String lessonId)? onSelectLesson,
}) async {
  final colors = context.colors;
  final maxHeight = MediaQuery.of(context).size.height * 0.74;

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    elevation: 0,
    barrierColor: colors.ink.withValues(alpha: 0.34),
    isScrollControlled: true,
    builder: (sheetContext) {
      final sheetColors = sheetContext.colors;
      return Material(
        color: sheetColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        child: Container(
          constraints: BoxConstraints(maxHeight: maxHeight),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: sheetColors.rule),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Text(
                  reader.topicName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: sheetColors.ink,
                  ),
                ),
              ),
              Divider(height: 1, color: sheetColors.ruleFaint),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: reader.topicLessons.length,
                  separatorBuilder: (context, index) =>
                      Divider(height: 1, color: sheetColors.ruleFaint),
                  itemBuilder: (context, index) {
                    final item = reader.topicLessons[index];
                    final isCurrent = item.id == reader.lesson.id;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 4,
                      ),
                      title: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isCurrent ? FontWeight.w700 : FontWeight.w400,
                          color: sheetColors.ink,
                        ),
                      ),
                      trailing: isCurrent
                          ? Text(
                              'reading',
                              style: TextStyle(
                                fontSize: 12,
                                color: sheetColors.inkMuted,
                              ),
                            )
                          : (item.isRead
                              ? Text(
                                  '✓',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: sheetColors.board,
                                  ),
                                )
                              : null),
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        if (onSelectLesson != null) {
                          onSelectLesson(item.id);
                        } else {
                          context.go('/lesson/${item.id}?from=study');
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
