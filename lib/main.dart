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
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text("Double Pendulum"),
        ),
        body: MyGame().widget,
      ),
    );
  }
}

class MyGame extends BaseGame {
  static final threadPaint = BasicPalette.black.paint..strokeWidth = 1;
  static final bobPaint = Paint()
    ..color = Colors.red
    ..style = PaintingStyle.fill;
  static final trailPaint = BasicPalette.black.paint..strokeWidth = 0.5;
  Offset positionOrigin1 = Offset(150, 200);
  double G = 0.98;
  Offset positionBob1 = Offset(0, 100);
  double angle1 = pi / 2;
  double len1 = 100;
  double mass1 = 1;
  double velocity1 = 0.0;
  double acceleration1 = 0.0;

  Offset positionOrigin2;
  Offset positionBob2;
  Offset positionBob2Old;
  double angle2 = pi / 2;
  double len2 = 100;
  double mass2 = 5;
  double velocity2 = 0.0;
  double acceleration2 = 0.0;

  List<Offset> trail1 = [];
  List<Offset> trail2 = [];

  MyGame() {
    double minimumDimension = min(MediaQueryData.fromWindow(window).size.width, MediaQueryData.fromWindow(window).size.height);
    len1 = len2 = (minimumDimension / 4) - 50;
    positionOrigin1 = Offset(MediaQueryData.fromWindow(window).size.width / 2, MediaQueryData.fromWindow(window).size.height / 2);
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

    // Adding damping
    velocity1 *= 0.999;
    velocity2 *= 0.999;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    Rect bgRect = Rect.fromLTWH(0, 0, MediaQueryData.fromWindow(window).size.width, MediaQueryData.fromWindow(window).size.height);
    Paint bgPaint = Paint();
    bgPaint.color = Colors.white;
    canvas.drawRect(bgRect, bgPaint);

    canvas.drawLine(positionOrigin1, positionBob1, threadPaint);
    canvas.drawCircle(positionBob1, 10 * mass1, bobPaint);

    if (positionBob2 != null) {
      canvas.drawLine(positionOrigin2, positionBob2, threadPaint);
      canvas.drawCircle(positionBob2, 10 * mass2, bobPaint);
    }

    if (positionBob2Old != null) {
      // trail1.add(positionBob1);
      // canvas.drawPoints(PointMode.polygon, trail1, bobPaint);
      trail2.add(positionBob2Old);
      canvas.drawPoints(PointMode.polygon, trail2, trailPaint);
    }

    positionBob2Old = positionBob2;
  }
}
