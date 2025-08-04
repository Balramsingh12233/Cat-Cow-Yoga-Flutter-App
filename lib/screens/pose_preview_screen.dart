import 'package:flutter/material.dart';
import '../models/session_model.dart';
import 'session_screen.dart';

class PosePreviewScreen extends StatelessWidget {
  final YogaSession session;
  const PosePreviewScreen({required this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview Poses')),
      body: ListView.builder(
        itemCount: session.sequence.length,
        itemBuilder: (context, index) {
          final segment = session.sequence[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: segment.script.map((script) {
              return ListTile(
                leading: Image.asset(
                  'assets/images/${script.imageRef}.png',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
                title: Text(script.text),
                subtitle: Text('Duration: ${script.endSec - script.startSec}s'),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SessionScreen(session: session),
            ),
          );
        },
        label: const Text("Start Session"),
        icon: const Icon(Icons.play_arrow),
      ),
    );
  }
}
