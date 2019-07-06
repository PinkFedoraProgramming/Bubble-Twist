import 'package:flame/position.dart';
import 'main.dart';
import 'bubbles.dart';
import 'package:flutter/material.dart';
import 'damienMath.dart';
import 'package:flame/sprite.dart';

class Player {
  Game game;
  int score = 0;
  int multiplier = 1;
  int bubbleFired = 0;
  int nextStrikes = 5;
  int strikes = 6;
  int nextColor = 0;

  bool fired = false;

  double a = 180;
  Sprite arrow;

  Bubble currentBubble;

  Player(this.game) {
    newCurrentBubble();
    arrow = Sprite("arrow.png");
  }

  render(Canvas c) {
    currentBubble.render(c);

    Bubble next = Bubble.spawn(game, game.bubbles.spawnX,
        game.bubbles.spawnY - Bubbles.br * 2.25, nextColor);
    next.render(c);

    c.save();

    c.translate(game.bubbles.spawnX, game.bubbles.spawnY);
    c.rotate(DamienMath.toRadians(a));
    c.translate(-game.bubbles.spawnX, -game.bubbles.spawnY);

    double arrowWidth = Bubbles.br * 1.25;
    double arrowHeight = Bubbles.br * 4 * 1.25;

    arrow.renderPosition(
        c,
        Position(game.bubbles.spawnX - arrowWidth / 2,
            game.bubbles.spawnY - arrowHeight * 1.25),
        Position(arrowWidth, arrowHeight));

    c.restore();

    //Draw Strikes
    Paint p = new Paint();
    p.color = Colors.yellow;
    for (int i = 0; i < strikes; i++) {
      c.drawCircle(
          Offset(Bubbles.br * 2 + (Bubbles.br * 2.5 * i),
              game.walls[3].top + Bubbles.br * 2),
          Bubbles.br,
          p);
    }

    if (multiplier < 2) return;
    TextPainter tp = TextPainter(
        text: TextSpan(
            style: TextStyle(
                color: Colors.purple,
                fontWeight: FontWeight.bold,
                fontSize: Bubbles.br * 2),
            text: "X" + multiplier.toString()),
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(
        c,
        Offset(game.size.width - Bubbles.br - tp.width,
            game.walls[1].bottom + Bubbles.br * 1));
  }

  tick() {
    if (currentBubble.xv == 0 &&
        currentBubble.yv == 0 &&
        fired &&
        game.bubbles.checkPopFor == null) {
      newCurrentBubble();
    }
    currentBubble.tick();
  }

  onTap() {
    if (fired) return;
    fired = true;
    currentBubble.xv = DamienMath.getXOfAngle(a) * Bubbles.bSpeed;
    currentBubble.yv = DamienMath.getYOfAngle(a) * Bubbles.bSpeed;
  }

  onDrag(double x, double y) {
    double newA =
        DamienMath.getAngle(game.bubbles.spawnX, game.bubbles.spawnY, x, y);

    if (newA > 260) newA = 260;
    if (newA < 100) newA = 100;

    a = newA;
  }

  void addPoints(int points) {
    score += points * multiplier;
    game.wrapper.setScore(score);
  }

  void newCurrentBubble() {
    fired = false;
    currentBubble = new Bubble.shoot(
        game, game.bubbles.spawnX, game.bubbles.spawnY, 0, 0, nextColor);
    List<int> colors = game.bubbles.getAvailableColors();
    nextColor = colors[DamienMath.randInt(0, colors.length - 1)];
  }

  void strike() {
    strikes--;
    if (strikes == 0) {
      game.bubbles.pileOnBubbles();
      strikes = nextStrikes;
      nextStrikes--;
      if (nextStrikes == 0) nextStrikes = 6;
    }
  }

  void reset() {
    score = 0;
    multiplier = 1;
    bubbleFired = 0;
    nextStrikes = 5;
    strikes = 6;
    newCurrentBubble();
    game.wrapper.setScore(score);
  }
}
