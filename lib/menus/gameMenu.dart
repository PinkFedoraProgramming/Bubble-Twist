import 'package:flutter/material.dart';
import 'package:bubble/sharedPreferencesHelper.dart';
import 'menu.dart';
import 'package:bubble/webHelper.dart';

class GameMenu extends StatefulWidget {
  bool gameover;
  int score;
  GameMenu({this.score, this.gameover});

  @override
  _GameMenuState createState() => _GameMenuState();
}

class _GameMenuState extends State<GameMenu> {
  String submitMessage = "";
  bool showSubmitScore = false;

  @override
  initState() {
    super.initState();
    initTrySubmit();
    return;
  }

  initTrySubmit() async {
    if (!widget.gameover || Menu.of(context).submitted) return;

    setNeedsInput() {
      setState(() {
        showSubmitScore = true;
      });
    }

    String username = await SharedPreferencesHelper.getUsername();
    if (username == "")
      setNeedsInput();
    else {
      bool result = await submitScore(username);
      if (!result) setNeedsInput();
    }
  }

  Future<bool> submitScore(String text) async {
    setState(() {
      submitMessage = "Submiting...";
    });

    if (text.length < 3) {
      setState(() {
        submitMessage = "Name must be at least 3 characters";
      });
      return false;
    }
    var whr = await WebHelper.postScore(text, widget.score);

    if (!whr.connected) {
      submitMessage = "Couldn't Connect To Server";
      showSubmitScore = true;
      return false;
    } else if (whr.response == "badname") {
      submitMessage = "Server Declined Your Display Name";
      showSubmitScore = true;
      return false;
    } else if (whr.response == "false") {
      submitMessage = "Server Declined To Post";
      showSubmitScore = true;
      return false;
    }
    Menu.of(context).submitted = true;
    setState(() {
      submitMessage = whr.response;
      SharedPreferencesHelper.setUsername(text);
    });
    SharedPreferencesHelper.postScore(widget.score);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    Widget buildGameDetailsSection() {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: IntrinsicWidth(
            child: new Table(
              columnWidths: {
                0: IntrinsicColumnWidth(flex: 1),
                1: IntrinsicColumnWidth(flex: 1)
              },
              children: [
                TableRow(
                  children: [
                    TableCell(
                        child: Padding(
                            padding: EdgeInsets.fromLTRB(5, 5, 40, 5),
                            child: Text("Score:"))),
                    TableCell(
                        child: Padding(
                            padding: EdgeInsets.all(5),
                            child: Text("${widget.score}")))
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget buildControlsSection() {
      List<Widget> controlWidgets = [];
      print("Show submit score $showSubmitScore");
      if (widget.gameover && !Menu.of(context).submitted && showSubmitScore) {
        controlWidgets.add(NameInputField(
          buttonText: "Submit Score",
          buttonAction: submitScore,
          message: submitMessage,
        ));
      }
      if (!showSubmitScore)
        controlWidgets.add(Text(submitMessage ?? "",
            style: TextStyle(
              fontSize: 18,
              color: Colors.red,
            ),
            textAlign: TextAlign.center));

      controlWidgets.add(MenuButton(
        text: widget.gameover ? "New Game" : "Return To Game",
        action: () {
          Navigator.pop(context);
        },
      ));

      return Column(
        children: controlWidgets,
      );
    }

    return Expanded(
      child: DefaultTextStyle(
        style: new TextStyle(fontSize: 25, color: Colors.black),
        child: Container(
          decoration: BoxDecoration(color: Colors.white30),
          child: ListView(children: [
            buildGameDetailsSection(),
            buildControlsSection(),
          ]),
        ),
      ),
    );
  }
}
