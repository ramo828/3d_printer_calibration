import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../google_ads.dart';
import '../localization/app_localizations.dart';
import '../utils/calculations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.onThemeModeChanged});

  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<HomePage> createState() => _HomePageState();
}

/// Metin alanı + varsayılan değeri (sıfırlama ve boş girişte kullanılır).
class _Field {
  _Field(this.defaultValue)
      : controller = TextEditingController(text: defaultValue);

  final String defaultValue;
  final TextEditingController controller;

  /// Türkçe klavyedeki virgülü de kabul eder.
  double get value =>
      double.tryParse(controller.text.trim().replaceAll(',', '.')) ??
      double.parse(defaultValue);

  void reset() => controller.text = defaultValue;

  void dispose() => controller.dispose();
}

/// Grafikteki tek bir çizgi. [axis] verilirse yalnızca o eksenin kayıtları çizilir.
class _ChartSeries {
  const _ChartSeries(this.color, [this.axis]);

  final Color color;
  final String? axis;

  bool matches(CalibrationRecord record) => axis == null || record.axis == axis;
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  static const _axes = ['X', 'Y', 'Z'];
  static const _listPadding = EdgeInsets.fromLTRB(16, 8, 16, 16);
  static const _cardMargin = EdgeInsets.symmetric(vertical: 8);

  final GoogleAds _ads = GoogleAds();
  late AppLocalizations _loc;
  bool _adRequested = false;

