import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pantas/features/paywall/domain/products.dart';

Map<String, DateTime> passesFromLedger(Iterable<Map<String, dynamic>> rows) {
  final passes = <String, DateTime>{};
  for (final row in rows) {
    final productId = row['product'];
    final examId = row['examId'];
    final end = row['endsAt'];
    if (row['state'] != 'active' ||
        productId is! String ||
        examId is! String ||
        end is! int) {
      continue;
    }
    final product = productForId(productId);
    if (product?.kind != ProductKind.pass || product?.examId != examId) {
      continue;
    }
    final date = DateTime.fromMillisecondsSinceEpoch(end, isUtc: true);
    if (passes[examId] == null || date.isAfter(passes[examId]!)) {
      passes[examId] = date;
    }
  }
  return Map.unmodifiable(passes);
}

abstract interface class PassLedgerSource {
  Future<Map<String, DateTime>> read(String uid);
  Stream<Map<String, DateTime>> watch(String uid);
}

class FirestorePassLedgerSource implements PassLedgerSource {
  const FirestorePassLedgerSource();

  @override
  Future<Map<String, DateTime>> read(String uid) async {
    if (Firebase.apps.isEmpty) return const {};
    final snapshot = await FirebaseFirestore.instance
        .collection('users/$uid/passes')
        .get(const GetOptions(source: Source.server));
    return passesFromLedger(snapshot.docs.map((doc) => doc.data()));
  }

  @override
  Stream<Map<String, DateTime>> watch(String uid) {
    if (Firebase.apps.isEmpty) return Stream.value(const {});
    return FirebaseFirestore.instance
        .collection('users/$uid/passes')
        .snapshots(includeMetadataChanges: true)
        .where((snapshot) => !snapshot.metadata.isFromCache)
        .map(
          (snapshot) =>
              passesFromLedger(snapshot.docs.map((doc) => doc.data())),
        );
  }
}
