import 'package:flutter/material.dart';

class PaywallPage extends StatelessWidget {
  const PaywallPage({this.returnTo, super.key});

  final String? returnTo;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: null,
      body: Center(child: Text('Try Pro')),
    );
  }
}
