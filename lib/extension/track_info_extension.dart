import 'package:nyxx/nyxx.dart';
import 'package:nyxx_lavalink/nyxx_lavalink.dart';
import 'package:rpmtw_dart_common_library/rpmtw_dart_common_library.dart';

extension ITrackInfoExtension on ITrackInfo {
  EmbedBuilder generateEmbed() {
    EmbedBuilder embed = EmbedBuilder();
    embed.title = title;
    embed.url = uri;
    embed.addField(name: '歌曲創作者', content: author, inline: true);
    embed.addField(
        name: '歌曲長度',
        content: RPMTWUtil.formatDuration(Duration(milliseconds: length),
            i18nDay: "天", i18nHour: "小時", i18nMinute: "分鐘", i18nSecond: "秒"),
        inline: true);
    embed.timestamp = RPMTWUtil.getUTCTime();

    return embed;
  }
}
