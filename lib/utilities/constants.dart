import 'package:flutter/material.dart';

// System Colors
const Color primaryColor = Color(0xFF7B61FF);
const Color redAlertColor = Color.fromARGB(255, 255, 0, 0);

// const Color primaryColor = Color(0xFF7B61FF);
// const Color redPrimaryColor = Color(0xFFFF7070);
// const Color redSecondaryColor = Color.fromARGB(255, 255, 74, 74);

// Vibration Patterns
// Longo, curto, curto (1 segundo)
const vibratePatternLongShortShort = [0, 500, 150, 200, 150, 200, 150];
// toc, toc, toc, toc (1 seg e 250ms)
const vibratePatternTocTocToc = [0, 200, 150, 200, 150, 200, 150];
// bonk, bonk, bonk (1 seg e 350ms)
const vibratePatternBonkBonkBonk = [0, 300, 150, 300, 150, 300, 150];
// intense bonk, bonk, bonk (1 seg e 350ms)
const vibratePatternIntenseBonkBonkBonk = [0, 500, 150, 500, 150, 500, 150];
