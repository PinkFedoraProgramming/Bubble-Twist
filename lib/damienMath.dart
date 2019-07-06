import 'dart:math' as math;
import 'dart:core';

class DamienMath {
  static math.Random random = math.Random();

  //Random Functions
  static int randInt(num min, num max) {
    return random.nextInt((max.toInt() - min.toInt()) + 1) + min.toInt();
  }

  static double randDouble(double min, double max) {
    return (random.nextDouble() * (max - (min))) + min;
  }

  static bool randBoolean() {
    return random.nextBool();
  }

  static bool randChance(double percent) {
    return ((random.nextDouble() * 100) < percent);
  }

  static double toDegrees(double radians) {
    return radians * 180 / math.pi;
  }

  static double toRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  //Angle Functions
  static double getAngle(double x1, double y1, double x2, double y2) {
    double angle = toDegrees(math.atan2(x2 - x1, y1 - y2));
    return (angle > 0 ? angle : angle + 360);
  }

  static double getDifferenceInAngles(double a1, double a2) {
    double amount = a2 - a1;
    return amount < 180 ? amount : 360 - amount;
  }

  static double getAbsDifferenceInAngles(double a1, double a2) {
    double amount = a2 - a1;
    return (amount < 180 ? amount : 360 - amount).abs();
  }

  static double getXOfAngle(double angle) {
    return math.cos(toRadians(angle - 90));
  }

  static double getYOfAngle(double angle) {
    return math.sin(toRadians(angle - 90));
  }

  static double translateAngle(
      double angle, double relativeAngle, bool clockwise) {
    if (!clockwise) {
      angle -= relativeAngle;
      angle = -angle;
    } else {
      angle += relativeAngle;
    }
    return angle;
  }

  //Point functions
  static double distanceBetween(double x1, double y1, double x2, double y2) {
    double xDistance = (x1 > x2 ? x1 - x2 : x2 - x1);
    double yDistance = (y1 > y2 ? y1 - y2 : y2 - y1);
    return math.sqrt(math.pow(xDistance, 2) + math.pow(yDistance, 2));
  }

  static List<double> rotatePoint(
      double x, double y, double rx, double ry, double angle) {
    var rad = toRadians(angle);
    var rotatedX = math.cos(rad) * (x - rx) - math.sin(rad) * (y - ry) + rx;
    var rotatedY = math.sin(rad) * (x - rx) + math.cos(rad) * (y - ry) + ry;
    return [rotatedX, rotatedY];
  }
}
