import 'dart:ui';
import 'main.dart';
import 'package:flutter/material.dart';

class FloatingNumbers {
  final Game game;
  List<FloatingNumber> floatingNumbers = [];

  FloatingNumbers(this.game);

  render(Canvas c) {
    floatingNumbers.forEach((f) => f.render(c));
  }

  tick() {
    floatingNumbers.forEach((f) => f.tick());
    floatingNumbers.removeWhere((f) => f.alpha <= 0);
  }

  create(num x, num y, int value, int c) {
    floatingNumbers.add(new FloatingNumber(x, y, value, c));
  }
}

class FloatingNumber {
  num x, y, value, colorInt, alpha;
  FloatingNumber(this.x, this.y, this.value, this.colorInt) {
    alpha = 255;
  }

  render(Canvas c) {
    TextPainter tp = TextPainter(
        text: TextSpan(
            style: TextStyle(
                color: Colors.green.withAlpha(alpha),
                fontWeight: FontWeight.bold),
            text: "+$value"),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(c, Offset(x.toDouble(), y.toDouble()));
  }

  tick() {
    alpha -= 2;
    if (alpha < 150) alpha -= 5;
    if (alpha < 0) {
      alpha = 0;
    }
    y -= 1.5;
  }
}
