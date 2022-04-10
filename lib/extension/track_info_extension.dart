import 'package:nyxx/nyxx.dart';
import 'package:nyxx_lavalink/nyxx_lavalink.dart';
import 'package:rpmtw_dart_common_library/rpmtw_dart_common_library.dart';
import 'package:rpmtw_discord_bot/utilities/util.dart';

extension ITrackInfoExtension on ITrackInfo {
  EmbedBuilder generateEmbed() {
    EmbedBuilder embed = EmbedBuilder();
    embed.title = title;
    embed.url = uri;
    embed.addField(name: '歌曲創作者', content: author, inline: true);
    embed.addField(
        name: '歌曲長度',
        content: RPMTWUtil.formatDuration(Duration(milliseconds: length),
            i18nHours: "小時", i18nMinutes: "分鐘", i18nSeconds: "秒"),
        inline: true);
    embed.timestamp = Util.getUTCTime();

    return embed;
  }
}
