import 'package:flutter/material.dart';

class ConnectionScreen extends StatelessWidget {
  const ConnectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.route,
                  color: Colors.blueGrey,
                ),
                Icon(
                  Icons.smartphone,
                  color: Colors.blueGrey,
                ),
              ],
            ),
            Text(
              'Inicie uma rota no app spotholes android',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Colors.blueGrey,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
