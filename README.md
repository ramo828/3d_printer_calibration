# 3D Printer Calibration

3D yazıcı kalibrasyon hesaplayıcısı (Flutter). Dört araç içerir:

- **Eksen adımları** – X/Y/Z için yeni adım/mm değeri
- **Akış oranı** – duvar kalınlığından yeni akış yüzdesi
- **Geri çekme** – geri çekme mesafesi ve hızı
- **Sıcaklık** – stringing puanına göre önerilen sıcaklık

Arayüz İngilizce ve Türkçe, açık/koyu tema destekler. Her sekmede hesaplama geçmişi grafiği vardır.

## Geliştirme

```bash
flutter pub get
flutter run
```

## Release build (Android)

1. İmzalama anahtarını ve `key.properties` dosyasını **`android/app/`** (veya `android/`) içine koy:

   ```properties
   storeFile=anahtar.jks
   storePassword=...
   keyAlias=...
   keyPassword=...
   ```

   `storeFile` yolu `android/app/` klasörüne göredir. Bu dosyalar `.gitignore` tarafından
   yok sayılır; **asla commit etme**. `key.properties` bulunamazsa build debug anahtarıyla
   imzalanır ve Play Store'a yüklenemez (build sırasında uyarı basılır).

2. Gerçek reklam kimliklerini ver:

   - `android/app/src/main/AndroidManifest.xml` → `com.google.android.gms.ads.APPLICATION_ID`
   - `ios/Runner/Info.plist` → `GADApplicationIdentifier`
   - Banner birimi build sırasında verilir:

   ```bash
   flutter build aab --release --dart-define=BANNER_AD_UNIT_ID=ca-app-pub-xxx/yyy
   ```

   `BANNER_AD_UNIT_ID` verilmezse Google'ın test reklamı gösterilir (gelir getirmez).
   Depodaki App ID'ler de Google'ın **test** kimlikleridir.

3. Sürümü artırırken `pubspec.yaml` (`version:`) ile `android/app/build.gradle.kts`
   (`versionName` / `versionCode`) değerlerini birlikte güncelle.
