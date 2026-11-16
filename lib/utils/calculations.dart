enum CalibrationType { steps, flow, retraction, temperature }

enum CalibrationError {
  zeroMeasuredDistance,
  zeroWallThickness,
  zeroRetractionDistance,
}

/// Hesaplama hataları metin yerine kodla taşınır; mesajı arayüz yerelleştirir.
class CalibrationException implements Exception {
  const CalibrationException(this.error);

  final CalibrationError error;

  @override
  String toString() => 'CalibrationException($error)';
}

/// Geçmiş grafiğinde kullanılan tek bir kalibrasyon kaydı.
class CalibrationRecord {
  const CalibrationRecord({
    required this.type,
    required this.value,
    required this.timestamp,
    this.axis,
    this.speed,
  });

  final CalibrationType type;
  final double value;
  final DateTime timestamp;

  /// Yalnızca eksen adımı kalibrasyonunda dolu (X, Y, Z).
  final String? axis;

  /// Yalnızca geri çekme kalibrasyonunda dolu (mm/s).
  final double? speed;
}

class CalibrationCalculations {
  const CalibrationCalculations._();

  /// Eksen adım kalibrasyonu: yeni adım = mevcut adım × (hedef / ölçülen).
  static double calculateStepsPerMm({
    required double optimalDistance,
    required double measuredDistance,
    required double currentSteps,
  }) {
    if (measuredDistance == 0) {
      throw const CalibrationException(CalibrationError.zeroMeasuredDistance);
    }
    return currentSteps * (optimalDistance / measuredDistance);
  }

  /// Akış oranı kalibrasyonu (%).
  static double calculateFlowRate({
    required double optimalWallThickness,
    required double measuredWallThickness,
    required double currentFlowRate,
  }) {
    if (measuredWallThickness == 0) {
      throw const CalibrationException(CalibrationError.zeroWallThickness);
    }
    return (optimalWallThickness / measuredWallThickness) * currentFlowRate;
  }

  /// Geri çekme kalibrasyonu. Mesafe ve hız aynı oranla ölçeklenir.
  static ({double distance, double speed}) calculateRetraction({
    required double optimalRetractionDistance,
    required double measuredRetractionDistance,
    required double currentRetractionSpeed,
  }) {
    if (measuredRetractionDistance == 0) {
      throw const CalibrationException(
        CalibrationError.zeroRetractionDistance,
      );
    }
    final ratio = optimalRetractionDistance / measuredRetractionDistance;
    return (
      distance: optimalRetractionDistance * ratio,
      speed: currentRetractionSpeed * ratio,
    );
  }

  /// Sıcaklık önerisi: stringing arttıkça sıcaklık düşürülür.
  static double suggestTemperature({
    required double currentTemperature,
    required double stringingScore, // 0-10 arası
  }) {
    final score = stringingScore.clamp(0.0, 10.0).toDouble();
    return currentTemperature - (score * 2);
  }
}
