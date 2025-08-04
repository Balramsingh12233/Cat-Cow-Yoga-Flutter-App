class YogaScript {
  final String text;
  final int startSec;
  final int endSec;
  final String imageRef;

  YogaScript({required this.text, required this.startSec, required this.endSec, required this.imageRef});
}

class YogaSegment {
  final String type;
  final String name;
  final String audioRef;
  final int durationSec;
  final List<YogaScript> script;
  final int? iterations;

  YogaSegment({
    required this.type,
    required this.name,
    required this.audioRef,
    required this.durationSec,
    required this.script,
    this.iterations,
  });
}

class YogaSession {
  final String title;
  final List<YogaSegment> sequence;

  YogaSession({required this.title, required this.sequence});
}
