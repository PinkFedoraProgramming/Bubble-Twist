import 'package:flame/position.dart';
import 'package:flutter/material.dart';
import 'package:flame/sprite.dart';
import 'main.dart';
import 'damienMath.dart';

class Bubbles {
  final Game game;
  static double br; // Bubble Radius
  static double bSpeed; // Bubble Speed
  final List<Bubble> bubbles = new List<Bubble>();
  final List<Bubble> flyingBubbles = new List<Bubble>();
  Bubble anchor;
  double rotation = 0;
  double rv = 0; //Rotational Velocity

  int bubblesToPileOn = 0;

  double spawnX;
  double spawnY;

  Bubble checkPopFor;
  int popDelay = 0;

  int previousBubbles = -1;

  Bubbles(this.game) {
    br = game.size.width / 35;

    bSpeed = br * 1.25;

    anchor = new Ancor(game, game.size.width / 2, game.size.height / 2);

    spawnX = game.size.width / 2;
    spawnY = game.walls[1].bottom - br;
    generateGame();
  }

  render(Canvas c) {
    bubbles.forEach((b) => b.render(c));

    flyingBubbles.forEach((f) => f.render(c));
  }

  tick() {
    rotation += rv;
    rotateAll(rv);

    if (previousBubbles != bubbles.length) {
      previousBubbles = bubbles.length;
    }

    if (checkPopFor != null) {
      if (popDelay <= 0) {
        if (!game.bubbles.doPops(checkPopFor)) game.player.strike();
        checkPopFor = null;
      } else
        popDelay--;
    }

    bubbles.forEach((b) => b.tick());
    flyingBubbles.forEach((f) => f.tick());

    if (rv > 0.03 || rv < -0.03) {
      rv *= 0.98;
    } else {
      rv = 0;
    }

    if (bubblesToPileOn > 0 && DamienMath.randChance(25)) {
      bubblesToPileOn--;
      bool left = DamienMath.randBoolean();
      double x =
          left ? game.walls[0].right + br * 2 : game.walls[2].left - br * 2;
      double y = DamienMath.randInt(
              game.walls[1].bottom + br * 2, game.walls[3].top - br * 2)
          .toDouble();
      double angleToCenter = DamienMath.getAngle(x, y, anchor.x, anchor.y);
      double xv = DamienMath.getXOfAngle(angleToCenter) * bSpeed;
      double yv = DamienMath.getYOfAngle(angleToCenter) * bSpeed;

      flyingBubbles
          .add(new Bubble(game, x, y, xv, yv, getRandAvailableColor(), false));
    }

    if (bubbles.length <= 1) {
      generateGame();
      rv = DamienMath.randDouble(5, 7);
      game.player.multiplier++;
    }
  }

  generateGame() {
    flyingBubbles.clear();
    bubbles.clear();
    bubbles.add(anchor);
    rotation = 0;
    rv = DamienMath.randDouble(3, 6);
    if (DamienMath.randBoolean()) rv *= -1;

    final int layers = 6;

    for (int i = 1; i < layers; i++) {
      double bubblesInLayer = i * 6.0;
      for (int ii = 0; ii < bubblesInLayer; ii++) {
        double angleFromCenter = (360.0 / bubblesInLayer) * ii;
        Bubble b = new Bubble.spawn(
            game,
            anchor.x + DamienMath.getXOfAngle(angleFromCenter) * br * 2 * i,
            anchor.y + DamienMath.getYOfAngle(angleFromCenter) * br * 2 * i,
            DamienMath.randInt(0, 5));

        bubbles.add(b);

        for (int iii = 0; iii < i - 1; iii++) {
          ii++;
          double angle = 120 + (60 * (ii ~/ i)).toDouble();

          Bubble b2 = new Bubble.spawn(
              game,
              b.x + (DamienMath.getXOfAngle(angle) * br * 2 * (iii + 1)),
              b.y + (DamienMath.getYOfAngle(angle) * br * 2 * (iii + 1)),
              DamienMath.randInt(0, 5));
          bubbles.add(b2);
        }
      }
    }
    previousBubbles = -1;
  }

  rotateAll(double amount) {
    bubbles.forEach((b) {
      List<double> newLoc =
          DamienMath.rotatePoint(b.x, b.y, anchor.x, anchor.y, amount);
      b.x = newLoc[0];
      b.y = newLoc[1];
    });
  }

