import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'sharedPreferencesHelper.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'dart:io' show Platform;
import 'dart:math' as math;

class WebHelper {
  static const String _apiURL = "https://pinkfedora.net/bubbles/api/";
  static int version = 1;

  //Most of these functions have been omitted to protect the integrity of the highscore board slightly longer than otherwise

  static Future<http.Response> _post(String url, Map body) async {
    body['v'] = version.toString();
    try {
      return await http.post(url, body: body);
    } catch (e) {
      if (e.toString().contains("HandshakeException")) {
        return await _post(url, body); //Try again for HandshakeExceptions
      }
      print("_post had an error: $e");
    }
    return null;
  }

  static Future<http.Response> _get(String url) async {
    if (!url.contains("&v=")) url += "&v=$version";
    try {
      return await http.get(url);
    } catch (e) {
      if (e.toString().contains("HandshakeException")) {
        return await _get(url); //Try again for HandshakeExceptions
      }
      print("_get had an error: $e");
    }
    return null;
  }

  static Future<String> getID() async {
    String os = "";
    if (Platform.isIOS) {
      os = "iOS";
    } else {
      os = "Android";
    }
    var response = await _get(_apiURL + "?newId&os=$os").then((r) => r.body);
    return response;
  }

  static Future<WebHelperResponse> updateName(String name) async {
    var map = new Map<String, String>();
    map['name'] = name;
    http.Response response = await _post(_apiURL + "?name", map);

    if (response == null) return new WebHelperResponse(connected: false);
    return new WebHelperResponse(connected: true, response: response.body);
  }

  static Future<String> getHighscores({String board = "allTime"}) async {
    var id = await SharedPreferencesHelper.getID();
    var response = await _get(_apiURL + "?highscores&id=$id&board=$board");
    try {
      if (response.statusCode == 200) {
        return response.body;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<WebHelperResponse> addFriend(int friendCode) async {
    var map = new Map<String, String>();

    map['friendCode'] = friendCode.toString();
    http.Response response = await _post(_apiURL + "?addFriend", map);
    if (response == null) return new WebHelperResponse(connected: false);
    return new WebHelperResponse(connected: true, response: response.body);
  }

  static Future<String> removeFriend(int removeId) async {
    var map = new Map<String, String>();
    map['remove'] = removeId.toString();
    http.Response response = await _post(_apiURL + "?removeFriend", map);
    return response.body;
  }

  static Future<WebHelperResponse> postScore(
    String name,
    int score,
  ) async {
    var map = new Map<String, String>();

    map['name'] = name;

    map['score'] = score.toString();

    var response = await _post(_apiURL + "?postScore", map);

    if (response == null) return WebHelperResponse(connected: false);

    return new WebHelperResponse(connected: true, response: response.body);
  }

  static launchURL(String url) {
    launch(url);
  }
}

class WebHelperResponse {
  final bool connected;
  final Map<String, dynamic> params;
  final String response;

  WebHelperResponse({@required this.connected, this.params, this.response});
}
