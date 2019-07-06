import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:date_format/date_format.dart';

class SharedPreferencesHelper {
  static final String _usename = "USERNAME";
  static final String _id = "ID";
  static final String _pass = "PASS";
  static final String _lastClearedDaily = "lastClearedDaily";
  static final String _lastClearedWeekly = "lastClearedWeekly";
  static final String _lastClearedMonthly = "lastClearedMonthly";
  static final String leaderboardConcent = "leaderboardConcent";

  static Future<String> getUsername() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usename) ?? "";
  }

  static Future<bool> setUsername(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_usename, value);
  }

  static Future<int> getID() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_id) ?? 0;
  }

  static Future<bool> setID(int value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setInt(_id, value);
  }

  static Future<String> getPass() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pass) ?? "";
  }

  static Future<bool> setPass(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_pass, value);
  }

  static Future<String> getFriendCode() async {
    final id = await getID();
    final pass = await getPass();
    if (id == 0 || pass == "") return "";
    int key = int.parse(pass.substring(pass.length - 3));
    int friendCode = (id * 737 - key) * 1000 + key;
    return friendCode.toString();
  }

  static Future<bool> getLeaderboardConcent() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(leaderboardConcent) ?? false;
  }

  static Future<bool> setLeaderboardConcent(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(leaderboardConcent, value);
  }

  static Future<String> getLastClearedDaily() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastClearedDaily) ?? "";
  }

  static Future<bool> setLastClearedDaily(DateTime d) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_lastClearedDaily, formatDate(d, [yyyy, mm, dd]));
  }

  static Future<String> getLastClearedWeekly() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastClearedWeekly) ?? "";
  }

  static Future<bool> setLastClearedWeekly(DateTime d) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_lastClearedWeekly, formatDate(d, [yyyy, mm, dd]));
  }

  static Future<String> getLastClearedMonthly() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastClearedMonthly) ?? "";
  }

  static Future<bool> setLastClearedMonthly(DateTime d) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_lastClearedMonthly, formatDate(d, [yyyy, mm, dd]));
  }

  //Database Stuff
  static final String _highScoresDatabase = "highscores.db";
  static final int _highScoresDatabaseVersion = 2;
  static final String _tableAllTimeScores = "allTime";
  static final String _tableDailyScores = "daily";
  static final String _tableWeeklyScores = "weekly";
  static final String _tableMonthlyScores = "monthly";

  static Future<bool> postScore(int score) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _highScoresDatabase);

    Database database = await openDatabase(path,
        version: _highScoresDatabaseVersion, onCreate: _onDBCreate);
    Map<String, dynamic> map = {"score": score};

    List<Future> posts = [];

    if ((await database.query(_tableAllTimeScores, where: "score=$score"))
            .length ==
        0) posts.add(database.insert(_tableAllTimeScores, map));
    if ((await database.query(_tableDailyScores, where: "score=$score"))
            .length ==
        0) posts.add(database.insert(_tableDailyScores, map));
    if ((await database.query(_tableWeeklyScores, where: "score=$score"))
            .length ==
        0) posts.add(database.insert(_tableWeeklyScores, map));
    if ((await database.query(_tableMonthlyScores, where: "score=$score"))
            .length ==
        0) posts.add(database.insert(_tableMonthlyScores, map));

    await Future.wait(posts);
    database.close();
    return true;
  }

  static Future<List<Map<String, dynamic>>> getHighScores(String board) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _highScoresDatabase);
    Database database = await openDatabase(path,
        version: _highScoresDatabaseVersion, onCreate: _onDBCreate);
    var query;
    DateTime now = DateTime.now();
    switch (board) {
      case "allTime":
        query =
            await database.query(_tableAllTimeScores, orderBy: "score DESC");
        break;
      case "daily":
        String lastClearedString = await getLastClearedDaily();
        if (lastClearedString != "") {
          DateTime lastCleared = DateTime.parse(lastClearedString);
          if (now.day != lastCleared.day) {
            database.delete(_tableDailyScores);
            setLastClearedDaily(now);
          }
        } else {
          setLastClearedDaily(now);
        }
        query = await database.query(_tableDailyScores, orderBy: "score DESC");
        break;
      case "weekly":
        String lastClearedString = await getLastClearedWeekly();
        if (lastClearedString != "") {
          DateTime lastCleared = DateTime.parse(lastClearedString);
          if (now.difference(lastCleared).inDays >= 7) {
            database.delete(_tableWeeklyScores);
            setLastClearedWeekly(now);
          }
        } else {
          setLastClearedWeekly(now);
        }
        query = await database.query(_tableWeeklyScores, orderBy: "score DESC");
        break;
      case "monthly":
        String lastClearedString = await getLastClearedMonthly();
        if (lastClearedString != "") {
          DateTime lastCleared = DateTime.parse(lastClearedString);
          if (now.difference(lastCleared).inDays >= 30 ||
              (now.difference(lastCleared).inDays > 1 && now.day == 1)) {
            database.delete(_tableMonthlyScores);
            setLastClearedMonthly(now);
          }
        } else {
          setLastClearedMonthly(now);
        }
        query =
            await database.query(_tableMonthlyScores, orderBy: "score DESC");
        break;
    }
    String username = await getUsername();

    List<Map<String, dynamic>> result = [];
    int rank = 1;
    query.forEach((r) {
      result.add({"score": r['score'], "name": username, "rank": rank});
      rank++;
    });

    if (board == "allTime" && result.length > 10) {
      for (int i = 10; i < result.length; i++) {
        database.delete(_tableAllTimeScores,
            where: "score = ${result[i]['score']}");
      }
    }
    return result;
  }

  static _onDBCreate(Database db, int version) async {
    print("onDBCreate called");
    await db.execute('''
        CREATE TABLE $_tableAllTimeScores (
                score INTEGER
              );
        ''');
    await db.execute('''
        CREATE TABLE $_tableDailyScores (
                score INTEGER
              );
        ''');
    await db.execute('''
        CREATE TABLE $_tableWeeklyScores (
                score INTEGER
              );
        ''');
    await db.execute('''
        CREATE TABLE $_tableMonthlyScores (
                score INTEGER
              );
        ''');
  }

  static clearDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _highScoresDatabase);
    Database database = await openDatabase(path,
        version: _highScoresDatabaseVersion, onCreate: _onDBCreate);

    database.delete(_tableAllTimeScores);
    database.delete(_tableDailyScores);
    database.delete(_tableWeeklyScores);
    database.delete(_tableMonthlyScores);
  }
}
