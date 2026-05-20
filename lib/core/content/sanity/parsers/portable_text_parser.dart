import 'dart:convert';

import 'package:cse_cet_reviewer/core/content/sanity/parser_exceptions.dart';

String portableTextToJson(
  Object? value, {
  String doctype = 'portableText',
  String field = 'value',
}) {
  if (value is! List) {
    throw ParseException(
      doctype: doctype,
      field: field,
      message: 'expected a list of Portable Text blocks',
    );
  }
  for (var blockIndex = 0; blockIndex < value.length; blockIndex++) {
    final block = value[blockIndex];
    if (block is! Map<String, Object?>) {
      throw ParseException(
        doctype: doctype,
        field: '$field[$blockIndex]',
        message: 'expected block object',
      );
    }
    final type = block['_type'];
    if (type is! String || type.isEmpty) {
      throw ParseException(
        doctype: doctype,
        field: '$field[$blockIndex]._type',
        message: 'expected non-empty string',
      );
    }
    if (type == 'block') {
      _validateTextBlock(block, doctype, '$field[$blockIndex]');
    }
  }
  return jsonEncode(value);
}

void _validateTextBlock(
  Map<String, Object?> block,
  String doctype,
  String path,
) {
  final children = block['children'];
  if (children is! List) {
    throw ParseException(
      doctype: doctype,
      field: '$path.children',
      message: 'expected list',
    );
  }
  for (var childIndex = 0; childIndex < children.length; childIndex++) {
    final child = children[childIndex];
    if (child is! Map<String, Object?>) {
      throw ParseException(
        doctype: doctype,
        field: '$path.children[$childIndex]',
        message: 'expected child object',
      );
    }
    final type = child['_type'];
    if (type is! String || type.isEmpty) {
      throw ParseException(
        doctype: doctype,
        field: '$path.children[$childIndex]._type',
        message: 'expected non-empty string',
      );
    }
    if (type == 'span' && child['text'] is! String) {
      throw ParseException(
        doctype: doctype,
        field: '$path.children[$childIndex].text',
        message: 'expected string',
      );
    }
  }
}