  getAvailableColors() {
    List<int> colors = [];
    for (int i = 0; i < bubbles.length; i++) {
      if (!colors.contains(bubbles[i].color) &&
          bubbles[i].color != -1 &&
          bubbles[i] != checkPopFor) colors.add(bubbles[i].color);
    }
    return colors;
  }

  getRandAvailableColor() {
    var colors = getAvailableColors();
    return colors[DamienMath.randInt(0, colors.length - 1)];
  }

  Bubble getBubbleAt(double x, double y) {
    for (int i = 0; i < bubbles.length; i++) {
      if (DamienMath.distanceBetween(x, y, bubbles[i].x, bubbles[i].y) < br)
        return bubbles[i];
    }
    return null;
  }

  void removeFloating() {
    List<Bubble> attached = [];
    attached.add(anchor);
    List<Bubble> toCheck = [];
    toCheck.add(anchor);
    while (toCheck.length > 0) {
      for (int i = 0; i < toCheck.length; i++) {
        Bubble b2 = toCheck[i];
        for (int ii = 0; ii < 6; ii++) {
          Bubble b3 = getBubbleAt(
              b2.x + (DamienMath.getXOfAngle(rotation + (ii * 60)) * br * 2),
              b2.y + DamienMath.getYOfAngle(rotation + (ii * 60)) * br * 2);
          if (b3 != null) {
            if (!attached.contains(b3)) {
              attached.add(b3);
              toCheck.add(b3);
            }
          }
        }
        toCheck.remove(b2);
      }
    }
    for (int i = 0; i < bubbles.length; i++) {
      Bubble b = bubbles[i];
      if (!attached.contains(b)) {
        popBubble(b);
        i--;
      }
    }
  }

  bool doPops(Bubble b) {
    bool popedAny = false;
    List<Bubble> inPop = [];
    inPop.add(b);
    List<Bubble> toCheck = [];
    toCheck.add(b);
    List<Bubble> checked = [];
    while (toCheck.length > 0) {
      for (int i = 0; i < toCheck.length; i++) {
        Bubble b2 = toCheck[i];
        for (int ii = 0; ii < 6; ii++) {
          Bubble b3 = getBubbleAt(
              b2.x + (DamienMath.getXOfAngle(rotation + (ii * 60)) * br * 2),
              b2.y + DamienMath.getYOfAngle(rotation + (ii * 60)) * br * 2);
          if (b3 != null && b3.color == b.color && !checked.contains(b3)) {
            inPop.add(b3);
            toCheck.add(b3);
          }
        }
        checked.add(b2);
        toCheck.remove(b2);
      }
    }

    if (inPop.length >= 3) {
      for (int i = 0; i < inPop.length; i++) {
        popBubble(inPop[i]);
        popedAny = true;
      }
      removeFloating();
    }

    return popedAny;
  }

  getSpaces(Bubble b) {
    List<Bubble> spaces = [];
    for (int ii = 0; ii < 6; ii++) {
      double x = b.x + (DamienMath.getXOfAngle(rotation + (ii * 60)) * br * 2);
      double y = b.y + (DamienMath.getYOfAngle(rotation + (ii * 60)) * br * 2);
      if (canPlaceByPosition(x, y)) {
        spaces.add(new Bubble.spawn(game, x, y, -1));
      }
    }
    return spaces;
  }

  bool canPlace(Bubble b) {
    for (int i = 0; i < bubbles.length; i++) {
      Bubble b2 = bubbles[i];

      if (b.intersects(b2)) {
        return false;
      }
    }
    return true;
  }

  bool canPlaceByPosition(double x, double y) {
    for (int i = 0; i < bubbles.length; i++) {
      if (DamienMath.distanceBetween(x, y, bubbles[i].x, bubbles[i].y) <
          (br - 1) * 2) return false;
    }
    return true;
  }

  void popBubble(Bubble b) {
    if (b == anchor) return;
    bubbles.remove(b);

    game.player.addPoints(game.player.multiplier);
    game.floatingNumbers.create(b.x, b.y, game.player.multiplier, b.color);
  }

