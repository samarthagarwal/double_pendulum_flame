import 'dart:math';
import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MainScreen());
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        backgroundColor: Colors.red,
        body: MyGame().widget,
      ),
    );
  }
}

class MyGame extends BaseGame {
  static final squarePaint = BasicPalette.black.paint..strokeWidth = 1;
  Offset positionOrigin1 = Offset(150, 200);
  double G = 0.098 * 2.5;
  Offset positionBob1 = Offset(0, 100);
  double angle1 = pi / 2;
  double len1 = 90;
  double mass1 = 1;
  double velocity1 = 0.0;
  double acceleration1 = 0.0;

  Offset positionOrigin2;
  Offset positionBob2;
  Offset positionBob2Old;
  double angle2 = pi / 2;
  double len2 = 90;
  double mass2 = 1;
  double velocity2 = 0.0;
  double acceleration2 = 0.0;

  List<Offset> trail = [];

  MyGame() {
    positionOrigin1 = Offset(MediaQueryData.fromWindow(window).size.width / 2, 200);
  }

  @override
  void update(double dt) {
    super.update(dt);
    // acceleration1 = mass1 * G * sin(angle1);

    double num1 = -G * (2 * mass1 + mass2) * sin(angle1);
    double num2 = -mass2 * G * sin(angle1 - 2 * angle2);
    double num3 = -2 * sin(angle1 - angle2) * mass2 * ((velocity2 * velocity2 * len2) + (velocity1 * velocity1 * len1 * cos(angle1 - angle2)));
    double den = len1 * (2 * mass1 + mass2 - (mass2 * cos(2 * angle1 - 2 * angle2)));
    acceleration1 = (num1 + num2 + num3) / den;

    num1 = 2 * sin(angle1 - angle2);
    num2 = (velocity1 * velocity1) * len1 * (mass1 + mass2);
    num3 = G * (mass1 + mass2) * cos(angle1);
    double num4 = velocity2 * velocity2 * len2 * mass2 * cos(angle1 - angle2);

    acceleration2 = num1 * (num2 + num3 + num4) / den;
    velocity1 += acceleration1;
    velocity2 += acceleration2;
    angle1 += velocity1;
    angle2 += velocity2;
    // velocity1 *= 0.9990;
    positionBob1 = Offset(positionOrigin1.dx + len1 * sin(angle1), positionOrigin1.dy + len1 * cos(angle1));
    positionOrigin2 = positionBob1;
    positionBob2 = Offset(positionOrigin2.dx + len2 * sin(angle2), positionOrigin2.dy + len2 * cos(angle2));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    Rect bgRect = Rect.fromLTWH(0, 0, MediaQueryData.fromWindow(window).size.width, MediaQueryData.fromWindow(window).size.height);
    Paint bgPaint = Paint();
    bgPaint.color = Colors.white;
    canvas.drawRect(bgRect, bgPaint);

    canvas.drawLine(positionOrigin1, positionBob1, squarePaint);
    canvas.drawCircle(positionBob1, 10 * mass1, squarePaint);

    canvas.drawLine(positionOrigin2, positionBob2, squarePaint);
    canvas.drawCircle(positionBob2, 10 * mass2, squarePaint);

    if (positionBob2Old != null) {
      trail.add(positionBob2Old);
      canvas.drawPoints(PointMode.polygon, trail, squarePaint);
    }

    positionBob2Old = positionBob2;
  }
}
