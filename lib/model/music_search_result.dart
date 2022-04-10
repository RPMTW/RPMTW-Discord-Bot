import 'package:nyxx_lavalink/nyxx_lavalink.dart';

class MusicSearchResult {
  /// Max: 25
  final List<ITrackInfo> trackInfos;
  final IPlaylistInfo? playlistInfo;

  const MusicSearchResult(this.trackInfos, this.playlistInfo);

  bool get isPlaylist => playlistInfo != null;
}
