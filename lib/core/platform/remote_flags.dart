import 'package:meta/meta.dart';

@immutable
class RemoteFlags {
  const RemoteFlags({
    required this.minimumSupportedBuild,
    required this.serviceMessage,
  });

  /// Builds below this are blocked. Defaults to 0, which blocks nothing.
  final int minimumSupportedBuild;

  /// One line shown on Home when set. Null when there is nothing to say.
  final String? serviceMessage;

  static const fallback = RemoteFlags(
    minimumSupportedBuild: 0,
    serviceMessage: null,
  );

  static RemoteFlags parse(int? minimum, String? message) {
    final cleanMessage =
        (message == null || message.trim().isEmpty) ? null : message;
    return RemoteFlags(
      minimumSupportedBuild: minimum ?? 0,
      serviceMessage: cleanMessage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RemoteFlags &&
          runtimeType == other.runtimeType &&
          minimumSupportedBuild == other.minimumSupportedBuild &&
          serviceMessage == other.serviceMessage;

  @override
  int get hashCode => minimumSupportedBuild.hashCode ^ serviceMessage.hashCode;
}
