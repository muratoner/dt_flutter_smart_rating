# Smart Rating for Flutter

A smart rating dialog package for Flutter that prompts users to rate the app based on their usage experience and network success.

📖 **[Türkçe Dokümantasyon için tıklayın](README_TR.md)**

## Features

- **Smart Triggering**: Shows the rating dialog only after a period of successful network activity (default 5 seconds).
- **Network Monitoring**: Automatically monitors network traffic using a Dio interceptor (or manual reporting).
- **Conditional Logic**:
    - **4-5 Stars**: Redirects the user to the store.
    - **1-3 Stars**: Asks for feedback within the app.
- **Persistence**: Remembers when the dialog was last shown and respects a cooldown period (default 30 days).
- **Localization**: Fully customizable text strings.
- **Failure Tracking**: Track network failures and show rating dialog only when conditions are met.

## Installation

Add `dt_flutter_smart_rating` to your `pubspec.yaml`:

### Latest Version (Recommended)
```yaml
dependencies:
  dt_flutter_smart_rating:
    git:
      url: https://github.com/muratoner/dt_flutter_smart_rating.git
      ref: main  # Always get the latest version
```

### Specific Version (Stable)
```yaml
dependencies:
  dt_flutter_smart_rating:
    git:
      url: https://github.com/muratoner/dt_flutter_smart_rating.git
      ref: v0.0.2  # Pin to a specific version
```

Then run:
```bash
flutter pub get
```

## Usage

### 1. Initialize

Initialize the `SmartRating` singleton in your `main.dart` or `App` widget. You need to provide a `navigatorKey` to allow the dialog to be shown without a direct context reference from the network layer.

```dart
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    SmartRating().initialize(
      SmartRatingConfig(
        appName: 'My App',
        storeUrl: 'https://apps.apple.com/app/id...', // or Play Store URL
        navigatorKey: navigatorKey,
        appIcon: Image.asset('assets/icon.png', width: 60, height: 60),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: const HomePage(),
    );
  }
}
```

### 2. Monitor Network

#### Using Dio (Optional)

If your project uses Dio, first add it to your app's `pubspec.yaml`:

```yaml
dependencies:
  dio: ^5.4.1
```

Then import the interceptor separately and add it to your Dio instance:

```dart
import 'package:dt_flutter_smart_rating/src/network/smart_rating_dio_interceptor.dart';

final dio = Dio();
dio.interceptors.add(SmartRatingDioInterceptor());
```

> **Note**: The Dio interceptor is not exported from the main package to avoid compilation errors when Dio is not installed. In production, copy `lib/src/network/smart_rating_dio_interceptor.dart` to your own project, or import it directly (which may trigger a lint warning about implementation imports).

#### Manual Reporting (For non-Dio projects)

If you are not using Dio, you can manually report success or failure:

```dart
// On success
SmartRating().reportNetworkSuccess();

// On failure
SmartRating().reportNetworkFailure();
```

### Manual Mode

If you prefer to control when the dialog is shown (e.g., after a specific user action), you can disable automatic triggering:

```dart
SmartRatingConfig(
  // ...
  autoTrigger: false, // Disable automatic showing
)
```

Then show the dialog manually whenever you want:

```dart
// Basic usage - Show dialog at any time (still respects dialogInterval)
await SmartRating().showRatingDialog();

// Example: Show after user completes an action
void onUserCompletedOrder() {
  // ... your logic
  SmartRating().showRatingDialog();
}
```

> **Note**: Even in manual mode, the dialog respects `dialogInterval` to avoid showing too frequently.

### Smart Controls for Manual Triggering

When manually showing the dialog, you can use smart controls to ensure optimal user experience:

```dart
// Only show if there have been NO network failures
await SmartRating().showRatingDialog(
  onlyIfNoFailures: true,
);

// Only show if minimum success count has been reached
await SmartRating().showRatingDialog(
  requireMinimumSuccess: true,
);

// Allow up to 2 failures
await SmartRating().showRatingDialog(
  maximumAllowedFailures: 2,
);

// Combine multiple conditions
await SmartRating().showRatingDialog(
  requireMinimumSuccess: true,
  maximumAllowedFailures: 1,
);
```

**Use Cases:**
- **Critical flows** (payments, registrations): Use `onlyIfNoFailures: true`
- **Quality assurance**: Use `requireMinimumSuccess: true`
- **Tolerant flows**: Use `maximumAllowedFailures: N`

### Failure Tracking & Session Management

Monitor network quality and reset counters when needed:

```dart
// Check current stats
int failures = SmartRating().failureCount;
int successes = SmartRating().successCount;
bool anyFailures = SmartRating().hasFailures;

debugPrint('Network stats: $successes successes, $failures failures');

// Reset counters for new session/flow
void startNewUserSession() {
  SmartRating().resetCounters();
}

// Example: Reset after user logs in
void onUserLogin() {
  SmartRating().resetCounters(); // Fresh start for new session
}
```

## Configuration

`SmartRatingConfig` allows you to customize the behavior:

| Property | Type | Default | Description |
|---|---|---|---|
| `appName` | `String` | Required | Name of your app. |
| `storeUrl` | `String` | Required | URL to redirect for rating. |
| `navigatorKey` | `GlobalKey<NavigatorState>?` | `null` | Key to show dialog without context. |
| `appIcon` | `Widget?` | `null` | Icon to show in the dialog. |
| `dialogInterval` | `Duration` | 30 days | Minimum time between showing the dialog. |
| `waitDurationAfterSuccess` | `Duration` | 5 seconds | Time to wait after reaching minimum success count. |
| `minimumSuccessfulRequests` | `int` | 20 | Number of consecutive successful requests needed. Any failure resets this counter. |
| `autoTrigger` | `bool` | `true` | Whether to automatically show dialog. Set to `false` for manual control. |
| `localizations` | `SmartRatingLocalizations` | Default | Custom text strings. |
| `theme` | `SmartRatingTheme` | Default | Visual theme customization. |

## Theming

The package includes a powerful theming system to customize the dialog's appearance.

### Pre-built Themes

```dart
// Modern light theme with gradient
SmartRatingConfig(
  // ...
  theme: SmartRatingTheme.modernLight(),
)

// Dark theme with vibrant accents
SmartRatingConfig(
  // ...
  theme: SmartRatingTheme.modernDark(),
)

// Vibrant gradient theme
SmartRatingConfig(
  // ...
  theme: SmartRatingTheme.vibrantGradient(),
)
```

### Custom Theme

You can fully customize every aspect of the dialog:

```dart
SmartRatingConfig(
  // ...
  theme: SmartRatingTheme(
    backgroundColor: Colors.white,
    borderRadius: 28.0,
    backgroundGradient: [Color(0xFFF8F9FA), Color(0xFFFFFFFF)],
    shadows: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 32.0,
        offset: Offset(0, 8),
      ),
    ],
    titleStyle: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Color(0xFF1A1A1A),
    ),
    starColor: Color(0xFFFFB800),
    starSize: 52.0,
    primaryButtonColor: Color(0xFF6366F1),
    // ... and many more customization options
  ),
)
```

## License

MIT
