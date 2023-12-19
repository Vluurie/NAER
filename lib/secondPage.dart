import 'package:flutter/material.dart';

class SecondPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('More Features in Future'),
        backgroundColor:
            const Color.fromARGB(255, 33, 33, 34), // You can change this color
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'This Page will have:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey, // Change this color as needed
              ),
            ),
            SizedBox(height: 20), // Adds space between the lines
            Text(
              '1. Speedrunner Phase Jump',
              style: TextStyle(
                fontSize: 18,
                color: Colors.green, // Change this color as needed
              ),
            ),
            SizedBox(height: 10),
            Text(
              '2. My Mods as Install Option',
              style: TextStyle(
                fontSize: 18,
                color: Colors.green, // Change this color as needed
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Stay tuned for updates!',
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.redAccent, // Change this color as needed
              ),
            ),
          ],
        ),
      ),
    );
  }
}
