<p align="center">
  <img src="assets/smart_rating_icon.png" width="120" height="120" alt="Smart Rating Logo">
</p>

# Flutter için Smart Rating

Flutter uygulamaları için, kullanıcıların kullanım deneyimine ve ağ başarısına dayalı olarak uygulamayı puanlamasını isteyen akıllı bir derecelendirme diyalog paketi.

📖 **[For English documentation, click here](README.md)**

## Özellikler

- **Akıllı Tetikleme**: Derecelendirme diyaloğunu yalnızca belirli bir süre boyunca başarılı ağ etkinliği olduğunda gösterir (varsayılan 5 saniye).
- **Ağ İzleme**: Bir Dio interceptor kullanarak ağ trafiğini otomatik olarak izler (veya manuel raporlama).
- **Koşullu Mantık**:
    - **4-5 Yıldız**: Kullanıcıyı mağazaya yönlendirir.
    - **1-3 Yıldız**: Uygulama içinde geri bildirim ister.
- **Kalıcılık**: Diyaloğun en son ne zaman gösterildiğini hatırlar ve bir bekleme süresine (varsayılan 30 gün) saygı duyar.
- **Yerelleştirme**: Tamamen özelleştirilebilir metinler.
- **Hata Takibi**: Ağ hatalarını takip eder ve derecelendirme diyaloğunu yalnızca koşullar sağlandığında gösterir.

## Ekran Görüntüleri

### Temalar

| Modern Açık | Modern Koyu | Canlı Gradyan |
| :---: | :---: | :---: |
| <img src="./assets/light.png" width="200" alt="Modern Açık"> | <img src="./assets/dark.png" width="200" alt="Modern Koyu"> | <img src="./assets/vibrant_1.png" width="200" alt="Canlı Gradyan"> |

### Tüm Akış (Canlı Gradyan Teması)

| 1. Puanlama | 2. Düşük Puan Geri Bildirim | 3. Yüksek Puan (Mağaza) | 4. Teşekkür |
| :---: | :---: | :---: | :---: |
| <img src="./assets/vibrant_1.png" width="150" alt="Adım 1"> | <img src="./assets/vibrant_2.png" width="150" alt="Adım 2"> | <img src="./assets/vibrant_3.png" width="150" alt="Adım 3"> | <img src="./assets/vibrant_4.png" width="150" alt="Adım 4"> |

## Kurulum

### Bağımlılık Olarak Ekle

Bu komutu çalıştırın:

Dart ile:
```bash
dart pub add dt_flutter_smart_rating
```

Flutter ile:
```bash
flutter pub add dt_flutter_smart_rating
```

Bu, `pubspec.yaml` dosyanıza aşağıdaki gibi bir satır ekleyecek (ve otomatik olarak `flutter pub get` çalıştıracaktır):

```yaml
dependencies:
  dt_flutter_smart_rating: ^0.0.4
```

### İçe Aktarın (Import)

Artık Dart kodunuzda şunu kullanabilirsiniz:

```dart
import 'package:dt_flutter_smart_rating/dt_flutter_smart_rating.dart';
```

## Kullanım

### 1. Başlatma

`SmartRating` singleton'ını `main.dart` veya `App` widget'ınızda başlatın. Diyaloğun ağ katmanından doğrudan bir context referansı olmadan gösterilmesine izin vermek için bir `navigatorKey` sağlamanız gerekir.

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
        storeUrl: 'https://apps.apple.com/app/id...', // veya Play Store URL
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

### 2. Ağı İzleme

Ağ etkinliğini `SmartRating`'e bildirmek için network veya API katmanınızda manuel raporlama yöntemlerini çağırın.

#### Dio Kullanarak (Örnek Interceptor)

