class CalibrationCalculations {
  // Eksen Adım Kalibrasyonu (mm/adım)
  static double calculateStepsPerMm({
    required double optimalDistance,
    required double measuredDistance,
    required double currentSteps,
    required double flowRate,
  }) {
    if (measuredDistance == 0 || flowRate <= 0) {
      throw Exception('Ölçülen mesafe veya akış oranı sıfır olamaz.');
    }
    return (optimalDistance / measuredDistance) *
        currentSteps *
        (flowRate / 100);
  }

  // Akış Oranı Kalibrasyonu (%)
  static double calculateFlowRate({
    required double optimalWallThickness,
    required double measuredWallThickness,
    required double currentFlowRate,
  }) {
    if (measuredWallThickness == 0) {
      throw Exception('Ölçülen duvar kalınlığı sıfır olamaz.');
    }
    return (optimalWallThickness / measuredWallThickness) * currentFlowRate;
  }

  // Geri Çekme (Retraction) Kalibrasyonu
  static Map<String, double> calculateRetraction({
    required double optimalRetractionDistance,
    required double measuredRetractionDistance,
    required double currentRetractionSpeed,
  }) {
    if (measuredRetractionDistance == 0) {
      throw Exception('Ölçülen geri çekme mesafesi sıfır olamaz.');
    }
    final newRetractionDistance =
        (optimalRetractionDistance / measuredRetractionDistance) *
            optimalRetractionDistance;
    // Hız, mesafeye bağlı olarak ölçeklenir (basit bir oran)
    final newRetractionSpeed = currentRetractionSpeed *
        (newRetractionDistance / optimalRetractionDistance);
    return {
      'distance': newRetractionDistance,
      'speed': newRetractionSpeed,
    };
  }

  // Sıcaklık Kalibrasyonu (önerilen test sıcaklığı)
  static double suggestTemperature({
    required double currentTemperature,
    required double stringingScore, // 0-10 arası, stringing şiddeti
  }) {
    // Stringing fazla ise sıcaklık düşürülür
    return currentTemperature - (stringingScore * 2);
  }
}
