// ignore: depend_on_referenced_packages
import "package:google_mobile_ads/google_mobile_ads.dart"
    show AdWidget, MobileAds;
import 'package:flutter/material.dart';
import 'google_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Builder(builder: (context) => const Home()),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController iInput = TextEditingController(text: "0.0");
  TextEditingController mStep = TextEditingController(text: "80.0");
  TextEditingController outputM = TextEditingController(text: "0.0");
  double formula = 0.0;
  double formulaX = 0.0;
  double formulaY = 0.0;
  double formulaZ = 0.0;

  // Seçenekler listesi
  List<String> options = ['Calibration: X', 'Calibration: Y', 'Calibration: Z'];

  // Seçilen değeri tutacak değişken
  String selectedOption = "Calibration: X";

  @override
  void initState() {
    super.initState();
    // Load ads.
  }

  @override
  Widget build(BuildContext context) {
    Google_ads ga = Google_ads();
    ga.loadAd();

    return Scaffold(
      body: Center(
        child: ListView(
          children: [
            ga.bannerAd != null
                ? Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).size.width / 2.60),
                    child: Card(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: SafeArea(
                          child: SizedBox(
                            width: ga.bannerAd!.size.width.toDouble(),
                            height: ga.bannerAd!.size.height.toDouble(),
                            child: AdWidget(ad: ga.bannerAd!),
                          ),
                        ),
                      ),
                    ),
                  )
                : const Center(),
            // DropdownButton widget'ı
            Card(
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                height: MediaQuery.of(context).size.height / 8,
                child: Center(
                  child: Column(
                    children: [
                      Text("Output X: $formulaX"),
                      Text("Output Y: $formulaY"),
                      Text("Output Z: $formulaZ"),
                    ],
                  ),
                ),
              ),
            ),

            Center(
              child: DropdownButton<String>(
                // Seçilen değeri set etme
                value: selectedOption,
                // Seçeneklerin listesi
                items: options.map((String option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                // DropdownButton değiştiğinde yapılacak işlem
                onChanged: (newValue) {
                  setState(() {
                    selectedOption = newValue ?? "Calibration: X";
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 35,
                right: 35,
                bottom: 10,
              ),
              child: TextField(
                controller: iInput,
                decoration: const InputDecoration(
                  hintText: "0.0",
                  prefixText: "The optimal parameter: ",
                  hintStyle: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 35,
                right: 35,
                bottom: 10,
              ),
              child: TextField(
                controller: mStep,
                decoration: const InputDecoration(
                  hintText: "0.0",
                  prefixText: "Average value of a s motor: ",
                  hintStyle: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 35,
                right: 35,
                bottom: 10,
              ),
              child: TextField(
                controller: outputM,
                decoration: const InputDecoration(
                  hintText: "0.0",
                  prefixText: "Output measurement: ",
                  hintStyle: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: OutlinedButton(
                onPressed: () {
                  double a = double.parse(iInput.text);
                  double b = double.parse(outputM.text);
                  double c = double.parse(mStep.text);
                  setState(() {
                    formula = (a / b) * c;
                    if (selectedOption == "Calibration: X") {
                      formulaX = formula;
                    } else if (selectedOption == "Calibration: Y") {
                      formulaY = formula;
                    } else if (selectedOption == "Calibration: Z") {
                      formulaZ = formula;
                    }
                  });
                },
                child: const Text("Calculate"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
