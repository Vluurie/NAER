import 'package:flutter/material.dart';

class CustomErrorScreen extends StatelessWidget {
  final FlutterErrorDetails? errorDetails;

  const CustomErrorScreen({
    Key? key,
    required this.errorDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Default error message
    String errorMessage = 'An unexpected error has occurred.';
    String errorDetailsMessage = '';

    // Check if errorDetails are available
    if (errorDetails != null) {
      errorMessage = 'Error: ${errorDetails!.exceptionAsString()}';
      errorDetailsMessage = 'Details: ${errorDetails!.stack.toString()}';
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Allows scrolling for long content
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logomyy.png',
                errorBuilder: (context, error, stackTrace) {
                  return const Text('Error loading image!');
                },
              ),
              const SizedBox(height: 20),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                errorDetailsMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
