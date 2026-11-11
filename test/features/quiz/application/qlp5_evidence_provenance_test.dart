import 'package:flutter_test/flutter_test.dart';

import '../../../../integration_test/release/support/qlp5_performance_collector.dart';

void main() {
  test(
      'provenance schema is fixed to non-secret release and device descriptors',
      () {
    const provenance = Qlp5EvidenceProvenance(
      sourceSha: '0123456789012345678901234567890123456789',
      contentSeedVersion: '588610f4184ff762',
      payloadSha256:
          '0ef89a64f2d2f63854b3d22048a7d992d5c04fb03df4fec2e7f4e898e6d083dc',
      manifestSha256:
          '51bc0a766558879e540475ab972f03df7e3077241bab8f688c1b50ece5874f23',
      signatureSha256:
          'e0853df259529031344f14d5a5fe6628e1b92c367a96c584894058fe13199f31',
      deviceModel: 'Example Model',
      androidVersion: '16',
      memoryClassMb: 4096,
      refreshRateHz: 60,
      buildMode: 'profile',
    );

    expect(provenance.toJson().keys, {
      'source_sha',
      'content_seed_version',
      'payload_sha256',
      'manifest_sha256',
      'signature_sha256',
      'device_model',
      'android_version',
      'memory_class_mb',
      'refresh_rate_hz',
      'build_mode',
    });
    final encoded = provenance.toJson().toString().toLowerCase();
    for (final forbidden in [
      'serial',
      'user_id',
      'question',
      'answer',
      'bootstrap',
      'private_key',
    ]) {
      expect(encoded, isNot(contains(forbidden)));
    }
  });
}
