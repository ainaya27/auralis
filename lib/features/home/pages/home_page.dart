import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final player = AudioPlayer();
  final List<Map<String, String>> songs = [
    {
      'title': 'If I Don\'t Laugh I\'ll Cry',
      'path': 'assets/audio/If_I_Dont_Laugh_Ill_Cry.mp3',
    },
    {'title': 'One Last Kiss', 'path': 'assets/audio/One_Last_Kiss.mp3'},
    {'title': 'drop dead', 'path': 'assets/audio/drop_dead.mp3'},
    {
      'title': 'LOVE LOOKS PRETTY ON YOU',
      'path': 'assets/audio/Love_Looks_Pretty_On_You.mp3',
    },
  ];

  String get currentSong => songs[currentSongIndex]['title']!;
  String get currentSongPath => songs[currentSongIndex]['path']!;

  int currentSongIndex = 0;

  bool isLoaded = false;
  bool isChangingSong = false;

  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();

    player.positionStream.listen((position) {
      setState(() {
        currentPosition = position;
      });
    });

    player.durationStream.listen((duration) {
      setState(() {
        totalDuration = duration ?? Duration.zero;
      });
    });

    player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed &&
          !isChangingSong) {
        debugPrint("Completed -> ${currentSong}");
        nextSong();
      }
    });
  }

  Future<void> playSong() async {
    if (!isLoaded) {
      await player.setAsset(currentSongPath);

      isLoaded = true;
    }

    if (player.playing) {
      await player.pause();
    } else {
      if (currentPosition >= totalDuration && totalDuration > Duration.zero) {
        await player.seek(Duration.zero);
      }

      await player.play();

      setState(() {});
    }
  }

  Future<void> nextSong() async {
    debugPrint("From = $currentSongIndex");
    if (isChangingSong) return;

    isChangingSong = true;

    setState(() {
      if (currentSongIndex < songs.length - 1) {
        currentSongIndex++;
      } else {
        currentSongIndex = 0;
      }

      debugPrint("To = $currentSongIndex");

      isLoaded = false;

      currentPosition = Duration.zero;
      totalDuration = Duration.zero;
    });

    await player.stop();

    await player.setAsset(currentSongPath);
    debugPrint("Loaded -> $currentSong");

    isLoaded = true;

    await player.play();
    debugPrint("Playing -> $currentSong");

    setState(() {});

    isChangingSong = false;
  }

  Future<void> previousSong() async {
    setState(() {
      if (currentSongIndex > 0) {
        currentSongIndex--;
      } else {
        currentSongIndex = songs.length - 1;
      }

      isLoaded = false;
    });

    await player.stop();

    await playSong();
  }

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');

    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return "$minutes:$seconds";
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
            const Icon(Icons.music_note, size: 140),

            const SizedBox(height: 20),

            Text(
              currentSong,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            Slider(
              value: currentPosition.inSeconds.toDouble().clamp(
                0,
                totalDuration.inSeconds.toDouble(),
              ),
              max: totalDuration.inSeconds > 0
                  ? totalDuration.inSeconds.toDouble()
                  : 1,
              onChanged: (value) {
                player.seek(Duration(seconds: value.toInt()));
              },
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Text(
                  formatDuration(currentPosition),
                  style: const TextStyle(color: Colors.white),
                ),

                Text(
                  formatDuration(totalDuration),
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 45,
                  onPressed: previousSong,
                  icon: const Icon(Icons.skip_previous),
                ),

                IconButton(
                  iconSize: 80,
                  onPressed: playSong,
                  icon: Icon(
                    player.playing ? Icons.pause_circle : Icons.play_circle,
                  ),
                ),

                IconButton(
                  iconSize: 45,
                  onPressed: nextSong,
                  icon: const Icon(Icons.skip_next),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
