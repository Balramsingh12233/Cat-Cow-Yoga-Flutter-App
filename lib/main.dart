import 'package:flutter/material.dart';
import 'models/session_model.dart';
import 'services/session_loader.dart';
import 'screens/pose_preview_screen.dart';

void main() {
  runApp(YogaApp());
}

class YogaApp extends StatelessWidget {
  final SessionLoader loader = SessionLoader();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cat-Cow Yoga',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.purple),
      home: FutureBuilder<YogaSession>(
        future: loader.loadSession(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('Error: ${snapshot.error}')),
            );
          } else {
            return PosePreviewScreen(session: snapshot.data!);
          }
        },
      ),
    );
  }
}
