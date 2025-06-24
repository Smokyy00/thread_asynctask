import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:isolate';
import 'dart:math';
import 'package:flutter/foundation.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Thread & Async Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ThreadAsyncDemo(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ThreadAsyncDemo extends StatefulWidget {
  @override
  _ThreadAsyncDemoState createState() => _ThreadAsyncDemoState();
}

class _ThreadAsyncDemoState extends State<ThreadAsyncDemo> {
  String _result = 'Hasil akan muncul di sini';
  bool _isLoading = false;
  int _counter = 0;
  Timer? _timer;
  List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    _startAutoCounter();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _addLog(String message) {
    setState(() {
      _logs.insert(0, '${DateTime.now().millisecondsSinceEpoch}: $message');
      if (_logs.length > 10) {
        _logs.removeLast();
      }
    });
  }

  void _startAutoCounter() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _counter++;
        });
      }
    });
  }

  // 1. ASYNC/AWAIT - Simple Async Task
  Future<void> _simpleAsyncTask() async {
    setState(() {
      _isLoading = true;
      _result = 'Memproses...';
    });
    
    _addLog('Memulai Simple Async Task');
    
    try {
      // Simulasi task yang membutuhkan waktu
      await Future.delayed(Duration(seconds: 3));
      
      setState(() {
        _result = 'Simple Async Task Selesai!';
        _isLoading = false;
      });
      
      _addLog('Simple Async Task Berhasil');
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
        _isLoading = false;
      });
      _addLog('Error pada Simple Async Task: $e');
    }
  }

  // 2. HTTP REQUEST SIMULATION
  Future<void> _httpRequestSimulation() async {
    setState(() {
      _isLoading = true;
      _result = 'Mengambil data dari server...';
    });
    
    _addLog('Memulai HTTP Request');
    
    try {
      // Simulasi HTTP request
      await Future.delayed(Duration(seconds: 2));
      
      // Simulasi data response
      List<String> fakeData = [
        'Data User 1',
        'Data User 2', 
        'Data User 3',
        'Data User 4',
        'Data User 5'
      ];
      
      setState(() {
        _result = 'Data diterima:\n${fakeData.join('\n')}';
        _isLoading = false;
      });
      
      _addLog('HTTP Request Berhasil');
    } catch (e) {
      setState(() {
        _result = 'Network Error: $e';
        _isLoading = false;
      });
      _addLog('HTTP Request Gagal: $e');
    }
  }

  // 3. MULTIPLE ASYNC TASKS - Parallel Execution
  Future<void> _multipleAsyncTasks() async {
    setState(() {
      _isLoading = true;
      _result = 'Menjalankan multiple tasks...';
    });
    
    _addLog('Memulai Multiple Async Tasks');
    
    try {
      // Jalankan 3 task secara bersamaan
      List<Future<String>> tasks = [
        _fetchUserData(),
        _fetchProductData(),
        _fetchOrderData(),
      ];
      
      List<String> results = await Future.wait(tasks);
      
      setState(() {
        _result = 'Multiple Tasks Selesai:\n${results.join('\n')}';
        _isLoading = false;
      });
      
      _addLog('Multiple Async Tasks Berhasil');
    } catch (e) {
      setState(() {
        _result = 'Error pada Multiple Tasks: $e';
        _isLoading = false;
      });
      _addLog('Multiple Async Tasks Gagal: $e');
    }
  }

  Future<String> _fetchUserData() async {
    await Future.delayed(Duration(seconds: 2));
    return '✅ User data loaded';
  }

  Future<String> _fetchProductData() async {
    await Future.delayed(Duration(seconds: 1));
    return '✅ Product data loaded';
  }

  Future<String> _fetchOrderData() async {
    await Future.delayed(Duration(seconds: 3));
    return '✅ Order data loaded';
  }

  // 4. COMPUTE (ISOLATE) - Heavy Computation
  Future<void> _heavyComputation() async {
    setState(() {
      _isLoading = true;
      _result = 'Melakukan perhitungan berat...';
    });
    
    _addLog('Memulai Heavy Computation');
    
    try {
      // Menggunakan compute untuk heavy task di isolate terpisah
      int result = await compute(_calculateFibonacci, 40);
      
      setState(() {
        _result = 'Fibonacci(40) = $result';
        _isLoading = false;
      });
      
      _addLog('Heavy Computation Berhasil');
    } catch (e) {
      setState(() {
        _result = 'Error pada Heavy Computation: $e';
        _isLoading = false;
      });
      _addLog('Heavy Computation Gagal: $e');
    }
  }

  // 5. ISOLATE MANUAL - Advanced Threading
  Future<void> _manualIsolate() async {
    setState(() {
      _isLoading = true;
      _result = 'Menjalankan isolate manual...';
    });
    
    _addLog('Memulai Manual Isolate');
    
    try {
      ReceivePort receivePort = ReceivePort();
      
      await Isolate.spawn(_isolateFunction, receivePort.sendPort);
      
      String result = await receivePort.first;
      
      setState(() {
        _result = 'Isolate Result: $result';
        _isLoading = false;
      });
      
      _addLog('Manual Isolate Berhasil');
    } catch (e) {
      setState(() {
        _result = 'Error pada Manual Isolate: $e';
        _isLoading = false;
      });
      _addLog('Manual Isolate Gagal: $e');
    }
  }

  // 6. STREAM - Real-time Data
  void _startStreamDemo() {
    setState(() {
      _result = 'Stream dimulai...';
    });
    
    _addLog('Memulai Stream Demo');
    
    _dataStream().listen(
      (data) {
        setState(() {
          _result = 'Stream Data: $data';
        });
      },
      onDone: () {
        _addLog('Stream Selesai');
      },
      onError: (error) {
        setState(() {
          _result = 'Stream Error: $error';
        });
        _addLog('Stream Error: $error');
      },
    );
  }

  Stream<String> _dataStream() async* {
    for (int i = 1; i <= 5; i++) {
      await Future.delayed(Duration(seconds: 1));
      yield 'Data batch $i dari 5';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thread & Async Demo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Auto Counter (untuk show UI tidak freeze)
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'UI Counter (Proof UI agar tidak freeze)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '$_counter',
                      style: TextStyle(fontSize: 24, color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Result Display
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hasil:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _isLoading
                          ? Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                SizedBox(width: 12),
                                Expanded(child: Text(_result)),
                              ],
                            )
                          : Text(_result),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Buttons
            Text(
              'Pilih Demo:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            
            SizedBox(height: 12),
            
            _buildDemoButton(
              'Simple Async Task',
              _simpleAsyncTask,
              Icons.timer,
              Colors.blue,
            ),
            
            _buildDemoButton(
              'HTTP Request Simulation',
              _httpRequestSimulation,
              Icons.cloud_download,
              Colors.green,
            ),
            
            _buildDemoButton(
              'Multiple Async Tasks',
              _multipleAsyncTasks,
              Icons.layers,
              Colors.orange,
            ),
            
            _buildDemoButton(
              'Heavy Computation (Isolate)',
              _heavyComputation,
              Icons.memory,
              Colors.red,
            ),
            
            _buildDemoButton(
              'Manual Isolate',
              _manualIsolate,
              Icons.settings,
              Colors.purple,
            ),
            
            _buildDemoButton(
              'Stream Demo',
              _startStreamDemo,
              Icons.stream,
              Colors.teal,
            ),
            
            SizedBox(height: 20),
            
            // Logs
            Text(
              'Logs:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            
            SizedBox(height: 8),
            
            Container(
              height: 200,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      _logs[index],
                      style: TextStyle(
                        color: Colors.green,
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoButton(String title, VoidCallback onPressed, IconData icon, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          title,
          style: TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

// Function untuk compute (isolate)
int _calculateFibonacci(int n) {
  if (n <= 1) return n;
  return _calculateFibonacci(n - 1) + _calculateFibonacci(n - 2);
}

// Function untuk manual isolate
void _isolateFunction(SendPort sendPort) {
  // Simulasi heavy computation di isolate
  String result = '';
  for (int i = 0; i < 1000000; i++) {
    result = 'Processed $i items';
  }
  
  sendPort.send('Isolate completed: $result');
}