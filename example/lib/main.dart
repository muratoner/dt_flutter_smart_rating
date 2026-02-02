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
    // Initialize SmartRating with a configuration suitable for testing
    SmartRating().initialize(
      SmartRatingConfig(
        appName: 'Example App',
        storeUrl: 'https://example.com',
        navigatorKey: navigatorKey,
        waitDurationAfterSuccess: const Duration(seconds: 2),
        // Short interval to easier testing of multiple dialogs
        dialogInterval: const Duration(seconds: 5),
        minimumSuccessfulRequests: 3,
        // Disable auto trigger to demonstrate manual controls primarily,
        // or keep it enabled but show how manual overrides work.
        // Let's keep it true but set a higher threshold so we can test manual first.
        autoTrigger: true,
        theme: SmartRatingTheme.vibrantGradient(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(),
    );
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

  // --- Simulation Methods ---

  Future<void> _simulateSuccess() async {
    try {
      // Mocking a successful request
      await _dio.get('https://mock.httpstatus.io/200');
      _showSnackbar('Request Success! (+1 Success)');
    } catch (e) {
      debugPrint('Error: $e');
    }
    setState(() {}); // Update UI to show new stats
  }

  Future<void> _simulateFailure() async {
    try {
      // Mocking a failed request
      await _dio.get('https://mock.httpstatus.io/500');
    } catch (e) {
      _showSnackbar('Request Failed! (+1 Failure, Success Reset)');
    }
    setState(() {}); // Update UI to show new stats
  }

  void _resetStats() {
    SmartRating().resetCounters();
    _showSnackbar('All counters reset!');
    setState(() {});
  }

  // --- Smart Trigger Methods ---

  Future<void> _showOnlyIfNoFailures() async {
    await SmartRating().showRatingDialog(onlyIfNoFailures: true);
    // Dialog handles its own display logic. If it doesn't show, it logs to console.
    // We can't easily know if it showed or not without complex logic,
    // but the user will see the dialog if conditions met.
  }

  Future<void> _showIfMinSuccessReached() async {
    await SmartRating().showRatingDialog(requireMinimumSuccess: true);
  }

  Future<void> _showWithMaxFailures(int max) async {
    await SmartRating().showRatingDialog(maximumAllowedFailures: max);
  }

  Future<void> _forceShow() async {
    await SmartRating().showRatingDialog();
  }

  Future<void> _showWithCustomFeedback() async {
    await SmartRating().showRatingDialog(
      onSubmitFeedback: (feedback) async {
        debugPrint('Custom feedback received: $feedback');
        // Simulate API call
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return;
        Navigator.of(context).pop(); // Close the dialog
        if (SmartRating().config != null) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => ThankYouDialog(config: SmartRating().config!),
          );
        }
      },
    );
  }

  void _showSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get current stats
    final successCount = SmartRating().successCount;
    final failureCount = SmartRating().failureCount;
    final hasFailures = SmartRating().hasFailures;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Rating v0.0.2 Demo'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Stats Card ---
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      '📊 Network Stats',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          'Success',
                          successCount.toString(),
                          Colors.green,
                        ),
                        _buildStatItem(
                          'Failures',
                          failureCount.toString(),
                          Colors.red,
                        ),
                        _buildStatItem(
                          'Issues?',
                          hasFailures ? 'YES' : 'NO',
                          hasFailures ? Colors.orange : Colors.grey,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: _resetStats,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset Session / Counters'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- Simulation Controls ---
            const Text(
              '1. Network Simulation',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _simulateSuccess,
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Success (+1)'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _simulateFailure,
                    icon: const Icon(Icons.error),
                    label: const Text('Failure (+1)'),
                    style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // --- Smart Trigger Controls ---
            const Text(
              '2. Manual Triggers (Smart Controls)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.verified_user),
                  label: const Text('Only If No Failures'),
                  onPressed: _showOnlyIfNoFailures,
                  tooltip: 'Shows dialog ONLY if failure count is 0',
                ),
                ActionChip(
                  avatar: const Icon(Icons.trending_up),
                  label: const Text('Require Min Success (3)'),
                  onPressed: _showIfMinSuccessReached,
                  tooltip: 'Shows dialog if success count >= 3',
                ),
                ActionChip(
                  avatar: const Icon(Icons.warning_amber),
                  label: const Text('Max 2 Failures'),
                  onPressed: () => _showWithMaxFailures(2),
                  tooltip: 'Shows dialog if failures <= 2',
                ),
                ActionChip(
                  avatar: const Icon(Icons.open_in_new),
                  label: const Text('Force Show'),
                  onPressed: _forceShow,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                ),
                ActionChip(
                  avatar: const Icon(Icons.comment),
                  label: const Text('With Custom Feedback'),
                  onPressed: _showWithCustomFeedback,
                  tooltip: 'Shows dialog with custom feedback handler',
                ),
              ],
            ),

            const SizedBox(height: 20),
            // --- Helper Text ---
            const Card(
              color: Color(0xFFFFF3E0),
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  '💡 Tip: Watch the debug console to see why a dialog was skipped if it doesn\'t appear.',
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
