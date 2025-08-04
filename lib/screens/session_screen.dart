import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../models/session_model.dart';
import '../widgets/pose_display.dart';

class SessionScreen extends StatefulWidget {
  final YogaSession session;
  const SessionScreen({required this.session});

  @override
  _SessionScreenState createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  int currentSegmentIndex = 0;
  int currentScriptIndex = 0;
  AudioPlayer audioPlayer = AudioPlayer();
  Timer? poseTimer;
  AudioPlayer backgroundPlayer = AudioPlayer();

  bool isPlaying = true;
  int elapsedSeconds = 0;
  double progress = 0.0;
  bool isMusicMuted = false;
  double musicVolume = 0.4;

  void startSegment(YogaSegment segment) async {
    await audioPlayer.stop();
    await audioPlayer.play(AssetSource('audio/cat_cow_${segment.audioRef}.mp3'));

    List<YogaScript> scripts = segment.script;
    int totalDuration = segment.durationSec;

    int scriptIndex = 0;
    elapsedSeconds = 0;
    progress = 0.0;

    poseTimer?.cancel();
    poseTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      elapsedSeconds++;
      setState(() {
        progress = elapsedSeconds / totalDuration;
      });

      if (scriptIndex < scripts.length &&
          elapsedSeconds >= scripts[scriptIndex].startSec) {
        setState(() {
          currentScriptIndex = scriptIndex;
        });
        scriptIndex++;
      }

      if (elapsedSeconds >= totalDuration) {
        timer.cancel();
        nextSegment();
      }
    });
  }

  void nextSegment() {
    if (currentSegmentIndex + 1 < widget.session.sequence.length) {
      setState(() {
        currentSegmentIndex++;
        currentScriptIndex = 0;
      });
      startSegment(widget.session.sequence[currentSegmentIndex]);
    }
  }

  @override
  void initState() {
    super.initState();
    // Start background music (looping)
    backgroundPlayer.setReleaseMode(ReleaseMode.loop);
    backgroundPlayer.setVolume(musicVolume);
    backgroundPlayer.play(AssetSource('audio/background_music.mp3'));

    // Start session
    startSegment(widget.session.sequence[currentSegmentIndex]);
  }

  @override
  void dispose() {
    poseTimer?.cancel();
    audioPlayer.dispose();
    backgroundPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final segment = widget.session.sequence[currentSegmentIndex];
    final script = segment.script[currentScriptIndex];

    return Scaffold(
      appBar: AppBar(title: Text(widget.session.title)),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            backgroundColor: Colors.grey[300],
            color: Colors.purple,
          ),
          Expanded(
            child: Center(
              child: PoseDisplay(
                imageName: '${script.imageRef}.png',
                text: script.text,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: IconButton(
              icon: Icon(
                isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                size: 60,
                color: Colors.purple,
              ),
              onPressed: () async {
                if (isPlaying) {
                  await audioPlayer.pause();
                  poseTimer?.cancel();
                } else {
                  await audioPlayer.resume();
                  // Resume timer manually
                  final segment = widget.session.sequence[currentSegmentIndex];
                  final remainingDuration = segment.durationSec - elapsedSeconds;
                  poseTimer = Timer.periodic(Duration(seconds: 1), (timer) {
                    elapsedSeconds++;
                    setState(() {
                      progress = elapsedSeconds / segment.durationSec;
                    });
                    if (elapsedSeconds >= segment.durationSec) {
                      timer.cancel();
                      nextSegment();
                    }
                  });
                }
                setState(() {
                  isPlaying = !isPlaying;
                });
              },
            ),
          ),

          // 🔊 Music Controls
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        isMusicMuted ? Icons.volume_off : Icons.volume_up,
                        color: Colors.purple,
                        size: 30,
                      ),
                      onPressed: () {
                        setState(() {
                          isMusicMuted = !isMusicMuted;
                          backgroundPlayer.setVolume(
                              isMusicMuted ? 0.0 : musicVolume);
                        });
                      },
                    ),
                    SizedBox(width: 8),
                    Text(
                      isMusicMuted ? 'Muted' : 'Background Music',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                Slider(
                  value: musicVolume,
                  min: 0,
                  max: 1,
                  divisions: 10,
                  label: '${(musicVolume * 100).toInt()}%',
                  onChanged: (value) {
                    setState(() {
                      musicVolume = value;
                      if (!isMusicMuted) {
                        backgroundPlayer.setVolume(musicVolume);
                      }
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
