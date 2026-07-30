import 'package:pantas/features/legal/domain/legal_contact.dart';
import 'package:pantas/features/legal/domain/legal_document.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final legalContactProvider = Provider<LegalContact>(
  (ref) => defaultLegalContact,
);

final legalDocumentProvider = Provider.family<LegalDocument?, String>(
  (ref, id) => legalDocumentFallbacks[id],
);
