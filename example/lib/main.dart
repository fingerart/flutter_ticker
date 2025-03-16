import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_ticker/flutter_ticker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final rdm = Random();
  late double number = _nextNumber();

  /// 随机下一个数字
  double _nextNumber() => rdm.nextDouble() * rdm.nextInt(1000);

  /// 字符串数字
  String get numberString => number.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Ticker example')),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              color: const Color(0xFF21CE99),
              width: double.infinity,
              child: Ticker(
                text: '\$$numberString',
                style: const TextStyle(fontSize: 50, color: Colors.white),
              ),
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 5,
              children: [
                FilledButton(
                  onPressed: () => setState(() => number += 1),
                  child: const Text('+1'),
                ),
                FilledButton(
                  onPressed: () => setState(() => number = 0),
                  child: const Text('0'),
                ),
                FilledButton(
                  onPressed: () => setState(() => number -= 1),
                  child: const Text('-1'),
                ),
                FilledButton(
                  onPressed: () => setState(() => number = _nextNumber()),
                  child: const Text('Random'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
