class RiskCalculator {
  double calculateRisk(String ocrText) {
    // Example logic: Calculate risk based on extracted numbers
    final numbers = ocrText.split(RegExp(r'[^0-9.]')).where((s) => s.isNotEmpty).map(double.parse).toList();
    if (numbers.isEmpty) return 0.0;

    // Example: Average of extracted numbers (simulating risk calculation)
    final sum = numbers.reduce((a, b) => a + b);
    final average = sum / numbers.length;

    // Example risk scale: 0-100%
    return average.clamp(0.0, 100.0);
  }
}