import 'package:flutter/material.dart';

class EconomicModeScreen extends StatelessWidget {
  const EconomicModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Spotholes\nModo Econômico',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Colors.blueGrey,
                  ),
            ),
            const Icon(
              Icons.battery_saver,
              color: Colors.blueGrey,
            ),
          ],
        ),
      ),
    );
  }
}
