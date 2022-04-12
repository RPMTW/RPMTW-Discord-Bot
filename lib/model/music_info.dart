import 'package:nyxx_lavalink/nyxx_lavalink.dart';

class MusicInfo {
  final int position;
  final IQueuedTrack? nowPlaying;

  bool get isPlaying => nowPlaying != null;

  const MusicInfo({required this.position, required this.nowPlaying});
}