  late final TabController _tabController =
      TabController(length: CalibrationType.values.length, vsync: this);
  late final AnimationController _fadeController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );
  late final Animation<double> _fadeAnimation =
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
  late final AnimationController _buttonController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );
  late final Animation<double> _buttonScale =
      Tween<double>(begin: 1, end: 0.95).animate(
    CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
  );

  bool _isCalculating = false;
  Key _chartKey = UniqueKey();
  final Set<CalibrationType> _visibleResults = {};
  final List<CalibrationRecord> _history = [];

  // Eksen adımları
  final _optimalDistance = _Field('20.0');
  final _measuredDistance = _Field('20.0');
  final _currentSteps = _Field('80.0');
  String _selectedAxis = 'X';
  final Map<String, double> _axisResults = {'X': 0, 'Y': 0, 'Z': 0};

  // Akış oranı
  final _optimalWallThickness = _Field('0.8');
  final _measuredWallThickness = _Field('0.8');
  final _currentFlowRate = _Field('100.0');
  double _flowRateResult = 0;

  // Geri çekme
  final _optimalRetractionDistance = _Field('2.0');
  final _measuredRetractionDistance = _Field('2.0');
  final _currentRetractionSpeed = _Field('40.0');
  double _retractionDistanceResult = 0;
  double _retractionSpeedResult = 0;

  // Sıcaklık
  final _currentTemperature = _Field('200.0');
  final _stringingScore = _Field('5');
  double _temperatureResult = 0;

  late final List<_Field> _allFields = [
    _optimalDistance,
    _measuredDistance,
    _currentSteps,
    _optimalWallThickness,
    _measuredWallThickness,
    _currentFlowRate,
    _optimalRetractionDistance,
    _measuredRetractionDistance,
    _currentRetractionSpeed,
    _currentTemperature,
    _stringingScore,
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loc = AppLocalizations(Localizations.localeOf(context));
    if (!_adRequested) {
      _adRequested = true;
      _ads.loadAd(
        width: MediaQuery.sizeOf(context).width.truncate(),
        onChanged: () {
          if (mounted) setState(() {});
        },
      );
    }
  }

  @override
  void dispose() {
    for (final field in _allFields) {
      field.dispose();
    }
    _ads.dispose();
    _fadeController.dispose();
    _buttonController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------- mantık

  CalibrationRecord _compute(CalibrationType type) {
    final now = DateTime.now();
    switch (type) {
      case CalibrationType.steps:
        final result = CalibrationCalculations.calculateStepsPerMm(
          optimalDistance: _optimalDistance.value,
          measuredDistance: _measuredDistance.value,
          currentSteps: _currentSteps.value,
        );
        _axisResults[_selectedAxis] = result;
        return CalibrationRecord(
          type: type,
          axis: _selectedAxis,
          value: result,
          timestamp: now,
        );
      case CalibrationType.flow:
        _flowRateResult = CalibrationCalculations.calculateFlowRate(
          optimalWallThickness: _optimalWallThickness.value,
          measuredWallThickness: _measuredWallThickness.value,
          currentFlowRate: _currentFlowRate.value,
        );
        return CalibrationRecord(
          type: type,
          value: _flowRateResult,
          timestamp: now,
        );
      case CalibrationType.retraction:
        final result = CalibrationCalculations.calculateRetraction(
          optimalRetractionDistance: _optimalRetractionDistance.value,
          measuredRetractionDistance: _measuredRetractionDistance.value,
          currentRetractionSpeed: _currentRetractionSpeed.value,
        );
        _retractionDistanceResult = result.distance;
        _retractionSpeedResult = result.speed;
        return CalibrationRecord(
          type: type,
          value: result.distance,
          speed: result.speed,
          timestamp: now,
        );
      case CalibrationType.temperature:
        _temperatureResult = CalibrationCalculations.suggestTemperature(
          currentTemperature: _currentTemperature.value,
          stringingScore: _stringingScore.value,
        );
        return CalibrationRecord(
          type: type,
          value: _temperatureResult,
          timestamp: now,
        );
    }
  }

  Future<void> _calculate(CalibrationType type) async {
    if (_isCalculating) return;
    setState(() => _isCalculating = true);

    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    try {
      setState(() {
        _history.add(_compute(type));
        _visibleResults.add(type);
        _chartKey = UniqueKey();
      });
      _fadeController.forward(from: 0);
    } on CalibrationException catch (e) {
      _showMessage(_loc.errorMessage(e.error));
    } catch (_) {
      _showMessage(_loc.errorGeneric);
    } finally {
      if (mounted) setState(() => _isCalculating = false);
    }
  }

  void _reset(CalibrationType type) {
    setState(() {
      switch (type) {
        case CalibrationType.steps:
          _optimalDistance.reset();
          _measuredDistance.reset();
          _currentSteps.reset();
          _axisResults.updateAll((axis, _) => 0);
        case CalibrationType.flow:
          _optimalWallThickness.reset();
          _measuredWallThickness.reset();
          _currentFlowRate.reset();
          _flowRateResult = 0;
        case CalibrationType.retraction:
          _optimalRetractionDistance.reset();
          _measuredRetractionDistance.reset();
          _currentRetractionSpeed.reset();
          _retractionDistanceResult = 0;
          _retractionSpeedResult = 0;
        case CalibrationType.temperature:
          _currentTemperature.reset();
          _stringingScore.reset();
          _temperatureResult = 0;
      }
      _history.removeWhere((record) => record.type == type);
      _visibleResults.remove(type);
      _chartKey = UniqueKey();
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _playButtonAnimation() {
    _buttonController.forward().then((_) {
      if (mounted) _buttonController.reverse();
    });
  }

  // ------------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final resultStyle =
        theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold);
    final adWidget = _ads.getAdWidget();

    return Scaffold(
      appBar: AppBar(
        title: Text(_loc.appTitle),
        centerTitle: true,
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: isDark ? _loc.lightMode : _loc.darkMode,
            onPressed: () => widget
                .onThemeModeChanged(isDark ? ThemeMode.light : ThemeMode.dark),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: _loc.stepsCalibration),
            Tab(text: _loc.flowRate),
            Tab(text: _loc.retraction),
            Tab(text: _loc.temperature),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [scheme.primary, scheme.tertiary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Text(
                _loc.appTitle,
                style: theme.textTheme.headlineSmall
                    ?.copyWith(color: scheme.onPrimary),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: Text(_loc.exit),
              onTap: () => SystemNavigator.pop(),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTab(
            type: CalibrationType.steps,
            historyLabel: _loc.stepsCalibration,
            results: [
              for (final axis in _axes)
                Text(_loc.axisResult(axis, _axisResults[axis]!),
                    style: resultStyle),
            ],
            fields: [
              _buildAxisSelector(),
              _buildTextField(_optimalDistance, _loc.optimalDistance),
              _buildTextField(_measuredDistance, _loc.measuredDistance),
              _buildTextField(_currentSteps, _loc.currentSteps),
            ],
            series: const [
              _ChartSeries(Colors.blueAccent, 'X'),
              _ChartSeries(Colors.greenAccent, 'Y'),
              _ChartSeries(Colors.redAccent, 'Z'),
            ],
          ),
          _buildTab(
            type: CalibrationType.flow,
            historyLabel: _loc.flowRate,
            results: [
              Text(_loc.flowRateResult(_flowRateResult), style: resultStyle),
            ],
            fields: [
              _buildTextField(
                  _optimalWallThickness, _loc.optimalWallThickness),
              _buildTextField(
                  _measuredWallThickness, _loc.measuredWallThickness),
              _buildTextField(_currentFlowRate, _loc.currentFlowRate),
            ],
            series: const [_ChartSeries(Colors.blueAccent)],
          ),
          _buildTab(
            type: CalibrationType.retraction,
            historyLabel: _loc.retraction,
            results: [
              Text(_loc.retractionDistanceResult(_retractionDistanceResult),
                  style: resultStyle),
              Text(_loc.retractionSpeedResult(_retractionSpeedResult),
                  style: resultStyle),
            ],
            fields: [
              _buildTextField(
                  _optimalRetractionDistance, _loc.optimalRetractionDistance),
              _buildTextField(_measuredRetractionDistance,
                  _loc.measuredRetractionDistance),
              _buildTextField(
                  _currentRetractionSpeed, _loc.currentRetractionSpeed),
            ],
            series: const [_ChartSeries(Colors.blueAccent)],
          ),
          _buildTab(
            type: CalibrationType.temperature,
            historyLabel: _loc.temperature,
            results: [
              Text(_loc.temperatureResult(_temperatureResult),
                  style: resultStyle),
            ],
            fields: [
              _buildTextField(_currentTemperature, _loc.currentTemperature),
              _buildTextField(_stringingScore, _loc.stringingScore),
            ],
            series: const [_ChartSeries(Colors.blueAccent)],
          ),
        ],
      ),
      bottomNavigationBar: adWidget == null ? null : SafeArea(child: adWidget),
    );
  }

  Widget _buildTab({
    required CalibrationType type,
    required String historyLabel,
    required List<Widget> results,
    required List<Widget> fields,
    required List<_ChartSeries> series,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final records = _history.where((r) => r.type == type).toList();

    return ListView(
      padding: _listPadding,
      children: [
        if (_visibleResults.contains(type))
          FadeTransition(
            opacity: _fadeAnimation,
            child: Card(
              margin: _cardMargin,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(children: results),
                ),
              ),
            ),
          ),
        Card(
          margin: _cardMargin,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  _loc.historyTitle(historyLabel),
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                SizedBox(height: 200, child: _buildChart(records, series)),
              ],
            ),
          ),
        ),
        ...fields,
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ScaleTransition(
                scale: _buttonScale,
                child: ElevatedButton(
                  onPressed: _isCalculating
                      ? null
                      : () {
                          _playButtonAnimation();
                          _calculate(type);
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: _isCalculating
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: scheme.onPrimary,
                          ),
                        )
                      : Text(_loc.calculate),
                ),
              ),
              ScaleTransition(
                scale: _buttonScale,
                child: ElevatedButton(
                  onPressed: _isCalculating
                      ? null
                      : () {
                          _playButtonAnimation();
                          _reset(type);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: scheme.surfaceContainerHighest,
                    foregroundColor: scheme.onSurface,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: Text(_loc.reset),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAxisSelector() {
    return Card(
      margin: _cardMargin,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DropdownButton<String>(
          value: _selectedAxis,
          isExpanded: true,
          items: [
            for (final axis in _axes)
              DropdownMenuItem(
                value: axis,
                child: Text(
                  _loc.axisCalibration(axis),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: (value) {
            if (value != null) setState(() => _selectedAxis = value);
          },
        ),
      ),
    );
  }

  Widget _buildTextField(_Field field, String label) {
    return Card(
      margin: _cardMargin,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: TextField(
          controller: field.controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*[.,]?\d{0,2}')),
          ],
          decoration: InputDecoration(
            labelText: label,
            hintText: field.defaultValue,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- grafik

  String _formatTime(DateTime time) =>
      '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}';

  LineChartBarData _buildBar(
    _ChartSeries series,
    List<CalibrationRecord> records,
  ) {
    final spots = [
      for (var i = 0; i < records.length; i++)
        if (series.matches(records[i]))
          FlSpot(i.toDouble(), records[i].value),
    ];
    return LineChartBarData(
      spots: spots.isEmpty ? const [FlSpot(0, 0)] : spots,
      isCurved: true,
      preventCurveOverShooting: true,
      color: series.color,
      barWidth: 4,
      dotData: const FlDotData(show: true),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [
            series.color.withValues(alpha: 0.3),
            series.color.withValues(alpha: 0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildChart(
    List<CalibrationRecord> records,
    List<_ChartSeries> series,
  ) {
    final theme = Theme.of(context);
    final gridColor = theme.colorScheme.outlineVariant;
    final labelStyle = theme.textTheme.bodySmall;

    final maxValue = records.isEmpty
        ? 100.0
        : records.map((r) => r.value).reduce(math.max) * 1.2;
    final maxY = maxValue <= 0 ? 1.0 : maxValue;
    final maxX = math.max(1, records.length - 1).toDouble();
    final labelInterval = math.max(1, (records.length / 4).ceil()).toDouble();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          verticalInterval: 1,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: gridColor, strokeWidth: 1),
          getDrawingVerticalLine: (_) =>
              FlLine(color: gridColor, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                value.toStringAsFixed(maxY < 10 ? 1 : 0),
                style: labelStyle,
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: labelInterval,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (value != index.toDouble() ||
                    index < 0 ||
                    index >= records.length) {
                  return const SizedBox.shrink();
                }
                return Text(
                  _formatTime(records[index].timestamp),
                  style: labelStyle?.copyWith(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: gridColor, width: 1),
        ),
        lineBarsData: [for (final s in series) _buildBar(s, records)],
        minX: 0,
        maxX: maxX,
        minY: 0,
        maxY: maxY,
      ),
      key: _chartKey,
    );
  }
}
