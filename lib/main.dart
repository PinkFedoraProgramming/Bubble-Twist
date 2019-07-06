import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'bubbles.dart';
import 'player.dart';
import 'floatingNumbers.dart';
import 'adHelper.dart';
import 'menus/menu.dart';
import 'webHelper.dart';
import 'sharedPreferencesHelper.dart';

void main() async {
  await AdHelper.init();
  runApp(MyApp(await Flame.util.initialDimensions()));
  AdHelper.showBanner();
  Future.delayed(Duration(seconds: 30), () {
    AdHelper.loadAd();
  });
}

class MyApp extends StatelessWidget {
  Game game;

  MyApp(Size dimensions) {
    game = new Game(dimensions);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Bubble Twist',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          backgroundColor: Colors.green,
          body: Container(child: GameWrapper(game)),
        ));
  }
}

class Game extends BaseGame {
  Bubbles bubbles;
  Player player;
  FloatingNumbers floatingNumbers;
  double creationTimer = 0.0;
  Size size;
  List<Rect> walls = [];
  _GameWrapperState wrapper;

  List<Sprite> bubbleSprites;

  static final Color backgroundColor = Color(0xFFFAFAFA);

  bool gameoverCalled = false;

  Game(this.size) {
    bubbleSprites = [
      Sprite("red.png"),
      Sprite("navy.png"),
      Sprite("cyan.png"),
      Sprite("pink.png"),
      Sprite("yellow.png"),
      Sprite("green.png")
    ];

    walls.addAll([
      Rect.fromLTRB(0, 0, 5, size.height), //LEFT
      Rect.fromLTWH(0, 0, size.width, size.height / 2 - size.width / 2), //TOP
      Rect.fromLTRB(size.width - 5, 0, size.width, size.height), //RIGHT
      Rect.fromLTWH(0, size.height / 2 + size.width / 2, size.width,
          size.height / 2), //BOTTOM
    ]);

    bubbles = new Bubbles(this);
    player = new Player(this);
    floatingNumbers = new FloatingNumbers(this);
  }

  @override
  void render(Canvas c) {
    super.render(c);
    Paint p = new Paint();
    p.color = backgroundColor;
    c.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), p);
    p.color = Colors.blue;
    walls.forEach((w) => c.drawRect(w, p));
    p.color = backgroundColor;
    c.drawCircle(Offset(bubbles.spawnX, walls[1].bottom), Bubbles.br * 5, p);
    bubbles.render(c);
    player.render(c);
    floatingNumbers.render(c);
  }

  @override
  void update(double t) {
    this.creationTimer += t;
    if (this.creationTimer >= 0.015) {
      this.creationTimer = 0.0;

      if (gameoverCalled) {
        gameoverCalled = false;
        wrapper.showMenu(player.score, gameover: true);
        reset();
        AdHelper.showAd();
      }

      bubbles.tick();
      player.tick();
      floatingNumbers.tick();
      super.update(t);
    }
  }

  onTap() {
    player.onTap();
  }

  onDragUpdate(DragUpdateDetails dud) {
    player.onDrag(dud.globalPosition.dx, dud.globalPosition.dy);
  }

  gameover() {
    gameoverCalled = true;
  }

  static Color colorFromInt(int colorInt) {
    switch (colorInt) {
      case 0:
        return new Color(0xFFFF0000);
        break;
      case 1:
        return new Color(0xFF0003CC);
        break;
      case 2:
        return new Color(0xFF00F6FA);
        break;
      case 3:
        return new Color(0xFFFF52C2);
        break;
      case 4:
        return new Color(0xFFFFFF08);
        break;
      case 5:
        return new Color(0xFF00D111);
        break;
    }
    return null;
  }

  Sprite spriteFromInt(int colorInt) {
    if (colorInt == -1) return Sprite("ancor.png");
    return bubbleSprites[colorInt];
  }

  reset() {
    player.reset();
    bubbles.generateGame();
  }

  static void showTutorial(BuildContext context) {
    List<String> tutorialStrings = [
      "In Bubble Twist you have to shoot and match colored bubbles. ",
      "Matching 3 or more bubbles of the same color will pop them and add to your points. Bubbles shot that don't result in any pop will take one of your strikes, each time you run out of strikes more bubbles will pile on.",
      "Each time you eliminate all of the bubbles you'll get a new mass of bubbles and your multiplier will increase by 1 so future pops will be worth more! Try to get the highest score, good luck!"
    ];

    List<Widget> tutorialTexts = [];
    tutorialStrings.forEach((s) {
      tutorialTexts.add(new Padding(
          padding: EdgeInsets.all(8),
          child: Text(s, style: TextStyle(fontSize: 20))));
    });

    List<Widget> widgets = [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: FractionallySizedBox(
          widthFactor: 0.25,
          child: Image.asset("assets/appicon.png"),
        ),
      ),
    ]
      ..addAll(tutorialTexts)
      ..addAll([
        RaisedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Close",
                style: TextStyle(color: Colors.white, fontSize: 18)),
            color: Colors.green),
        SizedBox(height: 100)
      ]);

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.blue),
                    child: Text("How To Play",
                        style: TextStyle(fontSize: 20, color: Colors.white))),
                Expanded(
                    child: ListView.builder(
                  itemCount: widgets.length,
                  itemBuilder: (BuildContext content, int index) {
                    return widgets[index];
                  },
                ))
              ],
            ),
          );
        });
  }

  static void showPrivacyAgreement(BuildContext context) {
    List<String> tutorialStrings = [
      "Bubble Twist uses a global leaderboard for players to compete in high scores. Your displayed name on this leaderboard can be chosen the first time you submit a score and can be changed any time in the settings menu.",
      "By choosing 'I agree' you agree to the collection of your display name and scores for use in the global leaderboard.",
      "",
      "The full privacy policy for Bubble Twist can be accessed at",
    ];

    List<Widget> tutorialTexts = [];
    tutorialStrings.forEach((s) {
      tutorialTexts.add(new Padding(
          padding: EdgeInsets.all(8),
          child: Text(s, style: TextStyle(fontSize: 20))));
    });

    List<Widget> widgets = [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: FractionallySizedBox(
          widthFactor: 0.25,
          child: Image.asset("assets/appicon.png"),
        ),
      ),
    ]
      ..addAll(tutorialTexts)
      ..addAll([
        FlatButton(
          onPressed: () {
            WebHelper.launchURL("https://pinkfedora.net/bubbles/privacy/");
          },
          child: Text("pinkfedora.net/bubbles/privacy/",
              style: TextStyle(
                  fontSize: 17,
                  color: Colors.blue,
                  decoration: TextDecoration.underline)),
        ),
        RaisedButton(
            onPressed: () {
              SharedPreferencesHelper.setLeaderboardConcent(true);
              Navigator.of(context).pop();
            },
            child: Text("I Agree",
                style: TextStyle(color: Colors.white, fontSize: 18)),
            color: Colors.green),
        SizedBox(height: 100)
      ]);

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.blue),
                    child: Text("Leadboards",
                        style: TextStyle(fontSize: 20, color: Colors.white))),
                Expanded(
                    child: ListView.builder(
                  itemCount: widgets.length,
                  itemBuilder: (BuildContext content, int index) {
                    return widgets[index];
                  },
                ))
              ],
            ),
          );
        });
  }
}

