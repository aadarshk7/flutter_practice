import 'dart:async';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class IsolatesExample extends StatefulWidget {
  const IsolatesExample({super.key});

  @override
  State<IsolatesExample> createState() => _IsolatesExampleState();
}

class _IsolatesExampleState extends State<IsolatesExample> {
  // Results and status trackers
  String _basicResult = '';
  String _computeResult = '';
  String _customResult = '';
  String _progressResult = '';
  String _multipleResult = '';

  // Progress indicators
  bool _isBasicLoading = false;
  bool _isComputeLoading = false;
  bool _isCustomLoading = false;
  bool _isMultipleLoading = false;
  double _progressValue = 0.0;

  // For demonstrating performance differences
  final Stopwatch _stopwatch = Stopwatch();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Isolates'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(
                'What are Isolates?',
                'Isolates are Flutter\'s way of achieving concurrency. Each isolate has its own memory heap, '
                    'ensuring no shared state between isolates. This helps avoid common threading issues like race conditions.'),

            const SizedBox(height: 20),

            // Basic Isolate Example
            _buildExampleSection(
              title: 'Basic Isolate',
              description: 'Simple isolate creation and communication using ports.',
              buttonText: 'Run Basic Isolate',
              isLoading: _isBasicLoading,
              result: _basicResult,
              onPressed: _runBasicIsolate,
            ),

            // Compute Example
            _buildExampleSection(
              title: 'Compute Function',
              description: 'Using Flutter\'s compute() function for simpler isolate usage.',
              buttonText: 'Run Compute',
              isLoading: _isComputeLoading,
              result: _computeResult,
              onPressed: _runCompute,
            ),

            // Custom Isolate with Progress
            _buildExampleSection(
              title: 'Isolate with Progress',
              description: 'Tracking progress of a long-running isolate task.',
              buttonText: 'Run with Progress',
              isLoading: _isCustomLoading,
              result: _progressResult,
              onPressed: _runIsolateWithProgress,
              progressIndicator: LinearProgressIndicator(value: _progressValue),
            ),

            // Multiple Isolates
            _buildExampleSection(
              title: 'Multiple Isolates',
              description: 'Running several isolates simultaneously for parallel work.',
              buttonText: 'Run Multiple Isolates',
              isLoading: _isMultipleLoading,
              result: _multipleResult,
              onPressed: _runMultipleIsolates,
            ),

            // Performance Comparison
            _buildPerformanceComparison(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Card(
      elevation: 4,
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(content),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleSection({
    required String title,
    required String description,
    required String buttonText,
    required bool isLoading,
    required String result,
    required VoidCallback onPressed,
    Widget? progressIndicator,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(description),
            const SizedBox(height: 16),
            if (progressIndicator != null) ...[
              progressIndicator,
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                ElevatedButton(
                  onPressed: isLoading ? null : onPressed,
                  child: Text(buttonText),
                ),
                if (isLoading) ...[
                  const SizedBox(width: 16),
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                ],
              ],
            ),
            if (result.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                width: double.infinity,
                child: Text(result),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Widget _buildPerformanceComparison() {
  //   return Card(
  //     margin: const EdgeInsets.symmetric(vertical: 8),
  //     color: Colors.amber.shade50,
  //     child: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           const Text(
  //             'Performance Comparison',
  //             style: TextStyle(
  //               fontSize: 18,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //           const SizedBox(height: 8),
  //           const Text(
  //             'Compare heavy computation with and without isolates:',
  //           ),
  //           const SizedBox(height: 16),
  //           Row(
  //             children: [
  //               Expanded(
  //                 child: ElevatedButton(
  //                   onPressed: _runOnMainThread,
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: Colors.orange,
  //                   ),
  //                   child: const Text('Run on Main Thread'),
  //                 ),
  //               ),
  //               const SizedBox(width: 16),
  //               Expanded(
  //                 child: ElevatedButton(
  //                   onPressed: _runOnIsolate,
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: Colors.green,
  //                   ),
  //                   child: const Text('Run on Isolate'),
  //                 ),
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 16),
  //           Text(_customResult),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildPerformanceComparison() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Comparison',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Compare heavy computation with and without isolates:',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _runOnMainThread,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text('Run on Main Thread'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _runOnIsolate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Run on Isolate'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Add a counter to demonstrate UI responsiveness
            _buildResponsivenessIndicator(),
            const SizedBox(height: 16),
            Text(_customResult),
          ],
        ),
      ),
    );
  }

