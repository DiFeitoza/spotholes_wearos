import 'package:flutter/material.dart';

class NoSpotholesOnRouteScreen extends StatelessWidget {
  const NoSpotholesOnRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/markholes_thumbs_up.png',
              width: 75,
              height: 75,
            ),
            Text(
              'Tudo OK, não há alertas na rota',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Colors.white,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
