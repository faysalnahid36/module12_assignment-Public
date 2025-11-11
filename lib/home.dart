import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_expressions/math_expressions.dart';



class home extends StatefulWidget {
  const home({super.key});

  @override
  State<home> createState() => _CalculatorAppState();
}


class _CalculatorAppState extends State<home> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _saveTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', value);
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    _saveTheme(_isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Calculator',
      debugShowCheckedModeBanner: false,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[200],
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: CalculatorScreen(
        isDarkMode: _isDarkMode,
        onThemeToggle: _toggleTheme,
      ),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const CalculatorScreen({
    Key? key,
    required this.isDarkMode,
    required this.onThemeToggle,
  }) : super(key: key);

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String userInput = '';
  String result = '0';

  final List<String> buttons = [
    'AC', '⌫', '%', '÷',
    '7', '8', '9', '×',
    '4', '5', '6', '−',
    '1', '2', '3', '+',
    '0', '.', '=',
  ];

  void _buttonPressed(String text) {
    setState(() {
      if (text == 'AC') {
        userInput = '';
        result = '0';
      } else if (text == '⌫') {
        if (userInput.isNotEmpty) {
          userInput = userInput.substring(0, userInput.length - 1);
        }
      } else if (text == '=') {
        _calculateResult();
      } else {
        if (userInput.isEmpty && (text == '÷' || text == '×' || text == '+' || text == '−')) {
          return; // prevent starting with operator
        }
        if (userInput.isNotEmpty) {
          String lastChar = userInput[userInput.length - 1];
          if ('÷×+−'.contains(lastChar) && '÷×+−'.contains(text)) {
            return; // prevent multiple operators
          }
        }
        userInput += text;
      }
    });
  }

  void _calculateResult() {
    String finalInput = userInput;
    finalInput = finalInput.replaceAll('×', '*');
    finalInput = finalInput.replaceAll('÷', '/');
    finalInput = finalInput.replaceAll('−', '-');

    try {
      Parser p = Parser();
      Expression exp = p.parse(finalInput);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      result = eval.toString();
      if (result.endsWith('.0')) {
        result = result.replaceAll('.0', '');
      }
    } catch (e) {
      result = 'Error';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = widget.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Calculator"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onThemeToggle,
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.bottomRight,
              child: SingleChildScrollView(
                reverse: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      userInput,
                      style: TextStyle(
                        fontSize: 28,
                        color: dark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      result,
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: dark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: GridView.builder(
                itemCount: buttons.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  final text = buttons[index];
                  return ElevatedButton(
                    onPressed: () => _buttonPressed(text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getButtonColor(text, dark),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 24,
                        color: _getTextColor(text, dark),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getButtonColor(String text, bool dark) {
    if (text == 'AC' || text == '⌫') {
      return Colors.redAccent;
    } else if ('÷×−+='.contains(text)) {
      return Colors.blueAccent;
    } else {
      return dark ? Colors.grey[800]! : Colors.grey[300]!;
    }
  }

  Color _getTextColor(String text, bool dark) {
    if ('AC⌫÷×−+=.'.contains(text)) {
      return Colors.white;
    } else {
      return dark ? Colors.white : Colors.black;
    }
  }
}

