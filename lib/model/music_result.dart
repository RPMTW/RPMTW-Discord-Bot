import 'package:nyxx_lavalink/nyxx_lavalink.dart';

class MusicResult {
  final List<ITrackInfo> infos;
  final IPlaylistInfo? playlistInfo;

  const MusicResult(this.infos, this.playlistInfo);

  bool get isPlaylist => playlistInfo != null;
}
