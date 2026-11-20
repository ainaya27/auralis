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
      backgroundColor: const Color(0xFF17151F),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF30205C), Color(0xFF19132D), Color(0xFF100D1F)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              children: [
                // Top bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.more_vert,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Album cover
                Expanded(
                  flex: 5,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
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
                              color: const Color(
                                0xFFB16BFF,
                              ).withValues(alpha: 0.25),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.music_note_rounded,
                          color: Colors.white,
                          size: 110,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Song information
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentSong,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Unknown Artist',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.favorite_border_rounded,
                        color: Color(0xFFFF8EB4),
                        size: 30,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Playback slider
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFFFF8EB4),
                    inactiveTrackColor: Colors.white24,
                    thumbColor: const Color(0xFFFFC477),
                    overlayColor: const Color(0x33FF8EB4),
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 5,
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

                // Time labels
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatDuration(currentPosition),
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      formatDuration(totalDuration),
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Playback controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: previousSong,
                      icon: const Icon(Icons.skip_previous_rounded),
                      color: Colors.white,
                      iconSize: 38,
                    ),

                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
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
                          size: 40,
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed: nextSong,
                      icon: const Icon(Icons.skip_next_rounded),
                      color: Colors.white,
                      iconSize: 38,
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
