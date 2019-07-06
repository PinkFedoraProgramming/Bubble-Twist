import 'package:flutter/material.dart';
import '../webHelper.dart';
import 'package:flutter/cupertino.dart';
import 'menu.dart';
import 'gameMenu.dart';
import '../sharedPreferencesHelper.dart';

class Leaderboard extends StatefulWidget {
  @override
  _LeaderboardState createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  List<String> _scores = [null, null, null, null];

  List<List<Map<String, dynamic>>> localScores = [null, null, null, null];

  int selectedTab = 3;

  @override
  void initState() {
    super.initState();
    _refreshScores();
    SharedPreferencesHelper.getHighScores("allTime").then((r) => setState(() {
          localScores[3] = r;
        }));
    SharedPreferencesHelper.getHighScores("daily").then((r) => setState(() {
          localScores[0] = r;
        }));
    SharedPreferencesHelper.getHighScores("weekly").then((r) => setState(() {
          localScores[1] = r;
        }));
    SharedPreferencesHelper.getHighScores("monthly").then((r) => setState(() {
          localScores[2] = r;
        }));
  }

  _refreshScores() {
    WebHelper.getHighscores().then((result) {
      if (result == null) {
        print("getHighscores returned null");
        return;
      }
      print("getHighScores returned: $result");

      setState(() {
        _scores[3] = result;
      });
    });

    //return; //Remove after testing
    WebHelper.getHighscores(board: "daily").then((result) {
      if (result == null) {
        print("getHighscoresDaily returned null");
        return;
      }
      print("---------");
      print("---------");
      print("---------");
      print("Get daily score response with: $result");
      print("---------");
      print("---------");
      print("---------");
      setState(() {
        _scores[0] = result;
      });
    });

    WebHelper.getHighscores(board: "weekly").then((result) {
      if (result == null) {
        print("getHighscoresWeekly returned null");
        return;
      }
      setState(() {
        _scores[1] = result;
      });
    });

    WebHelper.getHighscores(board: "monthly").then((result) {
      if (result == null) {
        print("getHighscoresMonthly returned null");
        return;
      }
      setState(() {
        _scores[2] = result;
      });
    });
  }

  _removeFriend(String name, int removeId) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: Text("Remove Friend"),
            content: Text(
                "Are you sure you want to remove $name from your friend list."),
            actions: [
              FlatButton(
                child: Text("No"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text("Yes"),
                onPressed: () {
                  WebHelper.removeFriend(removeId)
                      .then((s) => _refreshScores());
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    Widget buildScoreboardTabButton(
        {@required String text, @required Function action}) {
      return SizedBox(
        width: 70,
        child: new RaisedButton(
          padding: EdgeInsets.all(0),
          child: Text(
            text,
            style: TextStyle(color: Colors.white, fontSize: 12),
            textAlign: TextAlign.center,
            softWrap: false,
          ),
          color: Colors.blue,
          onPressed: action,
        ),
      );
    }

    Widget getTabsRow() {
      return Center(
        child: new Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          buildScoreboardTabButton(
              text: "Daily",
              action: () {
                setState(() {
                  selectedTab = 0;
                });
              }),
          buildScoreboardTabButton(
              text: "Weekly",
              action: () {
                setState(() {
                  selectedTab = 1;
                });
              }),
          buildScoreboardTabButton(
              text: "Monthly",
              action: () {
                setState(() {
                  selectedTab = 2;
                });
              }),
          buildScoreboardTabButton(
              text: "All Time",
              action: () {
                setState(() {
                  selectedTab = 3;
                });
              }),
        ]),
      );
    }

    LeaderboardTab getSelectedTab({Widget friendCodeInputField}) {
      switch (selectedTab) {
        case 0:
          return LeaderboardTab(
            title: "Daily",
            data: _scores[0],
            localData: localScores[0],
            editAction: _removeFriend,
            friendCodeInputField: friendCodeInputField,
          );
          break;
        case 1:
          return LeaderboardTab(
            title: "Weekly",
            data: _scores[1],
            localData: localScores[1],
            editAction: _removeFriend,
            friendCodeInputField: friendCodeInputField,
          );
          break;
        case 2:
          return LeaderboardTab(
            title: "Monthly",
            data: _scores[2],
            localData: localScores[2],
            editAction: _removeFriend,
            friendCodeInputField: friendCodeInputField,
          );
          break;
        case 3:
          return LeaderboardTab(
            title: "All Time",
            data: _scores[3],
            localData: localScores[3],
            editAction: _removeFriend,
            friendCodeInputField: friendCodeInputField,
          );
          break;
      }
    }

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white30,
        ),
        padding: EdgeInsets.all(0),
        child: ListView(padding: EdgeInsets.only(bottom: 500), children: [
          getTabsRow(),
          getSelectedTab(
              friendCodeInputField: FriendCodeInputField(
            message: "",
            action: _refreshScores,
          )),
        ]),
      ),
    );
  }
}

