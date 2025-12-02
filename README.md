# Smart Rating for Flutter

A smart rating dialog package for Flutter that prompts users to rate the app based on their usage experience and network success.

## Features

- **Smart Triggering**: Shows the rating dialog only after a period of successful network activity (default 10 minutes).
- **Network Monitoring**: Automatically monitors network traffic using a Dio interceptor (or manual reporting).
- **Conditional Logic**:
    - **4-5 Stars**: Redirects the user to the store.
    - **1-3 Stars**: Asks for feedback within the app.
- **Persistence**: Remembers when the dialog was last shown and respects a cooldown period (default 30 days).
- **Localization**: Fully customizable text strings.

## Installation

Add `dt_flutter_smart_rating` to your `pubspec.yaml`:

```yaml
dependencies:
  dt_flutter_smart_rating:
    path: ../ # or git url
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

#### Using Dio

Add the `SmartRatingDioInterceptor` to your Dio instance:

```dart
final dio = Dio();
dio.interceptors.add(SmartRatingDioInterceptor());
```

#### Manual Reporting

If you are not using Dio, you can manually report success or failure:

```dart
// On success
SmartRating().reportNetworkSuccess();

// On failure
SmartRating().reportNetworkFailure();
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
| `waitDurationAfterSuccess` | `Duration` | 10 mins | Time to wait after success before showing. |
| `localizations` | `SmartRatingLocalizations` | Default | Custom text strings. |

## License

MIT