Eğer [Dio](https://pub.dev/packages/dio) kullanıyorsanız, raporlamayı otomatikleştirmek için basit bir interceptor oluşturabilirsiniz:

```dart
class SmartRatingInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    SmartRating().reportNetworkSuccess();
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    SmartRating().reportNetworkFailure();
    super.onError(err, handler);
  }
}

// Dio örneğinize ekleyin:
final dio = Dio();
dio.interceptors.add(SmartRatingInterceptor());
```

#### Manuel Raporlama

Dio kullanmıyorsanız, ağ yanıtınıza göre başarı veya başarısızlığı manuel olarak raporlayabilirsiniz:

```dart
// Başarılı olduğunda
SmartRating().reportNetworkSuccess();

// Başarısız olduğunda
SmartRating().reportNetworkFailure();
```

### Manuel Mod

Diyaloğun ne zaman gösterileceğini kontrol etmeyi tercih ederseniz (örneğin, belirli bir kullanıcı eyleminden sonra), otomatik tetiklemeyi devre dışı bırakabilirsiniz:

```dart
SmartRatingConfig(
  // ...
  autoTrigger: false, // Otomatik göstermeyi devre dışı bırak
)
```

Ardından diyaloğu istediğiniz zaman manuel olarak gösterin:

```dart
// Temel kullanım - Diyaloğu istediğiniz zaman gösterin (yine de dialogInterval'a saygı duyar)
await SmartRating().showRatingDialog();

// Örnek: Kullanıcı bir işlemi tamamladıktan sonra geri bildirim callback'i ile göster
void onUserCompletedOrder() {
  // ... mantığınız
  SmartRating().showRatingDialog(
    onSubmitFeedback: (feedback) async {
       // Geri bildirimi backend'inize veya analitik sisteminize gönderin
       debugPrint('Kullanıcı geri bildirimi: $feedback');
       
       // Burada özel bir teşekkür mesajı gösterebilir veya başka işlemler yapabilirsiniz
    },
  );
}
```

> **Not**: Manuel modda bile, diyalog çok sık gösterilmemesi için `dialogInterval`'a saygı duyar.

### Manuel Tetikleme için Akıllı Kontroller

Diyaloğu manuel olarak gösterirken, optimum kullanıcı deneyimi sağlamak için akıllı kontrolleri kullanabilirsiniz:

```dart
// Sadece HİÇ ağ hatası olmadıysa göster
await SmartRating().showRatingDialog(
  onlyIfNoFailures: true,
);

// Sadece minimum başarı sayısına ulaşıldıysa göster
await SmartRating().showRatingDialog(
  requireMinimumSuccess: true,
);

// 2 hataya kadar izin ver
await SmartRating().showRatingDialog(
  maximumAllowedFailures: 2,
);

// Birden fazla koşulu birleştir
await SmartRating().showRatingDialog(
  requireMinimumSuccess: true,
  maximumAllowedFailures: 1,
);
```

**Kullanım Senaryoları:**
- **Kritik akışlar** (ödemeler, kayıtlar): `onlyIfNoFailures: true` kullanın
- **Kalite güvencesi**: `requireMinimumSuccess: true` kullanın
- **Toleranslı akışlar**: `maximumAllowedFailures: N` kullanın

### Hata Takibi ve Oturum Yönetimi

Ağ kalitesini izleyin ve gerektiğinde sayaçları sıfırlayın:

```dart
// Mevcut istatistikleri kontrol et
int failures = SmartRating().failureCount;
int successes = SmartRating().successCount;
bool anyFailures = SmartRating().hasFailures;

debugPrint('Network stats: $successes successes, $failures failures');

// Yeni oturum/akış için sayaçları sıfırla
void startNewUserSession() {
  SmartRating().resetCounters();
}

// Örnek: Kullanıcı giriş yaptıktan sonra sıfırla
void onUserLogin() {
  SmartRating().resetCounters(); // Yeni oturum için temiz başlangıç
}
```

## Konfigürasyon

`SmartRatingConfig`, davranışı özelleştirmenize olanak tanır:

| Özellik | Tür | Varsayılan | Açıklama |
|---|---|---|---|
| `appName` | `String` | Zorunlu | Uygulamanızın adı. |
| `storeUrl` | `String` | Zorunlu | Derecelendirme için yönlendirilecek URL. |
| `navigatorKey` | `GlobalKey<NavigatorState>?` | `null` | Diyaloğu context olmadan göstermek için anahtar. |
| `appIcon` | `Widget?` | `null` | Diyalogda gösterilecek simge. |
| `dialogInterval` | `Duration` | 30 gün | Diyaloğun gösterilmesi arasındaki minimum süre. |
| `waitDurationAfterSuccess` | `Duration` | 5 saniye | Minimum başarı sayısına ulaşıldıktan sonra beklenecek süre. |
| `minimumSuccessfulRequests` | `int` | 20 | Gereken ardışık başarılı istek sayısı. Herhangi bir hata bu sayacı sıfırlar. |
| `autoTrigger` | `bool` | `true` | Diyaloğun otomatik olarak gösterilip gösterilmeyeceği. Manuel kontrol için `false` yapın. |
| `localizations` | `SmartRatingLocalizations` | Varsayılan | Özel metin dizeleri. |
| `theme` | `SmartRatingTheme` | Varsayılan | Görsel tema özelleştirmesi. |

## Tema (Theming)

Paket, diyaloğun görünümünü özelleştirmek için güçlü bir tema sistemi içerir.

### Hazır Temalar

```dart
// Gradyan ile modern açık tema
SmartRatingConfig(
  // ...
  theme: SmartRatingTheme.modernLight(),
)

// Canlı vurgulara sahip koyu tema
SmartRatingConfig(
  // ...
  theme: SmartRatingTheme.modernDark(),
)

// Canlı gradyan tema
SmartRatingConfig(
  // ...
  theme: SmartRatingTheme.vibrantGradient(),
)
```

### Özel Tema

Diyaloğun her yönünü tamamen özelleştirebilirsiniz:

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
    // ... ve daha birçok özelleştirme seçeneği
  ),
)
```

## Lisans

MIT
