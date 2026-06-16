import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final player = AudioPlayer();

  bool isPlaying = false;
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> playSong() async {
    if (!isLoaded) {
      await player.setAsset('assets/audio/If_I_Dont_Laugh_Ill_Cry.mp3');

      isLoaded = true;
    }

    if (isPlaying) {
      setState(() {
        isPlaying = false;
      });

      await player.pause();
    } else {
      setState(() {
        isPlaying = true;
      });

      await player.play();
    }
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "isPlaying = $isPlaying",
              style: const TextStyle(color: Colors.white),
            ),

            ElevatedButton(
              onPressed: playSong,
              child: Text(isPlaying ? 'PAUSE' : 'PLAY'),
            ),
          ],
        ),
      ),
    );
  }
}
