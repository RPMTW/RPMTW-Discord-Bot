import 'package:nyxx_lavalink/nyxx_lavalink.dart';

enum MusicSearchPlatform {
  youtube,
  youtubeMusic,
  soundCloud,
}

extension MusicSearchPlatformExtension on MusicSearchPlatform {
  int get id {
    switch (this) {
      case MusicSearchPlatform.youtube:
        return 0;
      case MusicSearchPlatform.youtubeMusic:
        return 1;
      case MusicSearchPlatform.soundCloud:
        return 2;
    }
  }

  SearchPlatform get platform {
    switch (this) {
      case MusicSearchPlatform.youtube:
        return SearchPlatform.youtube;
      case MusicSearchPlatform.youtubeMusic:
        return SearchPlatform.youtubeMusic;
      case MusicSearchPlatform.soundCloud:
        return SearchPlatform.soundcloud;
    }
  }
}