  void pileOnBubbles() {
    bubblesToPileOn = DamienMath.randInt(4, 8);
  }
}

class Bubble {
  final Game game;
  double x;
  double y;
  double xv;
  double yv;
  final int color;
  Sprite sprite;
  final bool shotByPlayer;
  int bounces = 0;

  Bubble(this.game, this.x, this.y, this.xv, this.yv, this.color,
      this.shotByPlayer) {
    if (color != -1) sprite = game.bubbleSprites[color];
  }

  factory Bubble.spawn(Game game, double x, double y, int c) {
    return new Bubble(game, x, y, 0, 0, c, false);
  }

  factory Bubble.shoot(
      Game game, double x, double y, double xv, double yv, int c) {
    return new Bubble(game, x, y, xv, yv, c, true);
  }

  factory Bubble.pile(
      Game game, double x, double y, double xv, double yv, int c) {
    return new Bubble(game, x, y, xv, yv, c, false);
  }

  render(Canvas canvas) {
    double radius = Bubbles.br * 0.95;

    sprite.renderCentered(
        canvas, Position(x, y), Position(radius * 2, radius * 2));
  }

  tick() {
    if (xv != 0 || yv != 0) {
      x += xv;
      y += yv;

      for (int i = 0; i < game.bubbles.bubbles.length; i++) {
        Bubble b = game.bubbles.bubbles[i];
        if (b == this) return;
        if (intersects(b)) {
          double angleToCenter = DamienMath.getAngle(
              x, y, game.bubbles.anchor.x, game.bubbles.anchor.y);
          double velocityAngle = DamienMath.getAngle(x, y, x + xv, y + yv);
          double differenceValue = velocityAngle - angleToCenter;

          if (angleToCenter > 180)
            angleToCenter -= 360;
          else if (angleToCenter < -180) angleToCenter += 360;

          if (velocityAngle > 180)
            velocityAngle -= 360;
          else if (velocityAngle < -180) velocityAngle += 360;

          if (differenceValue > 180)
            differenceValue -= 360;
          else if (differenceValue < -180) differenceValue += 360;

          game.bubbles.rv += differenceValue * -0.03;
          xv = 0;
          yv = 0;
          Bubble closestSpace;
          double closestDistance = 0;
          List<Bubble> spaces = game.bubbles.getSpaces(b);
          for (int ii = 0; ii < spaces.length; ii++) {
            Bubble s = spaces[ii];
            double distanceToSpace = DamienMath.distanceBetween(x, y, s.x, s.y);
            if (closestSpace == null || distanceToSpace < closestDistance) {
              closestSpace = s;
              closestDistance = distanceToSpace;
              continue;
            }
          }
          x = closestSpace.x;
          y = closestSpace.y;
          game.bubbles.flyingBubbles.remove(this);
          game.bubbles.bubbles.add(this);
          if (shotByPlayer) {
            game.bubbles.checkPopFor = this;
            game.bubbles.popDelay = 1;
          }
        }
      }

      if (!(getArea().overlaps(game.walls[1]) && shotByPlayer && yv > 0)) {
        if (getArea().overlaps(game.walls[0]) ||
            getArea().overlaps(game.walls[2])) {
          xv *= -1;
          bounces++;
        }
        if (getArea().overlaps(game.walls[1]) ||
            getArea().overlaps(game.walls[3])) {
          yv *= -1;
          bounces++;
        }
      }
      if (bounces >= 8) {
        game.player.strike();
        game.player.newCurrentBubble();
      }
    } else if (game.bubbles.bubbles.contains(this) &&
        game.bubbles.checkPopFor != this) {
      Rect area = getArea();
      game.walls.forEach((w) {
        if (area.overlaps(w)) {
          game.gameover();
        }
      });
    }
  }

  bool intersects(Bubble B) {
    return DamienMath.distanceBetween(x, y, B.x, B.y) < (Bubbles.br - 1) * 2;
  }

  Rect getArea() {
    return Rect.fromLTWH(
        x - Bubbles.br, y - Bubbles.br, Bubbles.br * 2, Bubbles.br * 2);
  }
}

class Ancor extends Bubble {
  Ancor(Game game, double x, double y) : super(game, x, y, 0, 0, -1, false) {
    this.sprite = Sprite("anchor.png");
  }
}
