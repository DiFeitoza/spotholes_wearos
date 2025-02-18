import 'package:flutter/material.dart';

// System Colors
const Color primaryColor = Color(0xFF7B61FF);
const Color redAlertColor = Color.fromARGB(255, 255, 0, 0);
const Color yellowAlertColor = Colors.yellow;

const deepHoleAlertColor = redAlertColor;
const regularHoleAlertColor = yellowAlertColor;

const deepHoleAlertContrastColor = Colors.white;
const regularHoleAlertContrastColor = Colors.black;

// Vibration Patterns
// Longo, curto, curto (1 segundo)
const vibratePatternLongShortShort = [0, 500, 150, 200, 150, 200, 150];
// toc, toc, toc, toc (1 seg e 250ms)
const vibratePatternTocTocToc = [0, 200, 150, 200, 150, 200, 150];
// bonk, bonk, bonk (1 seg e 350ms)
const vibratePatternBonkBonkBonk = [0, 300, 150, 300, 150, 300, 150];
// intense bonk, bonk, bonk (1 seg e 350ms)
const vibratePatternIntenseBonkBonkBonk = [0, 500, 150, 500, 150, 500, 150];