// Add this method to your class
  Widget _buildResponsivenessIndicator() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          const Text('Counter: '),
          AnimatedCounter(), // Create this widget below
        ],
      ),
    );
  }

  // Basic isolate example
  Future<void> _runBasicIsolate() async {
    setState(() {
      _isBasicLoading = true;
      _basicResult = 'Starting isolate...';
    });

    try {
      final receivePort = ReceivePort();
      await Isolate.spawn(_basicIsolateTask, receivePort.sendPort);

      // Get the result
      final result = await receivePort.first as String;

      setState(() {
        _basicResult = 'Result from isolate: $result';
        _isBasicLoading = false;
      });
    } catch (e) {
      setState(() {
        _basicResult = 'Error: $e';
        _isBasicLoading = false;
      });
    }
  }

  // The function that runs in the isolate
  static void _basicIsolateTask(SendPort sendPort) {
    // Simulate work
    int sum = 0;
    for (int i = 0; i < 10000000; i++) {
      sum += i;
    }

    // Send the result back
    sendPort.send('Computed sum: $sum');
  }

  // Flutter compute example
  Future<void> _runCompute() async {
    setState(() {
      _isComputeLoading = true;
      _computeResult = 'Starting compute...';
    });

    _stopwatch.reset();
    _stopwatch.start();

    try {
      final result = await compute(_computeTask, 10000000);

      _stopwatch.stop();

      setState(() {
        _computeResult = 'Result: $result\nTime: ${_stopwatch.elapsedMilliseconds}ms';
        _isComputeLoading = false;
      });
    } catch (e) {
      setState(() {
        _computeResult = 'Error: $e';
        _isComputeLoading = false;
      });
    }
  }

  // The function to be run using compute
  static int _computeTask(int iterations) {
    int sum = 0;
    for (int i = 0; i < iterations; i++) {
      sum += i;
    }
    return sum;
  }

  // Isolate with progress updates
  Future<void> _runIsolateWithProgress() async {
    setState(() {
      _isCustomLoading = true;
      _progressResult = 'Starting isolate with progress...';
      _progressValue = 0.0;
    });

    final receivePort = ReceivePort();
    late Isolate isolate;

    try {
      isolate = await Isolate.spawn(_isolateWithProgressTask, receivePort.sendPort);

      // Listen for progress updates and the final result
      await for (dynamic message in receivePort) {
        if (message is double) {
          // This is a progress update
          setState(() {
            _progressValue = message;
            _progressResult = 'Progress: ${(message * 100).toStringAsFixed(1)}%';
          });
        } else if (message is String) {
          // This is the final result
          setState(() {
            _progressResult = 'Completed: $message';
            _isCustomLoading = false;
          });
          break;
        }
      }
    } catch (e) {
      setState(() {
        _progressResult = 'Error: $e';
        _isCustomLoading = false;
      });
    } finally {
      receivePort.close();
    }
  }

  static void _isolateWithProgressTask(SendPort sendPort) {
    final total = 20;
    var result = 0;

    // Simulate work with progress updates
    for (int i = 0; i <= total; i++) {
      // Simulate heavy computation
      final computation = _performHeavyComputation(500000);
      result += computation;

      // Send progress update
      final progress = i / total;
      sendPort.send(progress);

      // Small delay to make progress visible
      sleep(const Duration(milliseconds: 200));
    }

    // Send final result
    sendPort.send('Final result: $result');
  }

  static int _performHeavyComputation(int iterations) {
    int result = 0;
    for (int i = 0; i < iterations; i++) {
      result += sqrt(i * Random().nextDouble()).round();
    }
    return result;
  }

  // Multiple isolates example
  Future<void> _runMultipleIsolates() async {
    setState(() {
      _isMultipleLoading = true;
      _multipleResult = 'Starting multiple isolates...';
    });

    try {
      final results = await Future.wait([
        compute(_computeFibonacci, 42),
        compute(_computePrimes, 100000),
        compute(_computeFactorial, 20),
      ]);

      setState(() {
        _multipleResult = 'Fibonacci: ${results[0]}\n'
            'Primes count: ${results[1]}\n'
            'Factorial: ${results[2]}';
        _isMultipleLoading = false;
      });
    } catch (e) {
      setState(() {
        _multipleResult = 'Error: $e';
        _isMultipleLoading = false;
      });
    }
  }

  static int _computeFibonacci(int n) {
    if (n <= 1) return n;
    return _computeFibonacci(n - 1) + _computeFibonacci(n - 2);
  }

  static int _computePrimes(int max) {
    int count = 0;
    for (int i = 2; i <= max; i++) {
      bool isPrime = true;
      for (int j = 2; j <= sqrt(i); j++) {
        if (i % j == 0) {
          isPrime = false;
          break;
        }
      }
      if (isPrime) count++;
    }
    return count;
  }

  static BigInt _computeFactorial(int n) {
    BigInt result = BigInt.one;
    for (int i = 2; i <= n; i++) {
      result *= BigInt.from(i);
    }
    return result;
  }

  // Performance comparison methods
  Future<void> _runOnMainThread() async {
    setState(() {
      _isCustomLoading = true;
      _customResult = 'Running on main thread...';
    });

    _stopwatch.reset();
    _stopwatch.start();

    // Make this more intensive to clearly show UI blocking
    int result = 0;
    for (int i = 0; i < 50000000; i++) {
      // Increased iterations
      result += i;
      // Add some more work to make each iteration heavier
      if (i % 1000 == 0) {
        result = sqrt(result).round();
      }
    }

    _stopwatch.stop();

    setState(() {
      _customResult = 'Main thread result: $result\n'
          'Time: ${_stopwatch.elapsedMilliseconds}ms\n'
          'UI was blocked during computation!';
      _isCustomLoading = false;
    });
  }

  Future<void> _runOnIsolate() async {
    setState(() {
      _isCustomLoading = true;
      _customResult = 'Running on isolate...';
    });

    _stopwatch.reset();
    _stopwatch.start();

    // Run the same computation on isolate with same parameters
    final result = await compute(_heavierComputeTask, 50000000);

    _stopwatch.stop();

    setState(() {
      _customResult = 'Isolate result: $result\n'
          'Time: ${_stopwatch.elapsedMilliseconds}ms\n'
          'UI remained responsive during computation!';
      _isCustomLoading = false;
    });
  }

// Add this method
  static int _heavierComputeTask(int iterations) {
    int sum = 0;
    for (int i = 0; i < iterations; i++) {
      sum += i;
      if (i % 1000 == 0) {
        sum = sqrt(sum).round();
      }
    }
    return sum;
  }

  static void sleep(Duration duration) {
    final now = DateTime.now();
    var target = now.add(duration);
    while (DateTime.now().compareTo(target) < 0) {
      // Busy wait to simulate work
    }
  }
}

// Create a new StatefulWidget
class AnimatedCounter extends StatefulWidget {
  const AnimatedCounter({super.key});

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter> {
  int _counter = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Update counter every 100ms to show UI responsiveness
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _counter++;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '$_counter',
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }
}
