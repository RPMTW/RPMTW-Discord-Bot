import 'package:nyxx/nyxx.dart';
import 'package:nyxx_lavalink/nyxx_lavalink.dart';
import 'package:rpmtw_dart_common_library/rpmtw_dart_common_library.dart';
import 'package:rpmtw_discord_bot/handlers/music_handler.dart';
import 'package:rpmtw_discord_bot/model/music_info.dart';

extension ITrackInfoExtension on ITrackInfo {
  Uri get _uri => Uri.parse(uri);
  bool get isYoutube => _uri.host == 'www.youtube.com';

  EmbedBuilder generateEmbed({bool progressBar = false}) {
    EmbedBuilder embed = EmbedBuilder();
    embed.title = title;
    embed.url = uri;
    embed.addField(name: '歌曲創作者', content: author, inline: true);

    if (!stream) {
      embed.addField(
          name: '歌曲長度',
          content: RPMTWUtil.formatDuration(Duration(milliseconds: length),
              i18nDay: "天", i18nHour: "小時", i18nMinute: "分鐘", i18nSecond: "秒"),
          inline: true);

      if (progressBar) {
        MusicInfo info = MusicHandler.getInfo();

        _ProgressBar bar = _progressBar(info.position, length);

        embed.addField(
            name: '播放進度',
            content:
                "${bar.text} (${(bar.percentage * 100).toStringAsFixed(2)}%)");
      }
    }

    if (isYoutube) {
      embed.imageUrl =
          'https://img.youtube.com/vi/${_uri.queryParameters['v']}/0.jpg';
    }

    embed.timestamp = RPMTWUtil.getUTCTime();

    return embed;
  }

  _ProgressBar _progressBar(int value, int maxValue) {
    int size = 25;

    final double percentage = value / maxValue;

    // Calculate the number of square characters to fill the progress side.
    final int progress = (size * percentage).toInt();

    // Calculate the number of dash characters to fill the empty progress side.
    final int emptyProgress = size - progress;

    final String progressText = "▇" * progress;
    final String emptyProgressText = "—" * emptyProgress;

    return _ProgressBar(percentage, progressText + emptyProgressText);
  }
}

class _ProgressBar {
  final double percentage;
  final String text;

  const _ProgressBar(this.percentage, this.text);
}
