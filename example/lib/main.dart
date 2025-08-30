import 'dart:async';
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
  late final Timer timer;
  int progress = 0;
  DateTime now = DateTime.now();

  /// Next random number
  double _nextNumber() => rdm.nextDouble() * rdm.nextInt(1000);

  /// Number string
  String get numberString => number.toStringAsFixed(2);

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(milliseconds: 1000), (timer) {
      setState(() {
        if (timer.tick.isOdd) progress = (progress + 1) % 101;
        now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

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
            const SizedBox(height: 20),
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
            const SizedBox(height: 50),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF21CE99),
                borderRadius: BorderRadius.all(Radius.circular(2)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Ticker(
                text: '$progress%',
                duration: const Duration(milliseconds: 1000),
                style: const TextStyle(fontSize: 60, color: Colors.white),
              ),
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: const BoxDecoration(
                    color: Color(0xFF21CE99),
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                  ),
                  child: Ticker(
                    text: now.hour.toString().padLeft(2, '0'),
                    style: const TextStyle(fontSize: 60, color: Colors.white),
                  ),
                ),
                Text(':', style: const TextStyle(fontSize: 60)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: const BoxDecoration(
                    color: Color(0xFF21CE99),
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                  ),
                  child: Ticker(
                    text: now.minute.toString().padLeft(2, '0'),
                    style: const TextStyle(fontSize: 60, color: Colors.white),
                  ),
                ),
                Text(':', style: const TextStyle(fontSize: 60)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: const BoxDecoration(
                    color: Color(0xFF21CE99),
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                  ),
                  child: Ticker(
                    text: now.second.toString().padLeft(2, '0'),
                    style: const TextStyle(fontSize: 60, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