class RowData {
  final int rank;
  final String name;
  final int score;
  final bool friends;
  final bool isPlayer;
  final int removeId;
  RowData(this.rank, this.name, this.score, this.friends, this.isPlayer,
      this.removeId);

  factory RowData.fromString(String s) {
    List<String> split = s.split("|");
    bool isPlayer = false;
    if (split[1].endsWith("!")) {
      isPlayer = true;
      split[1] = split[1].substring(0, split[1].length - 1);
    }
    return new RowData(int.parse(split[0]), split[1], int.parse(split[2]),
        split[3] != "0", isPlayer, int.parse(split[3]));
  }
}

class LeaderboardTab extends StatelessWidget {
  List<Widget> children = [];
  final String title;
  Function(String, int) editAction;
  Widget friendCodeInputField;
  LeaderboardTab(
      {@required this.title,
      String data,
      List<Map<String, dynamic>> localData,
      this.editAction,
      @required this.friendCodeInputField}) {
    if (editAction == null) {
      editAction = (a, b) {};
    }

    if (data == null) {
      children.add(Text("Loading Scores...", style: TextStyle(fontSize: 25)));
      return;
    }

    List<String> split = data.split(";");
    List<RowData> allRowData = [];
    RowData player;
    split.forEach((s) {
      if (s.length > 5) {
        RowData rd = RowData.fromString(s);
        if (rd.isPlayer) player = rd;
        allRowData.add(rd);
      }
    });
    List<RowData> top10 = [];
    List<RowData> nearest10 = [];
    List<RowData> friends = [];
    List<RowData> local = [];

    allRowData.forEach((rd) {
      if (rd.rank <= 10) top10.add(rd);
      if (player != null &&
          player.rank > 10 &&
          rd.rank >= player.rank - 5 &&
          rd.rank <= player.rank + 5) nearest10.add(rd);
      if (rd.friends || rd.isPlayer) friends.add(rd);
    });

    if (localData != null) {
      localData.forEach((d) => print(d.toString()));
      localData.forEach((r) {
        local
            .add(new RowData(r['rank'], r['name'], r['score'], false, true, 0));
      });
    }

    children.add(new Scoreboard(title: "Top 10", rowData: top10));
    if (nearest10.length > 0)
      children
          .add(new Scoreboard(title: "Close Competition", rowData: nearest10));
    children.add(new Scoreboard(
        title: "Friends", rowData: friends, editAction: editAction));
    children.add(friendCodeInputField);
    if (local.length > 0)
      children.add(new Scoreboard(
        title: "Your Top Scores",
        rowData: local,
        editAction: editAction,
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
      Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30))
    ]..addAll(children));
  }
}

class Scoreboard extends StatelessWidget {
  final String title;
  Table table;
  Function(String, int) editAction;

  Scoreboard({@required this.title, List<RowData> rowData, this.editAction}) {
    List<TableRow> rows = [];
    if (editAction == null) {
      editAction = (a, b) {};
    }

    rows.add(new TableRow(
        children: [
      TableCell(
        child: Text(
          "Rank",
          softWrap: false,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline),
          textAlign: TextAlign.center,
        ),
      ),
      TableCell(
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text("Name",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline)),
        ),
      ),
      TableCell(
        child: Text("Score",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline)),
      ),
      title == "Friends"
          ? TableCell(
              child: Text(""),
            )
          : TableCell(
              child: Text(""),
            )
    ].where((e) => e != null).toList()));

    rowData.forEach((rd) {
      rows.add(new TableRow(
          decoration: rd.isPlayer ? BoxDecoration(color: Colors.white24) : null,
          children: [
            TableCell(
              child: Text(
                rd.rank.toString(),
                textAlign: TextAlign.center,
              ),
            ),
            TableCell(
              child: Text(
                rd.name,
                softWrap: false,
              ),
            ),
            TableCell(
              child: Text(rd.score.toString()),
            ),
            title == "Friends" && !rd.isPlayer
                ? TableCell(
                    child: IconButton(
                      icon: Icon(Icons.remove),
                      color: Colors.red,
                      onPressed: () {
                        editAction(rd.name, rd.removeId);
                      },
                    ),
                  )
                : TableCell(child: Text(""))
          ].where((e) => e != null).toList()));
    });

    table = new Table(
        border: TableBorder(
            horizontalInside: BorderSide(width: 1, color: Colors.black)),
        children: rows,
        columnWidths: {
          0: FractionColumnWidth(0.2),
          1: FractionColumnWidth(0.45),
          2: FractionColumnWidth(0.25),
          4: FractionColumnWidth(0.1),
        });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
        style: TextStyle(fontSize: 20, height: 1.5),
        child: Container(
            padding: EdgeInsets.only(top: 10, bottom: 10),
            child: Column(
              children: <Widget>[
                Text(title,
                    style: TextStyle(
                        decoration: TextDecoration.underline, fontSize: 25)),
                table,
              ],
            )));
  }
}
