# 🎯 Smart Rating - Yeni Özellikler Kullanım Kılavuzu

## 📦 Versiyon 0.0.2 - Failure Tracking & Smart Controls

Bu güncellemede, `dt_flutter_smart_rating` paketine **geriye dönük uyumlu** (backward compatible) önemli yeni özellikler eklendi.

---

## 🆕 Yeni Özellikler

### 1. **Failure Tracking Sistemi**
Her network hatası artık takip ediliyor ve sayılıyor.

```dart
// Hata sayısını öğren
int totalFailures = SmartRating().failureCount;

// Herhangi bir hata oldu mu?
bool hadIssues = SmartRating().hasFailures;

// Başarı sayısı
int totalSuccesses = SmartRating().successCount;
```

---

### 2. **Smart Manual Triggering**
`showRatingDialog()` metodu artık 3 yeni parametre ile geliştirildi:

#### a) `onlyIfNoFailures` - Sadece Hiç Hata Yoksa Göster
```dart
// Kritik flow'larda kullanın (ödeme, kayıt, vb.)
await SmartRating().showRatingDialog(
  onlyIfNoFailures: true,
);
```

**Kullanım Senaryosu:**
```dart
// Randevu oluşturma flow'u bittiğinde
Future<void> createAppointment() async {
  try {
    // API çağrıları...
    await apiService.createAppointment();
    
    // Eğer hiç hata olmadıysa rating iste
    await SmartRating().showRatingDialog(
      onlyIfNoFailures: true,
    );
  } catch (e) {
    // Hata oldu, zaten SmartRating.reportNetworkFailure() çağrıldı
  }
}
```

#### b) `requireMinimumSuccess` - Minimum Başarı Sayısı Kontrolü
```dart
// Sadece yeterli başarılı request varsa göster
await SmartRating().showRatingDialog(
  requireMinimumSuccess: true,
);
```

**Kullanım Senaryosu:**
```dart
// Kullanıcı profil sayfasını dolduruyor
Future<void> completeProfile() async {
  // Birden fazla API çağrısı yapıldı
  // Config'de minimumSuccessfulRequests = 20 olsun
  
  // Sadece 20+ başarılı request varsa rating iste
  await SmartRating().showRatingDialog(
    requireMinimumSuccess: true,
  );
}
```

#### c) `maximumAllowedFailures` - Tolerans Seviyesi
```dart
// Maksimum 2 hataya kadar tolere et
await SmartRating().showRatingDialog(
  maximumAllowedFailures: 2,
);
```

**Kullanım Senaryosu:**
```dart
// Normal flow - birkaç hata tolere edilebilir
Future<void> browseProducts() async {
  // Kullanıcı ürün listesinde gezindi
  // Bazı resimler yüklenmemiş olabilir (2-3 hata)
  // Ama genel deneyim iyiyse rating iste
  
  await SmartRating().showRatingDialog(
    maximumAllowedFailures: 3,
  );
}
```

---

### 3. **Birden Fazla Koşulu Birleştirme**
```dart
// Hem minimum başarı, hem de maksimum 1 hata
await SmartRating().showRatingDialog(
  requireMinimumSuccess: true,
  maximumAllowedFailures: 1,
);
```

---

### 4. **Session Management - Counter Reset**
Yeni session başlatıldığında sayaçları sıfırlayın:

```dart
void resetCounters() {
  SmartRating().resetCounters();
}
```

**Kullanım Senaryoları:**
```dart
// Kullanıcı giriş yaptığında
Future<void> onUserLogin() async {
  await authService.login();
  
  // Yeni session, temiz başlangıç
  SmartRating().resetCounters();
}

// Yeni flow başladığında
void startNewAppointmentFlow() {
  // Önceki flow'un hataları yeni flow'u etkilemeyecek
  SmartRating().resetCounters();
}

// Uygulama yeniden başlatıldığında
@override
void initState() {
  super.initState();
  
  // Her app açılışında temiz başla
  SmartRating().resetCounters();
}
```

---

## 🎓 Pratik Kullanım Örnekleri

