import 'dart:ui' show Locale;

import '../utils/calculations.dart';

class AppLocalizations {
  AppLocalizations(Locale locale) : isTurkish = locale.languageCode == 'tr';

  final bool isTurkish;

  String _t(String tr, String en) => isTurkish ? tr : en;

  String _n(double value) => value.toStringAsFixed(2);

  String get appTitle => _t('3D Yazıcı Kalibrasyonu', '3D Printer Calibration');

  String get exit => _t('Çıkış', 'Exit');
  String get darkMode => _t('Karanlık Mod', 'Dark Mode');
  String get lightMode => _t('Aydınlık Mod', 'Light Mode');

  // Sekmeler
  String get stepsCalibration => _t('Eksen Adımları', 'Axis Steps');
  String get flowRate => _t('Akış Oranı', 'Flow Rate');
  String get retraction => _t('Geri Çekme', 'Retraction');
  String get temperature => _t('Sıcaklık', 'Temperature');

  // Eksen adımları
  String axisCalibration(String axis) =>
      _t('Kalibrasyon: $axis Ekseni', 'Calibration: $axis Axis');
  String axisResult(String axis, double value) => _t(
        '$axis Ekseni: ${_n(value)} adım/mm',
        '$axis Axis: ${_n(value)} steps/mm',
      );
  String get optimalDistance =>
      _t('Optimal Mesafe (mm)', 'Optimal Distance (mm)');
  String get measuredDistance =>
      _t('Ölçülen Mesafe (mm)', 'Measured Distance (mm)');
  String get currentSteps => _t('Mevcut Adımlar', 'Current Steps');

  // Akış oranı
  String flowRateResult(double value) =>
      _t('Akış Oranı: ${_n(value)} %', 'Flow Rate: ${_n(value)} %');
  String get optimalWallThickness =>
      _t('Optimal Duvar Kalınlığı (mm)', 'Optimal Wall Thickness (mm)');
  String get measuredWallThickness =>
      _t('Ölçülen Duvar Kalınlığı (mm)', 'Measured Wall Thickness (mm)');
  String get currentFlowRate =>
      _t('Mevcut Akış Oranı (%)', 'Current Flow Rate (%)');

  // Geri çekme
  String retractionDistanceResult(double value) => _t(
        'Geri Çekme Mesafesi: ${_n(value)} mm',
        'Retraction Distance: ${_n(value)} mm',
      );
  String retractionSpeedResult(double value) => _t(
        'Geri Çekme Hızı: ${_n(value)} mm/s',
        'Retraction Speed: ${_n(value)} mm/s',
      );
  String get optimalRetractionDistance => _t(
        'Optimal Geri Çekme Mesafesi (mm)',
        'Optimal Retraction Distance (mm)',
      );
  String get measuredRetractionDistance => _t(
        'Ölçülen Geri Çekme Mesafesi (mm)',
        'Measured Retraction Distance (mm)',
      );
  String get currentRetractionSpeed => _t(
        'Mevcut Geri Çekme Hızı (mm/s)',
        'Current Retraction Speed (mm/s)',
      );

  // Sıcaklık
  String temperatureResult(double value) => _t(
        'Önerilen Sıcaklık: ${_n(value)} °C',
        'Suggested Temperature: ${_n(value)} °C',
      );
  String get currentTemperature =>
      _t('Mevcut Sıcaklık (°C)', 'Current Temperature (°C)');
  String get stringingScore =>
      _t('Stringing Puanı (0-10)', 'Stringing Score (0-10)');

  // Butonlar ve başlıklar
  String get calculate => _t('Hesapla', 'Calculate');
  String get reset => _t('Sıfırla', 'Reset');
  String historyTitle(String type) =>
      _t('$type Kalibrasyon Geçmişi', '$type Calibration History');

  // Hatalar
  String get errorGeneric => _t('Bir hata oluştu.', 'An error occurred.');
  String errorMessage(CalibrationError error) => switch (error) {
        CalibrationError.zeroMeasuredDistance => _t(
            'Ölçülen mesafe sıfır olamaz.',
            'Measured distance cannot be zero.',
          ),
        CalibrationError.zeroWallThickness => _t(
            'Ölçülen duvar kalınlığı sıfır olamaz.',
            'Measured wall thickness cannot be zero.',
          ),
        CalibrationError.zeroRetractionDistance => _t(
            'Ölçülen geri çekme mesafesi sıfır olamaz.',
            'Measured retraction distance cannot be zero.',
          ),
      };
}
