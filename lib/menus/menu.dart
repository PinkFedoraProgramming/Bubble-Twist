import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../sharedPreferencesHelper.dart';
import 'gameMenu.dart';
import 'leaderboard.dart';
import 'settingsMenu.dart';
import '../webHelper.dart';

class Menu extends StatefulWidget {
  bool gameover;
  int score;
  Menu({this.score, this.gameover});

  @override
  _MenuState createState() => _MenuState();

  static _MenuState of(BuildContext context) {
    final state = context.ancestorStateOfType(TypeMatcher<_MenuState>());
    return state;
  }
}

class _MenuState extends State<Menu> with TickerProviderStateMixin {
  TabController tabController;
  int lastIndex = 0;
  String tabName = "Menu";
  bool submitted = false;

  _MenuState() {
    tabController = new TabController(length: 3, vsync: this);
    tabController.addListener(onTabChange);
    onTabChange();
  }

  initState() {
    super.initState();
    tabName = (widget.gameover ? "Previous" : "Current") + " Game";
  }

  onTabChange() {
    int index = tabController.index;
    print("onTabChangeCalled. Index is $index");
    if (index != lastIndex) {
      lastIndex = index;
      setState(() {
        switch (tabController.index) {
          case 0:
            tabName = (widget.gameover ? "Previous" : "Current") + " Game";
            break;
          case 1:
            tabName = "Leaderboards";
            break;
          case 2:
            tabName = "Settings";
            break;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          backgroundColor: Color(0xFF73BBEA),
          appBar: AppBar(
            title: Text(
              tabName,
              style: TextStyle(fontSize: 25),
            ),
            backgroundColor: Colors.blue,
          ),
          bottomNavigationBar: Material(
            color: Colors.blue,
            child: TabBar(
              labelColor: Colors.yellow,
              unselectedLabelColor: Colors.yellow,
              controller: tabController,
              tabs: [
                Tab(icon: Icon(Icons.videogame_asset)),
                Tab(icon: Icon(Icons.score)),
                Tab(icon: Icon(Icons.settings)),
              ],
            ),
          ),
          body: DefaultTextStyle(
            style: TextStyle(color: Colors.white),
            child: TabBarView(controller: tabController, children: [
              Column(
                children: <Widget>[
                  GameMenu(score: widget.score, gameover: widget.gameover),
                ],
              ),
              Column(
                children: <Widget>[
                  Leaderboard(),
                ],
              ),
              Column(children: [SettingsMenu()]),
            ]),
          )),
    );
  }
}

class MenuButton extends StatelessWidget {
  final String text;
  final Function action;
  MenuButton({@required this.text, @required this.action});

  @override
  Widget build(BuildContext context) {
    return new RaisedButton(
        padding: EdgeInsets.all(10),
        onPressed: action,
        shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(20.0)),
        child: Text(text, style: TextStyle(color: Colors.white, fontSize: 20)),
        color: Colors.blue);
  }
}

class NameInputField extends StatefulWidget {
  String buttonText;
  Future<bool> Function(String) buttonAction;
  String message;

  NameInputField(
      {this.buttonText = "Submit", this.buttonAction, this.message = ""}) {
    if (this.buttonAction == null)
      this.buttonAction = (String s) async {
        return true;
      };
  }

  @override
  _NameInputFieldState createState() => _NameInputFieldState();
}

class _NameInputFieldState extends State<NameInputField> {
  final TextEditingController _controller = new TextEditingController(text: '');

  _NameInputFieldState() {
    SharedPreferencesHelper.getUsername().then((u) => _controller.text = u);
  }

  buttonPressed() async {
    String s = _controller.text;
    bool result = await widget.buttonAction(s);
    if (result) {
      SharedPreferencesHelper.setUsername(s);
      if (_controller.text != s.toUpperCase()) {
        var selection = _controller.selection;
        _controller.text = s.toUpperCase();
        _controller.selection = selection;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5),
      child: DecoratedBox(
        decoration: BoxDecoration(color: Colors.white30),
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Column(
            children: <Widget>[
              TextField(
                maxLength: 10,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30),
                textCapitalization: TextCapitalization.characters,
                controller: _controller,
                autocorrect: false,
                inputFormatters: [
                  WhitelistingTextInputFormatter(RegExp("[A-Za-z0-9_\\-!]"))
                ],
              ),
              MaterialButton(
                child: Text(widget.buttonText,
                    style: TextStyle(color: Colors.white)),
                onPressed: buttonPressed,
                color: Colors.blue,
              ),
              Text(widget.message ?? "",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class FriendCodeInputField extends StatefulWidget {
  final String message;
  Function action;
  FriendCodeInputField({this.message, this.action}) {
    if (action == null) action = (_) => {};
  }

  @override
  _FriendCodeInputFieldState createState() => _FriendCodeInputFieldState();
}

class _FriendCodeInputFieldState extends State<FriendCodeInputField> {
  final TextEditingController _controller = new TextEditingController(text: '');
  String friendCode = "";
  String message = "";

  _FriendCodeInputFieldState() {
    SharedPreferencesHelper.getFriendCode().then((fc) => setState(() {
          friendCode = fc;
        }));
  }

  initState() {
    super.initState();
    message = widget.message;
  }

  buttonPressed() async {
    setState(() {
      message = "Submitting...";
    });

    String s = _controller.text;
    var response = await WebHelper.addFriend(int.parse(s));
    setState(() {
      if (!response.connected)
        message = "Couldn't connect to server";
      else if (response.response == "false")
        message = "Invalid friend code.";
      else if (response.response == "true") {
        message = "Added Friend.";
        widget.action();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (friendCode == "") {
      return new Container();
    }

    return Padding(
      padding: EdgeInsets.all(5),
      child: DecoratedBox(
        decoration: BoxDecoration(color: Colors.white30),
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Column(
            children: <Widget>[
              Text(
                "This is your Friend Code: $friendCode",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              Text(
                "Exchange Friend Codes to track your friend's scores",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              TextField(
                keyboardType: TextInputType.number,
                maxLength: 12,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30),
                textCapitalization: TextCapitalization.characters,
                controller: _controller,
                autocorrect: false,
                inputFormatters: [
                  WhitelistingTextInputFormatter(RegExp("[0-9]"))
                ],
              ),
              MaterialButton(
                child:
                    Text("Add Friend", style: TextStyle(color: Colors.white)),
                onPressed: buttonPressed,
                color: Colors.blue,
              ),
              Text(message,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
