import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FirstRunPage extends ConsumerStatefulWidget {
  const FirstRunPage({super.key});

  @override
  ConsumerState<FirstRunPage> createState() => _FirstRunPageState();
}

class _FirstRunPageState extends ConsumerState<FirstRunPage> {
  @override
  Widget build(BuildContext context) => const Scaffold();
}
