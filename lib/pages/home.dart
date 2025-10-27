import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../google_ads.dart';
import '../utils/calculations.dart';
import '../localization/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final List<GoogleAds> _googleAdsList = [
    GoogleAds(),
    GoogleAds(),
    GoogleAds(),
    GoogleAds(),
  ];
  late TabController _tabController;
  late AppLocalizations _loc;
  bool _isCalculating = false;
  bool _showResults = false;
  Key _chartKey = UniqueKey();
  final ValueNotifier<List<Map<String, dynamic>>> _historyNotifier =
      ValueNotifier([]); // Grafik için veri notifier

  final ValueNotifier<ThemeMode> _themeMode = ValueNotifier(ThemeMode.light);

  // Eksen Adım Kalibrasyonu
  final TextEditingController _optimalDistance =
      TextEditingController(text: "20.0");
  final TextEditingController _measuredDistance =
      TextEditingController(text: "20.0");
  final TextEditingController _currentSteps =
      TextEditingController(text: "80.0");
  final TextEditingController _flowRateSteps =
      TextEditingController(text: "100.0");
  String _selectedAxis = 'X';
  double _calibrationX = 0.0, _calibrationY = 0.0, _calibrationZ = 0.0;

  // Akış Oranı Kalibrasyonu
  final TextEditingController _optimalWallThickness =
      TextEditingController(text: "0.8");
  final TextEditingController _measuredWallThickness =
      TextEditingController(text: "0.8");
  final TextEditingController _currentFlowRate =
      TextEditingController(text: "100.0");
  double _flowRateResult = 0.0;

  // Geri Çekme Kalibrasyonu
  final TextEditingController _optimalRetractionDistance =
      TextEditingController(text: "2.0");
  final TextEditingController _measuredRetractionDistance =
      TextEditingController(text: "2.0");
  final TextEditingController _currentRetractionSpeed =
      TextEditingController(text: "40.0");
  double _retractionDistanceResult = 0.0, _retractionSpeedResult = 0.0;

  // Sıcaklık Kalibrasyonu
  final TextEditingController _currentTemperature =
      TextEditingController(text: "200.0");
  final TextEditingController _stringingScore =
      TextEditingController(text: "5");
  double _temperatureResult = 0.0;

  final List<Map<String, dynamic>> _calibrationHistory = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonScaleAnimation;

  static const _axes = ['X', 'Y', 'Z'];
  static const _padding = EdgeInsets.symmetric(horizontal: 20, vertical: 10);
  static const _cardBorderRadius = BorderRadius.all(Radius.circular(16));

  @override
  void initState() {
    super.initState();
    _loc = AppLocalizations();
    for (var ads in _googleAdsList) {
      ads.loadAd();
    }
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _buttonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
          parent: _buttonAnimationController, curve: Curves.easeInOut),
    );
    _tabController = TabController(length: 4, vsync: this);
    _historyNotifier.value = _calibrationHistory; // İlk tarihçe ataması
    _animationController.forward();
  }

  @override
  void dispose() {
    _optimalDistance.dispose();
    _measuredDistance.dispose();
    _currentSteps.dispose();
    _flowRateSteps.dispose();
    _optimalWallThickness.dispose();
    _measuredWallThickness.dispose();
    _currentFlowRate.dispose();
    _optimalRetractionDistance.dispose();
    _measuredRetractionDistance.dispose();
    _currentRetractionSpeed.dispose();
    _currentTemperature.dispose();
    _stringingScore.dispose();
    for (var ads in _googleAdsList) {
      ads.dispose();
    }
    _animationController.dispose();
    _buttonAnimationController.dispose();
    _tabController.dispose();
    _themeMode.dispose();
    _historyNotifier.dispose();
    super.dispose();
  }

  double _parseDouble(String value, double defaultValue) {
    try {
      return double.parse(value);
    } catch (e) {
      return defaultValue;
    }
  }

  Future<void> _calculateCalibration(int tabIndex) async {
    setState(() {
      _isCalculating = true;
      _showResults = false;
      _chartKey = UniqueKey();
    });

    await Future.delayed(const Duration(milliseconds: 500));

    try {
      setState(() {
        if (tabIndex == 0) {
          final result = CalibrationCalculations.calculateStepsPerMm(
            optimalDistance: _parseDouble(_optimalDistance.text, 20.0),
            measuredDistance: _parseDouble(_measuredDistance.text, 20.0),
            currentSteps: _parseDouble(_currentSteps.text, 80.0),
            flowRate: _parseDouble(_flowRateSteps.text, 100.0),
          );
          if (_selectedAxis == 'X') {
            _calibrationX = result;
          } else if (_selectedAxis == 'Y') {
            _calibrationY = result;
          } else {
            _calibrationZ = result;
          }
          _calibrationHistory.add({
            'type': 'steps',
            'axis': _selectedAxis,
            'value': result,
            'timestamp': DateTime.now(),
          });
        } else if (tabIndex == 1) {
          _flowRateResult = CalibrationCalculations.calculateFlowRate(
            optimalWallThickness: _parseDouble(_optimalWallThickness.text, 0.8),
            measuredWallThickness:
                _parseDouble(_measuredWallThickness.text, 0.8),
            currentFlowRate: _parseDouble(_currentFlowRate.text, 100.0),
          );
          _calibrationHistory.add({
            'type': 'flow',
            'value': _flowRateResult,
            'timestamp': DateTime.now(),
          });
        } else if (tabIndex == 2) {
          final result = CalibrationCalculations.calculateRetraction(
            optimalRetractionDistance:
                _parseDouble(_optimalRetractionDistance.text, 2.0),
            measuredRetractionDistance:
                _parseDouble(_measuredRetractionDistance.text, 2.0),
            currentRetractionSpeed:
                _parseDouble(_currentRetractionSpeed.text, 40.0),
          );
          _retractionDistanceResult = result['distance']!;
          _retractionSpeedResult = result['speed']!;
          _calibrationHistory.add({
            'type': 'retraction',
            'value': _retractionDistanceResult,
            'speed': _retractionSpeedResult,
            'timestamp': DateTime.now(),
          });
        } else {
          _temperatureResult = CalibrationCalculations.suggestTemperature(
            currentTemperature: _parseDouble(_currentTemperature.text, 200.0),
            stringingScore: _parseDouble(_stringingScore.text, 5.0),
          );
          _calibrationHistory.add({
            'type': 'temperature',
            'value': _temperatureResult,
            'timestamp': DateTime.now(),
          });
        }
        _historyNotifier.value =
            List.from(_calibrationHistory); // Notifier güncelleme
        _showResults = true;
        _animationController.reset();
        _animationController.forward();
        debugPrint('History updated: $_calibrationHistory'); // Debug log
      });
    } catch (e) {
      setState(() {
        _showResults = false;
        _chartKey = UniqueKey();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              _loc.isTurkish ? e.toString() : _getEnglishError(e.toString())),
        ),
      );
    } finally {
      setState(() {
        _isCalculating = false;
        _chartKey = UniqueKey();
      });
    }
  }

  String _getEnglishError(String turkishError) {
    if (turkishError.contains(_loc.errorZeroFlowRate)) {
      return _loc.errorZeroFlowRate;
    } else if (turkishError.contains(_loc.errorZeroWallThickness)) {
      return _loc.errorZeroWallThickness;
    } else if (turkishError.contains(_loc.errorZeroRetraction)) {
      return _loc.errorZeroRetraction;
    }
    return 'Bir hata oluştu.';
  }

  void _resetFields(int tabIndex) {
    setState(() {
      if (tabIndex == 0) {
        _optimalDistance.text = "20.0";
        _measuredDistance.text = "20.0";
        _currentSteps.text = "80.0";
        _flowRateSteps.text = "100.0";
        _calibrationX = 0.0;
        _calibrationY = 0.0;
        _calibrationZ = 0.0;
      } else if (tabIndex == 1) {
        _optimalWallThickness.text = "0.8";
        _measuredWallThickness.text = "0.8";
        _currentFlowRate.text = "100.0";
        _flowRateResult = 0.0;
      } else if (tabIndex == 2) {
        _optimalRetractionDistance.text = "2.0";
        _measuredRetractionDistance.text = "2.0";
        _currentRetractionSpeed.text = "40.0";
        _retractionDistanceResult = 0.0;
        _retractionSpeedResult = 0.0;
      } else {
        _currentTemperature.text = "200.0";
        _stringingScore.text = "5";
        _temperatureResult = 0.0;
      }
      _calibrationHistory.clear();
      _historyNotifier.value =
          List.from(_calibrationHistory); // Notifier güncelleme
      _showResults = false;
      _chartKey = UniqueKey();
      _animationController.reset();
      _animationController.forward();
      debugPrint('History cleared: $_calibrationHistory'); // Debug log
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeMode,
      builder: (context, themeMode, child) {
        return MaterialApp(
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
            textTheme: GoogleFonts.poppinsTextTheme(),
            cardTheme: const CardThemeData(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: _cardBorderRadius),
              color: Colors.white,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                textStyle: GoogleFonts.poppins(fontSize: 16),
                shape: RoundedRectangleBorder(borderRadius: _cardBorderRadius),
              ),
            ),
            scaffoldBackgroundColor: Colors.grey[100],
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.blue,
            textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
            cardTheme: CardThemeData(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: _cardBorderRadius),
              color: Colors.grey[850],
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                textStyle: GoogleFonts.poppins(fontSize: 16),
                shape: RoundedRectangleBorder(borderRadius: _cardBorderRadius),
              ),
            ),
            scaffoldBackgroundColor: Colors.grey[900],
          ),
          themeMode: themeMode,
          home: Scaffold(
            appBar: AppBar(
              title: Text(_loc.appTitle, style: GoogleFonts.poppins()),
              centerTitle: true,
              elevation: 0,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
              actions: [
                IconButton(
                  icon: Icon(themeMode == ThemeMode.light
                      ? Icons.dark_mode
                      : Icons.light_mode),
                  onPressed: () {
                    _themeMode.value = themeMode == ThemeMode.light
                        ? ThemeMode.dark
                        : ThemeMode.light;
                  },
                  tooltip: themeMode == ThemeMode.light
                      ? 'Karanlık Mod'
                      : 'Aydınlık Mod',
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.blueAccent,
                labelColor: Theme.of(context).textTheme.bodyLarge!.color,
                unselectedLabelColor: Colors.grey,
                isScrollable: true,
                labelStyle: GoogleFonts.poppins(fontSize: 14),
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
                        colors: [
                          Theme.of(context).primaryColor,
                          Colors.blueAccent
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Text(
                      _loc.appTitle,
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontSize: 24),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.exit_to_app),
                    title: Text(_loc.exit, style: GoogleFonts.poppins()),
                    onTap: () => exit(0),
                  ),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildTab(
                  tabIndex: 0,
                  googleAds: _googleAdsList[0],
                  results: [
                    Text(_loc.xAxisResult(_calibrationX),
                        style:
                            GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    Text(_loc.yAxisResult(_calibrationY),
                        style:
                            GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    Text(_loc.zAxisResult(_calibrationZ),
                        style:
                            GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  ],
                  fields: [
                    Card(
                      margin: _padding,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: DropdownButton<String>(
                          value: _selectedAxis,
                          isExpanded: true,
                          items: _axes
                              .map((axis) => DropdownMenuItem(
                                    value: axis,
                                    child: Text(
                                      _loc.axisCalibration(axis),
                                      style: GoogleFonts.poppins(fontSize: 14),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _selectedAxis = value!),
                        ),
                      ),
                    ),
                    _buildTextField(
                        _optimalDistance, _loc.optimalDistance, '20.0'),
                    _buildTextField(
                        _measuredDistance, _loc.measuredDistance, '20.0'),
                    _buildTextField(_currentSteps, _loc.currentSteps, '80.0'),
                    _buildTextField(
                        _flowRateSteps, _loc.flowRateInput, '100.0'),
                  ],
                  historyType: 'steps',
                  historyBuilder: (history) {
                    final xSpots = history
                        .asMap()
                        .entries
                        .where((e) =>
                            e.value['type'] == 'steps' &&
                            e.value['axis'] == 'X')
                        .map((e) => FlSpot(e.key.toDouble(), e.value['value']))
                        .toList();
                    final ySpots = history
                        .asMap()
                        .entries
                        .where((e) =>
                            e.value['type'] == 'steps' &&
                            e.value['axis'] == 'Y')
                        .map((e) => FlSpot(e.key.toDouble(), e.value['value']))
                        .toList();
                    final zSpots = history
                        .asMap()
                        .entries
                        .where((e) =>
                            e.value['type'] == 'steps' &&
                            e.value['axis'] == 'Z')
                        .map((e) => FlSpot(e.key.toDouble(), e.value['value']))
                        .toList();
                    return [
                      LineChartBarData(
                        spots:
                            xSpots.isNotEmpty ? xSpots : [const FlSpot(0, 0)],
                        isCurved: true,
                        color: Colors.blueAccent,
                        barWidth: 4,
                        dotData: FlDotData(
                            show: true, checkToShowDot: (spot, _) => true),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              Colors.blueAccent.withOpacity(0.3),
                              Colors.blueAccent.withOpacity(0.0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      LineChartBarData(
                        spots:
                            ySpots.isNotEmpty ? ySpots : [const FlSpot(0, 0)],
                        isCurved: true,
                        color: Colors.greenAccent,
                        barWidth: 4,
                        dotData: FlDotData(
                            show: true, checkToShowDot: (spot, _) => true),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              Colors.greenAccent.withOpacity(0.3),
                              Colors.greenAccent.withOpacity(0.0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      LineChartBarData(
                        spots:
                            zSpots.isNotEmpty ? zSpots : [const FlSpot(0, 0)],
                        isCurved: true,
                        color: Colors.redAccent,
                        barWidth: 4,
                        dotData: FlDotData(
                            show: true, checkToShowDot: (spot, _) => true),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              Colors.redAccent.withOpacity(0.3),
                              Colors.redAccent.withOpacity(0.0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ];
                  },
                ),
                _buildTab(
                  tabIndex: 1,
                  googleAds: _googleAdsList[1],
                  results: [
                    Text(_loc.flowRateResult(_flowRateResult),
                        style:
                            GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  ],
                  fields: [
                    _buildTextField(_optimalWallThickness,
                        _loc.optimalWallThickness, '0.8'),
                    _buildTextField(_measuredWallThickness,
                        _loc.measuredWallThickness, '0.8'),
                    _buildTextField(
                        _currentFlowRate, _loc.currentFlowRate, '100.0'),
                  ],
                  historyType: 'flow',
                  historyBuilder: (history) {
                    final spots = history
                        .asMap()
                        .entries
                        .where((e) => e.value['type'] == 'flow')
                        .map((e) => FlSpot(e.key.toDouble(), e.value['value']))
                        .toList();
                    return [
                      LineChartBarData(
                        spots: spots.isNotEmpty ? spots : [const FlSpot(0, 0)],
                        isCurved: true,
                        color: Colors.blueAccent,
                        barWidth: 4,
                        dotData: FlDotData(
                            show: true, checkToShowDot: (spot, _) => true),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              Colors.blueAccent.withOpacity(0.3),
                              Colors.blueAccent.withOpacity(0.0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ];
                  },
                ),
                _buildTab(
                  tabIndex: 2,
                  googleAds: _googleAdsList[2],
                  results: [
                    Text(
                        _loc.retractionDistanceResult(
                            _retractionDistanceResult),
                        style:
                            GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    Text(_loc.retractionSpeedResult(_retractionSpeedResult),
                        style:
                            GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  ],
                  fields: [
                    _buildTextField(_optimalRetractionDistance,
                        _loc.optimalRetractionDistance, '2.0'),
                    _buildTextField(_measuredRetractionDistance,
                        _loc.measuredRetractionDistance, '2.0'),
                    _buildTextField(_currentRetractionSpeed,
                        _loc.currentRetractionSpeed, '40.0'),
                  ],
                  historyType: 'retraction',
                  historyBuilder: (history) {
                    final spots = history
                        .asMap()
                        .entries
                        .where((e) => e.value['type'] == 'retraction')
                        .map((e) => FlSpot(e.key.toDouble(), e.value['value']))
                        .toList();
                    return [
                      LineChartBarData(
                        spots: spots.isNotEmpty ? spots : [const FlSpot(0, 0)],
                        isCurved: true,
                        color: Colors.blueAccent,
                        barWidth: 4,
                        dotData: FlDotData(
                            show: true, checkToShowDot: (spot, _) => true),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              Colors.blueAccent.withOpacity(0.3),
                              Colors.blueAccent.withOpacity(0.0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ];
                  },
                ),
                _buildTab(
                  tabIndex: 3,
                  googleAds: _googleAdsList[3],
                  results: [
                    Text(_loc.temperatureResult(_temperatureResult),
                        style:
                            GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  ],
                  fields: [
                    _buildTextField(
                        _currentTemperature, _loc.currentTemperature, '200.0'),
                    _buildTextField(_stringingScore, _loc.stringingScore, '5'),
                  ],
                  historyType: 'temperature',
                  historyBuilder: (history) {
                    final spots = history
                        .asMap()
                        .entries
                        .where((e) => e.value['type'] == 'temperature')
                        .map((e) => FlSpot(e.key.toDouble(), e.value['value']))
                        .toList();
                    return [
                      LineChartBarData(
                        spots: spots.isNotEmpty ? spots : [const FlSpot(0, 0)],
                        isCurved: true,
                        color: Colors.blueAccent,
                        barWidth: 4,
                        dotData: FlDotData(
                            show: true, checkToShowDot: (spot, _) => true),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              Colors.blueAccent.withOpacity(0.3),
                              Colors.blueAccent.withOpacity(0.0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ];
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTab({
    required int tabIndex,
    required GoogleAds googleAds,
    required List<Widget> results,
    required List<Widget> fields,
    required String historyType,
    required List<LineChartBarData> Function(List<Map<String, dynamic>>)
        historyBuilder,
  }) {
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: _historyNotifier,
      builder: (context, history, child) {
        final historyData = historyBuilder(history);
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: _padding,
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  googleAds.isAdLoaded
                      ? (googleAds.getAdWidget() ?? const SizedBox.shrink())
                      : const SizedBox.shrink(),
                  if (_showResults)
                    AnimatedBuilder(
                      animation: _fadeAnimation,
                      builder: (context, child) => FadeTransition(
                        opacity: _fadeAnimation,
                        child: Card(
                          elevation: 4,
                          shape: const RoundedRectangleBorder(
                              borderRadius: _cardBorderRadius),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(children: results),
                          ),
                        ),
                      ),
                    ),
                  Card(
                    margin: _padding,
                    elevation: 4,
                    shape: const RoundedRectangleBorder(
                        borderRadius: _cardBorderRadius),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            _loc.historyTitle(historyType),
                            style: GoogleFonts.poppins(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 200,
                            child: LineChart(
                              key: _chartKey,
                              LineChartData(
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: true,
                                  horizontalInterval: 10,
                                  verticalInterval: 1,
                                  getDrawingHorizontalLine: (value) => FlLine(
                                    color: Theme.of(context)
                                        .dividerColor
                                        .withOpacity(0.3),
                                    strokeWidth: 1,
                                  ),
                                  getDrawingVerticalLine: (value) => FlLine(
                                    color: Theme.of(context)
                                        .dividerColor
                                        .withOpacity(0.3),
                                    strokeWidth: 1,
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 40,
                                      getTitlesWidget: (value, meta) => Text(
                                        value.toStringAsFixed(0),
                                        style:
                                            GoogleFonts.poppins(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        if (history.isEmpty ||
                                            value.toInt() >= history.length) {
                                          return const Text('');
                                        }
                                        return Text(
                                          history[value.toInt()]['timestamp']
                                              .toString()
                                              .substring(11, 16),
                                          style:
                                              GoogleFonts.poppins(fontSize: 10),
                                        );
                                      },
                                    ),
                                  ),
                                  topTitles: const AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false)),
                                ),
                                borderData: FlBorderData(
                                  show: true,
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .dividerColor
                                        .withOpacity(0.5),
                                    width: 1,
                                  ),
                                ),
                                lineBarsData: historyData,
                                minX: 0,
                                maxX: history.isEmpty
                                    ? 1
                                    : history.length.toDouble(),
                                minY: 0,
                                maxY: history.isEmpty
                                    ? 100
                                    : (history
                                                .map(
                                                    (e) => e['value'] as double)
                                                .reduce(
                                                    (a, b) => a > b ? a : b) *
                                            1.2)
                                        .toDouble(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ...fields,
                  Padding(
                    padding: _padding,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        AnimatedBuilder(
                          animation: _buttonScaleAnimation,
                          builder: (context, child) => ScaleTransition(
                            scale: _buttonScaleAnimation,
                            child: ElevatedButton(
                              onPressed: _isCalculating
                                  ? null
                                  : () {
                                      _buttonAnimationController.forward().then(
                                            (_) => _buttonAnimationController
                                                .reverse(),
                                          );
                                      _calculateCalibration(tabIndex);
                                    },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                              ),
                              child: _isCalculating
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(_loc.calculate,
                                      style: GoogleFonts.poppins(fontSize: 16)),
                            ),
                          ),
                        ),
                        AnimatedBuilder(
                          animation: _buttonScaleAnimation,
                          builder: (context, child) => ScaleTransition(
                            scale: _buttonScaleAnimation,
                            child: ElevatedButton(
                              onPressed: _isCalculating
                                  ? null
                                  : () {
                                      _buttonAnimationController.forward().then(
                                            (_) => _buttonAnimationController
                                                .reverse(),
                                          );
                                      _resetFields(tabIndex);
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[600],
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                              ),
                              child: Text(_loc.reset,
                                  style: GoogleFonts.poppins(fontSize: 16)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, String hint) {
    return Card(
      margin: _padding,
      elevation: 4,
      shape: const RoundedRectangleBorder(borderRadius: _cardBorderRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            border: InputBorder.none,
            labelStyle:
                GoogleFonts.poppins(color: Theme.of(context).primaryColor),
          ),
          style: GoogleFonts.poppins(),
        ),
      ),
    );
  }
}