class GameWrapper extends StatefulWidget {
  final Game game;
  GameWrapper(this.game);

  @override
  _GameWrapperState createState() => _GameWrapperState();
}

class _GameWrapperState extends State<GameWrapper> {
  int score = 0;

  initState() {
    super.initState();
    widget.game.wrapper = this;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SharedPreferencesHelper.getLeaderboardConcent().then((c) {
      if (!c) Game.showPrivacyAgreement(context);
    });
  }

  setScore(int newScore) {
    setState(() {
      score = newScore;
    });
  }

  void showMenu(int score, {bool gameover = false}) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: new Dialog(child: Menu(score: score, gameover: gameover)),
          );
        });
  }

  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragUpdate: widget.game.onDragUpdate,
              onVerticalDragUpdate: widget.game.onDragUpdate,
              onTap: widget.game.onTap,
              child: widget.game.widget),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: CircleButton(
                  color: Colors.purple,
                  iconColor: Colors.white,
                  iconData: Icons.refresh,
                  iconSize: 25,
                  onTap: widget.game.reset,
                ),
              ),
              Card(
                elevation: 10,
                child: Container(
                  width: Bubbles.br * 14,
                  height: Bubbles.br * 4,
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Text("Score: $score",
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.greenAccent, Colors.green])),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: CircleButton(
                  color: Colors.purple,
                  iconColor: Colors.white,
                  iconData: Icons.menu,
                  iconSize: 25,
                  onTap: () {
                    showMenu(widget.game.player.score);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: CircleButton(
                  color: Colors.purple,
                  iconColor: Colors.white,
                  iconData: Icons.info_outline,
                  iconSize: 25,
                  onTap: () {
                    Game.showTutorial(context);
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class CircleButton extends StatelessWidget {
  final GestureTapCallback onTap;
  final IconData iconData;
  final double iconSize;
  final Color color;
  final Color iconColor;

  const CircleButton(
      {Key key,
      this.onTap,
      this.iconData,
      this.iconSize = 24,
      this.color = Colors.white,
      this.iconColor = Colors.black})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double size = iconSize * 2;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: CircleBorder(),
      elevation: 5,
      child: new InkResponse(
        onTap: onTap,
        child: new Container(
          width: size,
          height: size,
          decoration: new BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: new Icon(iconData, color: iconColor, size: iconSize),
        ),
      ),
    );
  }
}
