import 'dart:ffi';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_circle_color_picker/flutter_circle_color_picker.dart';
import 'package:http/http.dart' as http;

const URL = 'http://192.168.1.93:5000';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LED',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const ColorPickerScreen(),
    );
  }
}

class ColorPickerScreen extends StatefulWidget {
  const ColorPickerScreen({Key? key}) : super(key: key);

  @override
  _ColorPickerScreenState createState() => _ColorPickerScreenState();
}

class _ColorPickerScreenState extends State<ColorPickerScreen> {
  final _controller = CircleColorPickerController(
    initialColor: Colors.blue,
  );

  Color selectedColor = Colors.blue;
  double redValue = 0.0;
  double greenValue = 0.0;
  double blueValue = 255.0;

  void connectToDevice() {
    // Implementa la lógica de conexión Bluetooth aquí
  }

  void sendColorToArduino(Color color) {
    int red = color.red;
    int green = color.green;
    int blue = color.blue;

    setColorRgb(red, green, blue);
  }

  void updateSelectedColor() {
    _controller.color = Color.fromARGB(
        255, redValue.toInt(), greenValue.toInt(), blueValue.toInt());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF8667F2),
        title: const Text(
          'Ledcito',
          style: TextStyle(
            color: Color(0xFFEDE7FF),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: IconButton(
              onPressed: () {
                // Lógica para el botón del icono del foco
              },
              icon: const Icon(Icons.lightbulb_outline_sharp),
              color: selectedColor,
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFEDE7FF),
              Color(0xFF8667F2),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 30.0),
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: selectedColor,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: const Text(
                    'Selecciona un color',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Arial',
                    ),
                  ),
                ),
                CircleColorPicker(
                  controller: _controller,
                  onChanged: (color) {
                    setState(() {
                      selectedColor = color;
                      redValue = color.red.toDouble();
                      greenValue = color.green.toDouble();
                      blueValue = color.blue.toDouble();
                      updateSelectedColor();
                    });
                  },
                ),
                const SizedBox(height: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ColorSlider(
                      label: const Text(
                        'Red',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      value: redValue,
                      onChanged: (value) {
                        setState(() {
                          redValue = value;
                          updateSelectedColor();
                        });
                      },
                      activeColor: const Color(0xFF8667F2),
                    ),
                    ColorSlider(
                      label: const Text(
                        'Green',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      value: greenValue,
                      onChanged: (value) {
                        setState(() {
                          greenValue = value;
                          updateSelectedColor();
                        });
                      },
                      activeColor: const Color(0xFF8667F2),
                    ),
                    ColorSlider(
                      label: const Text(
                        'Blue',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      value: blueValue,
                      onChanged: (value) {
                        setState(() {
                          blueValue = value;
                          updateSelectedColor();
                        });
                      },
                      activeColor: const Color(0xFF8667F2),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    connectToDevice();
                    sendColorToArduino(selectedColor);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedColor,
                  ),
                  child: const Text('Enviar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ColorSlider extends StatelessWidget {
  final Widget label;
  final double value;
  final ValueChanged<double> onChanged;
  final Color activeColor;

  const ColorSlider({
    Key? key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.activeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        label,
        Slider(
          value: value,
          onChanged: onChanged,
          min: 0,
          max: 255,
          divisions: 255,
          activeColor: activeColor,
        ),
      ],
    );
  }
}

void turnOnLed() async {
  print('Encender');
  await http.post(Uri.parse(URL + '/turn-on'));
}

void turnOffLed() async {
  print('Shutdown');
  await http.post(Uri.parse(URL + '/turn-off'));
}

void setColorRgb(int red, int green, int blue) async {
  print('red: $red, green: $green, blue: $blue');
  Map data = {
    'red': red,
    'green': green,
    'blue': blue,
  };

  var body = json.encode(data);

  await http.post(
    Uri.parse(URL + '/set-color'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: body,
  );
}
