import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final player = AudioPlayer();

  Future<void> playSong() async {
    await player.setAsset('assets/audio/If_I_Dont_Laugh_Ill_Cry.mp3');

    player.play();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auralis')),
      body: Center(
        child: ElevatedButton(onPressed: playSong, child: const Text('PLAY')),
      ),
    );
  }
}
