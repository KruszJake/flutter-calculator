import 'package:flutter/material.dart';
// Import the expressions package
import 'package:expressions/expressions.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  // This string holds the user input / expression
  String _expression = '';

  // Called whenever a button is pressed to update the display
  void _onButtonPressed(String value) {
    setState(() {
      // If the expression already ended with '=', start fresh on next numeric/operator input:
      if (_expression.contains('=') && _isNumericOrOperator(value)) {
        _expression = '';
      }
      _expression += value;
    });
  }

  // Check if the value is a digit/operator/decimal
  bool _isNumericOrOperator(String value) {
    final validChars = RegExp(r'^[0-9+\-*/.^%]+$');
    return validChars.hasMatch(value);
  }

  // Evaluate the expression using the expressions package
  void _calculateResult() {
    // If expression already ends with '=', don't evaluate again
    if (_expression.endsWith('=')) return;

    setState(() {
      try {
        // Replace '×' -> '*', '÷' -> '/' for parsing
        final parseExpression =
            _expression.replaceAll('×', '*').replaceAll('÷', '/');

        // Parse the string into an Expression
        final exp = Expression.parse(parseExpression);

        // Evaluate with ExpressionEvaluator
        const evaluator = ExpressionEvaluator();
        final dynamic result = evaluator.eval(exp, {});

        // Show final expression as "2+3*4 = 14"
        _expression = '$_expression = $result';
      } catch (e) {
        // Catch invalid or impossible expressions (e.g. divide by zero)
        _expression = 'Error';
      }
    });
  }

  // Clear all text
  void _clearExpression() {
    setState(() {
      _expression = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Name's Calculator"), // <— Update with your name
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Display area (shows expression or result)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                alignment: Alignment.bottomRight,
                child: SingleChildScrollView(
                  reverse: true,
                  child: Text(
                    _expression,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
            ),

            // Existing calculator rows
            _buildButtonRow(['7', '8', '9', '÷']),
            _buildButtonRow(['4', '5', '6', '×']),
            _buildButtonRow(['1', '2', '3', '-']),
            _buildButtonRow(['0', '.', '=', '+']),

            // NEW: Extra operations row
            _buildButtonRow(['(', ')', 'x²', '%']),

            // Clear row
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _clearExpression,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                    child: const Text(
                      'C',
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method: build a row of 4 buttons
  Widget _buildButtonRow(List<String> labels) {
    return Row(
      children: labels.map((label) {
        return Expanded(child: _buildCalcButton(label));
      }).toList(),
    );
  }

  // Helper method: build each individual calculator button
  Widget _buildCalcButton(String label) {
    return InkWell(
      onTap: () {
        // We can handle special cases here
        switch (label) {
          case '=':
            _calculateResult();
            break;
          // If user taps 'x²', we actually append '^2' to the expression
          case 'x²':
            _onButtonPressed('^2');
            break;
          default:
            _onButtonPressed(label);
        }
      },
      child: Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _getButtonColor(label),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 26,
              color: _isOperator(label) ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // Decide button color based on whether it’s an operator
  Color _getButtonColor(String label) {
    if (label == '=' || _isOperator(label) || label == 'x²') {
      return Colors.blue;
    }
    if (label == 'C') {
      return Colors.red;
    }
    return Colors.white;
  }

  bool _isOperator(String label) {
    return ['+', '-', '×', '÷', '%'].contains(label);
  }
}