### Örnek 1: E-Ticaret Sipariş Flow'u
```dart
class CheckoutController {
  Future<void> completeOrder() async {
    // Sepet doğrulama
    await cartService.validate();
    
    // Ödeme işlemi
    await paymentService.processPayment();
    
    // Sipariş oluşturma
    await orderService.createOrder();
    
    // ✅ Kritik flow - sadece hiç hata yoksa rating iste
    await SmartRating().showRatingDialog(
      onlyIfNoFailures: true,
      requireMinimumSuccess: true,
    );
  }
}
```

---

### Örnek 2: Sosyal Medya Feed Browsing
```dart
class FeedController {
  Future<void> onUserScrolledToEnd() async {
    // Kullanıcı feed'i gezdi
    // Bazı görseller yüklenmemiş olabilir
    // Ama genel deneyim iyiyse rating isteyebiliriz
    
    await SmartRating().showRatingDialog(
      maximumAllowedFailures: 5, // 5 görsel yüklenememiş olabilir
    );
  }
}
```

---

### Örnek 3: Çoklu Session App
```dart
class SessionManager {
  Future<void> onUserLogout() async {
    await authService.logout();
    
    // Logout öncesi rating iste
    // Bu session'daki deneyim nasıldı?
    await SmartRating().showRatingDialog(
      onlyIfNoFailures: true,
    );
    
    // Session bitti, counter'ları resetle
    SmartRating().resetCounters();
  }
  
  Future<void> onUserLogin() async {
    await authService.login();
    
    // Yeni session, temiz başla
    SmartRating().resetCounters();
  }
}
```

---

### Örnek 4: Debug/Monitoring Dashboard
```dart
class NetworkStatsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Text('Successes: ${SmartRating().successCount}'),
          Text('Failures: ${SmartRating().failureCount}'),
          Text('Has Issues: ${SmartRating().hasFailures}'),
          
          ElevatedButton(
            onPressed: () {
              SmartRating().resetCounters();
            },
            child: Text('Reset Stats'),
          ),
        ],
      ),
    );
  }
}
```

---

## 🔄 Geriye Dönük Uyumluluk

**ÖNEMLI:** Tüm mevcut kodlar aynen çalışmaya devam edecek!

```dart
// Eski kod - HİÇBİR DEĞİŞİKLİK GEREKMİYOR
await SmartRating().showRatingDialog();

// Yeni özellikler tamamen opsiyonel
await SmartRating().showRatingDialog(
  onlyIfNoFailures: true, // İstersen ekle
);
```

---

## 📊 Karar Ağacı: Hangi Parametreyi Kullanmalıyım?

```
┌─────────────────────────────────────────────┐
│ Flow türün ne?                              │
└───────────────┬─────────────────────────────┘
                │
        ┌───────┴───────┐
        │               │
    KRİTİK         NORMAL
(Ödeme, Kayıt)  (Browse, Search)
        │               │
        │               │
    onlyIfNoFailures: true    maximumAllowedFailures: N
    requireMinimumSuccess: true
```

---

## ✅ Test Senaryoları

```dart
void testSmartRating() {
  // Senaryo 1: Hiç hata yok
  // 20 başarılı request
  // ✅ Dialog gösterilir
  
  // Senaryo 2: 1 hata var
  // onlyIfNoFailures: true
  // ❌ Dialog gösterilmez
  
  // Senaryo 3: 2 hata var
  // maximumAllowedFailures: 3
  // ✅ Dialog gösterilir (2 <= 3)
  
  // Senaryo 4: 15 başarılı request
  // requireMinimumSuccess: true (min: 20)
  // ❌ Dialog gösterilmez (15 < 20)
}
```

---

## 🚀 Hızlı Başlangıç

1. **Paketin en son versiyonunu çekin**
2. **Hiçbir değişiklik yapmayın** - mevcut kod çalışır
3. **İstediğiniz yerlerde yeni parametreleri ekleyin**:

```dart
// Kritik flow'larda
await SmartRating().showRatingDialog(onlyIfNoFailures: true);

// Session değişimlerinde
SmartRating().resetCounters();
```

---

## 📞 Destek

Sorularınız için:
- GitHub Issues
- Package maintainer: @muratoner
