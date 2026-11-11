import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';

bool isValidPublicId(String digits) {
  if (!RegExp(r'^[1-9][0-9]{8}$').hasMatch(digits)) return false;
  var sum = 0;
  for (var i = 0; i < digits.length; i++) {
    final digit = int.parse(digits[i]) * (i.isOdd ? 2 : 1);
    sum += digit > 9 ? digit - 9 : digit;
  }
  return sum % 10 == 0;
}

enum PublicIdStatus { notSignedIn, notReady, ready }

@immutable
class PublicIdState {
  const PublicIdState.notSignedIn()
      : status = PublicIdStatus.notSignedIn,
        digits = null;
  const PublicIdState.notReady()
      : status = PublicIdStatus.notReady,
        digits = null;
  const PublicIdState.ready(this.digits) : status = PublicIdStatus.ready;

  final PublicIdStatus status;
  final String? digits;

  @override
  bool operator ==(Object other) =>
      other is PublicIdState &&
      other.status == status &&
      other.digits == digits;
  @override
  int get hashCode => Object.hash(status, digits);
}

typedef PublicIdReader = Stream<String?> Function(String uid);

final publicIdReaderProvider = Provider<PublicIdReader>((ref) {
  return (uid) {
    if (Firebase.apps.isEmpty) return Stream.value(null);
    return FirebaseFirestore.instance.doc('users/$uid').snapshots().map(
      (snapshot) {
        final id = snapshot.data()?['publicId'];
        return id is String ? id : null;
      },
    );
  };
});

final publicIdProvider = StreamProvider<PublicIdState>((ref) async* {
  final state = ref.watch(authStateProvider).value;
  if (state is! SignedInAuthState) {
    yield const PublicIdState.notSignedIn();
    return;
  }
  yield const PublicIdState.notReady();
  final reader = ref.watch(publicIdReaderProvider);
  await for (final digits in reader(state.user.uid)) {
    yield digits != null && isValidPublicId(digits)
        ? PublicIdState.ready(digits)
        : const PublicIdState.notReady();
  }
});
