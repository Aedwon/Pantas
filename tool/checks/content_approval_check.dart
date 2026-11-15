import '../content/content_gate.dart';
import 'check.dart';

class ContentApprovalCheck extends Check {
  const ContentApprovalCheck();
  @override
  String get name => 'content-approval';
  @override
  String get origin => 'Bite-sized lessons B6';
  @override
  List<Violation> run(String root) => [
        for (final finding in runContentGate('$root/content'))
          Violation(finding.id, finding.reason),
      ];
}
