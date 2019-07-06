import 'package:bubble/sharedPreferencesHelper.dart';
import 'package:flutter/material.dart';
import 'package:bubble/webHelper.dart';
import 'menu.dart';
import 'package:bubble/main.dart';

class SettingsMenu extends StatefulWidget {
  @override
  _SettingsMenuState createState() => _SettingsMenuState();
}

class _SettingsMenuState extends State<SettingsMenu> {
  bool showChangeNameSection = false;
  String submitMessage = "";

  showAboutDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Column(
              children: <Widget>[
                Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.blue),
                    child: Text("About",
                        style: TextStyle(fontSize: 20, color: Colors.white))),
                FractionallySizedBox(
                  widthFactor: 0.5,
                  child: Image.asset("assets/images/logo.png"),
                ),
                Text("Bubble Twist Was Designed By",
                    style: TextStyle(fontSize: 20)),
                Text("Pink Fedora Programming", style: TextStyle(fontSize: 20)),
                FlatButton(
                  onPressed: () {
                    WebHelper.launchURL("http://pinkfedora.net");
                  },
                  child: Text("pinkfedora.net",
                      style: TextStyle(
                          fontSize: 17,
                          color: Colors.blue,
                          decoration: TextDecoration.underline)),
                ),
                Expanded(
                    child: ListView(padding: EdgeInsets.all(5), children: [
                  RaisedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Cool",
                          style: TextStyle(color: Colors.white, fontSize: 18)),
                      color: Colors.green),
                ]))
              ],
            ),
          );
        });
  }

  showNotificationsComingSoonDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new Dialog(
            child: IntrinsicHeight(
                child: Column(
              children: [
                Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.blue),
                    child: Text("Coming Soon",
                        style: TextStyle(fontSize: 20, color: Colors.white))),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    "Be notified as soon as a friend beats you score. Available in the next update.",
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RaisedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text("Cool.",
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                        color: Colors.green),
                  ),
                ),
              ],
            )),
          );
        });
  }

  showSoundsComingSoonDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new Dialog(
            child: IntrinsicHeight(
                child: Column(
              children: [
                Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.blue),
                    child: Text("Coming Soon",
                        style: TextStyle(fontSize: 20, color: Colors.white))),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    "Sounds available in a future update.",
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RaisedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text("Cool.",
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                        color: Colors.green),
                  ),
                ),
              ],
            )),
          );
        });
  }

  showHowToPlayDialog() {
    var widgets = [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: FractionallySizedBox(
          widthFactor: 0.25,
          child: Image.asset("assets/appicon.png"),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("Todo. Write tutorial", style: TextStyle(fontSize: 20)),
      ),
      RaisedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Close",
              style: TextStyle(color: Colors.white, fontSize: 18)),
          color: Colors.green),
      SizedBox(height: 25)
    ];

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

  Future<bool> _submitNameChange(String s) async {
    if (s.length < 3) {
      setState(() {
        submitMessage = "Name must be at least 3 characters";
      });
      return false;
    } else {
      setState(() {
        submitMessage = "Submitting...";
      });
      String response = "";
      WebHelperResponse whr = await WebHelper.updateName(s);
      if (!whr.connected)
        response = "Couldn't Connect To Server";
      else if (whr.response == "badname")
        response = "Server Declined Your Display Name";
      else if (whr.response == "true") {
        response = "Your Display Name Has Been Changed To $s";
        SharedPreferencesHelper.setUsername(s);
      } else
        response = "There was an error processing you request.";
      setState(() {
        submitMessage = response;
      });
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
            decoration: BoxDecoration(color: Colors.white30),
            child: ListView(shrinkWrap: true, children: [
              Divider(),
              showChangeNameSection
                  ? Container(
                      padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
                      child: Column(
                        children: <Widget>[
                          Text(
                            "Change Name",
                            style: TextStyle(fontSize: 25),
                            textAlign: TextAlign.center,
                          ),
                          NameInputField(
                            buttonText: "Change Name",
                            buttonAction: _submitNameChange,
                            message: submitMessage,
                          ),
                        ],
                      ),
                    )
                  : ListTile(
                      onTap: () {
                        setState(() {
                          showChangeNameSection = true;
                        });
                      },
                      title:
                          Text("Change Name", style: TextStyle(fontSize: 20)),
                    ),
              Divider(),
              ListTile(
                onTap: showAboutDialog,
                title: Text("About", style: TextStyle(fontSize: 20)),
              ),
              Divider(),
              ListTile(
                onTap: () {
                  Game.showTutorial(context);
                },
                title: Text("How To Play", style: TextStyle(fontSize: 20)),
              ),
              Divider(),
              ListTile(
                onTap: () {
                  Game.showPrivacyAgreement(context);
                },
                title: Text("Privacy", style: TextStyle(fontSize: 20)),
              ),
              Divider(),
              ListTile(
                onTap: () {
                  showNotificationsComingSoonDialog();
                },
                title: Text("Notifications", style: TextStyle(fontSize: 20)),
              ),
              Divider(),
              ListTile(
                onTap: () {
                  showSoundsComingSoonDialog();
                },
                title: Text("Sounds", style: TextStyle(fontSize: 20)),
              ),
              Divider(),
            ])));
  }
}
