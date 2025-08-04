import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/session_model.dart';

class SessionLoader {
  Future<YogaSession> loadSession() async {
    final String jsonString = await rootBundle.loadString('assets/json/CatCowJson.json');
    final data = json.decode(jsonString);
    final title = data["metadata"]["title"];
    final sequence = (data["sequence"] as List).map((segment) {
      final scripts = (segment["script"] as List).map((s) => YogaScript(
        text: s["text"],
        startSec: s["startSec"],
        endSec: s["endSec"],
        imageRef: s["imageRef"],
      )).toList();

      return YogaSegment(
        type: segment["type"],
        name: segment["name"],
        audioRef: segment["audioRef"],
        durationSec: segment["durationSec"],
        iterations: segment["iterations"] != null ? 4 : null,
        script: scripts.cast<YogaScript>(),
      );
    }).toList();

    return YogaSession(title: title, sequence: sequence.cast<YogaSegment>());
  }
}
