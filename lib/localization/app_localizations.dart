import 'dart:io';

class AppLocalizations {
  final bool isTurkish;

  AppLocalizations() : isTurkish = Platform.localeName.startsWith('tr');

  String get appTitle =>
      isTurkish ? '3D Yazıcı Kalibrasyonu' : '3D Printer Calibration';

  String get home => isTurkish ? 'Ana Sayfa' : 'Home';
  String get exit => isTurkish ? 'Çıkış' : 'Exit';

  String get stepsCalibration => isTurkish ? 'Eksen Adımları' : 'Axis Steps';
  String get flowRate => isTurkish ? 'Akış Oranı' : 'Flow Rate';
  String get retraction => isTurkish ? 'Geri Çekme' : 'Retraction';
  String get temperature => isTurkish ? 'Sıcaklık' : 'Temperature';

  String axisCalibration(String axis) =>
      isTurkish ? 'Kalibrasyon: $axis Ekseni' : 'Calibration: $axis Axis';
  String xAxisResult(double value) => isTurkish
      ? 'X Ekseni: ${value.toStringAsFixed(2)} mm/adım'
      : 'X Axis: ${value.toStringAsFixed(2)} mm/step';
  String yAxisResult(double value) => isTurkish
      ? 'Y Ekseni: ${value.toStringAsFixed(2)} mm/adım'
      : 'Y Axis: ${value.toStringAsFixed(2)} mm/step';
  String zAxisResult(double value) => isTurkish
      ? 'Z Ekseni: ${value.toStringAsFixed(2)} mm/adım'
      : 'Z Axis: ${value.toStringAsFixed(2)} mm/step';

  String get optimalDistance =>
      isTurkish ? 'Optimal Mesafe (mm)' : 'Optimal Distance (mm)';
  String get measuredDistance =>
      isTurkish ? 'Ölçülen Mesafe (mm)' : 'Measured Distance (mm)';
  String get currentSteps => isTurkish ? 'Mevcut Adımlar' : 'Current Steps';
  String get flowRateInput => isTurkish ? 'Akış Oranı (%)' : 'Flow Rate (%)';

  String flowRateResult(double value) => isTurkish
      ? 'Akış Oranı: ${value.toStringAsFixed(2)} %'
      : 'Flow Rate: ${value.toStringAsFixed(2)} %';
  String get optimalWallThickness => isTurkish
      ? 'Optimal Duvar Kalınlığı (mm)'
      : 'Optimal Wall Thickness (mm)';
  String get measuredWallThickness => isTurkish
      ? 'Ölçülen Duvar Kalınlığı (mm)'
      : 'Measured Wall Thickness (mm)';
  String get currentFlowRate =>
      isTurkish ? 'Mevcut Akış Oranı (%)' : 'Current Flow Rate (%)';

  String retractionDistanceResult(double value) => isTurkish
      ? 'Geri Çekme Mesafesi: ${value.toStringAsFixed(2)} mm'
      : 'Retraction Distance: ${value.toStringAsFixed(2)} mm';
  String retractionSpeedResult(double value) => isTurkish
      ? 'Geri Çekme Hızı: ${value.toStringAsFixed(2)} mm/s'
      : 'Retraction Speed: ${value.toStringAsFixed(2)} mm/s';
  String get optimalRetractionDistance => isTurkish
      ? 'Optimal Geri Çekme Mesafesi (mm)'
      : 'Optimal Retraction Distance (mm)';
  String get measuredRetractionDistance => isTurkish
      ? 'Ölçülen Geri Çekme Mesafesi (mm)'
      : 'Measured Retraction Distance (mm)';
  String get currentRetractionSpeed => isTurkish
      ? 'Mevcut Geri Çekme Hızı (mm/s)'
      : 'Current Retraction Speed (mm/s)';

  String temperatureResult(double value) => isTurkish
      ? 'Önerilen Sıcaklık: ${value.toStringAsFixed(2)} °C'
      : 'Suggested Temperature: ${value.toStringAsFixed(2)} °C';
  String get currentTemperature =>
      isTurkish ? 'Mevcut Sıcaklık (°C)' : 'Current Temperature (°C)';
  String get stringingScore =>
      isTurkish ? 'Stringing Puanı (0-10)' : 'Stringing Score (0-10)';

  String get calculate => isTurkish ? 'Hesapla' : 'Calculate';
  String get reset => isTurkish ? 'Sıfırla' : 'Reset';

  String historyTitle(String type) =>
      isTurkish ? '$type Kalibrasyon Geçmişi' : '$type Calibration History';

  String get errorZeroFlowRate => isTurkish
      ? 'Ölçülen mesafe veya akış oranı sıfır olamaz.'
      : 'Measured distance or flow rate cannot be zero.';
  String get errorZeroWallThickness => isTurkish
      ? 'Ölçülen duvar kalınlığı sıfır olamaz.'
      : 'Measured wall thickness cannot be zero.';
  String get errorZeroRetraction => isTurkish
      ? 'Ölçülen geri çekme mesafesi sıfır olamaz.'
      : 'Measured retraction distance cannot be zero.';
}
