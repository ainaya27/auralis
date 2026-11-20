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
    setState(() {
      if (currentSongIndex < songs.length - 1) {
        currentSongIndex++;
      } else {
        currentSongIndex = 0;
      }

      isLoaded = false;

      currentPosition = Duration.zero;
      totalDuration = Duration.zero;
    });

    await player.stop();

    await player.setAsset(currentSongPath);

    isLoaded = true;

    await player.play();

    setState(() {});
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
    final double sliderMax = totalDuration.inSeconds > 0
        ? totalDuration.inSeconds.toDouble()
        : 1.0;

    final double sliderValue = currentPosition.inSeconds.toDouble().clamp(
      0.0,
      sliderMax,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF100D1F),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF30205C), Color(0xFF19132D), Color(0xFF100D1F)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    const Icon(
                      Icons.graphic_eq,
                      color: Color(0xFFFF8EB4),
                      size: 30,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'AURALIS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 4,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.headphones_rounded,
                      color: Color(0xFFB9A7FF),
                      size: 27,
                    ),
                  ],
                ),

                const SizedBox(height: 36),

                // Album artwork placeholder
                Container(
                  width: 270,
                  height: 270,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFFB45F),
                        Color(0xFFFF78A9),
                        Color(0xFF9B72F2),
                        Color(0xFF48318A),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFB16BFF).withValues(alpha: 0.25),
                        blurRadius: 35,
                        spreadRadius: 2,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: const Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: 24,
                        right: 25,
                        child: Icon(
                          Icons.auto_awesome,
                          color: Colors.white70,
                          size: 32,
                        ),
                      ),
                      Icon(
                        Icons.music_note_rounded,
                        color: Colors.white,
                        size: 115,
                      ),
                      Positioned(
                        bottom: 24,
                        left: 25,
                        child: Icon(
                          Icons.circle,
                          color: Colors.white24,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 36),

                // Song information
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'NOW PLAYING',
                    style: TextStyle(
                      color: Color(0xFFFFA7C7),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        currentSong,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.favorite_rounded,
                      color: Color(0xFFFF8EB4),
                      size: 27,
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // Playback slider
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFFFF8EB4),
                    inactiveTrackColor: Colors.white24,
                    thumbColor: const Color(0xFFFFC477),
                    overlayColor: const Color(0x33FF8EB4),
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                  ),
                  child: Slider(
                    value: sliderValue,
                    max: sliderMax,
                    onChanged: (value) {
                      player.seek(Duration(seconds: value.toInt()));
                    },
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatDuration(currentPosition),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      formatDuration(totalDuration),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Playback controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: previousSong,
                      icon: const Icon(Icons.skip_previous_rounded),
                      color: Colors.white,
                      iconSize: 42,
                    ),

                    const SizedBox(width: 28),

                    Container(
                      width: 76,
                      height: 76,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFFFB45F), Color(0xFFFF78A9)],
                        ),
                      ),
                      child: IconButton(
                        onPressed: playSong,
                        icon: Icon(
                          player.playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: const Color(0xFF241438),
                          size: 45,
                        ),
                      ),
                    ),

                    const SizedBox(width: 28),

                    IconButton(
                      onPressed: nextSong,
                      icon: const Icon(Icons.skip_next_rounded),
                      color: Colors.white,
                      iconSize: 42,
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                const Text(
                  'YOUR MUSIC, YOUR MOMENT',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    letterSpacing: 2.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
