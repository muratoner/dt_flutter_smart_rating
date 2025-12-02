import 'package:flutter/material.dart';
import 'package:dt_flutter_smart_rating/dt_flutter_smart_rating.dart';
import 'package:dt_flutter_smart_rating/src/network/smart_rating_dio_interceptor.dart';
import 'package:dio/dio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    SmartRating().initialize(
      SmartRatingConfig(
        appName: 'Example App',
        storeUrl: 'https://example.com',
        navigatorKey: navigatorKey,
        waitDurationAfterSuccess: const Duration(
          seconds: 5,
        ), // Short for testing
        dialogInterval: const Duration(seconds: 30), // Short for testing
        minimumSuccessfulRequests: 1,
        theme:
            SmartRatingTheme.vibrantGradient(), // Try modernDark() or vibrantGradient() too!
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(navigatorKey: navigatorKey, home: const HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    _dio.interceptors.add(SmartRatingDioInterceptor());
  }

  Future<void> _simulateSuccess() async {
    // Simulate a successful request
    // In a real app, you would make a real request.
    // Here we just manually trigger the interceptor logic or make a dummy request if we had a backend.
    // Since we don't have a backend, let's manually call the report method or mock the interceptor.
    // But to test the interceptor, we should make a request.
    // Let's make a request to a public API.
    try {
      await _dio.get('https://mock.httpstatus.io/200');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request Success! Wait 5s...')),
        );
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> _simulateFailure() async {
    try {
      await _dio.get('https://mock.httpstatus.io/500');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request Failed! Timer reset.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Rating Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _simulateSuccess,
              child: const Text('Simulate Network Success'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _simulateFailure,
              child: const Text('Simulate Network Failure'),
            ),
            const SizedBox(height: 20),
            const Text('Press Success, wait 5 seconds. Dialog should appear.'),
            const Text(
              'If you press Failure within 5 seconds, it should NOT appear.',
            ),
          ],
        ),
      ),
    );
  }
}
