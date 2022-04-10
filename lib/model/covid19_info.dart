import 'package:hive/hive.dart';
import 'package:instant/instant.dart';
import 'package:intl/intl.dart';
import 'package:nyxx/nyxx.dart';

import 'package:rpmtw_discord_bot/utilities/data.dart';
import 'package:rpmtw_discord_bot/utilities/util.dart';

part 'covid19_info.g.dart';

@HiveType(typeId: 1)
class Covid19Info extends HiveObject {
  /// Confirmed cases
  @HiveField(0)
  final int confirmed;

  /// Local confirmed cases
  @HiveField(1)
  final int localConfirmed;
  @HiveField(2)
  final int nonLocalConfirmed;

  @HiveField(3)
  final int death;

  @HiveField(4)
  final int totalConfirmed;
  @HiveField(5)
  final int totalLocalConfirmed;
  @HiveField(6)
  final int totalNonLocalConfirmed;
  @HiveField(7)
  final int totalDeath;

  /// UTC+0 time of last update
  @HiveField(8)
  final DateTime lastUpdated;

  /// last update time from the website
  @HiveField(9)
  final String lastUpdatedString;

  Covid19Info get yesterday {
    Box box = Data.covid19Box;
    return box.get(box.keys.last);
  }

  Covid19Info({
    required this.confirmed,
    required this.localConfirmed,
    required this.nonLocalConfirmed,
    required this.death,
    required this.totalConfirmed,
    required this.totalLocalConfirmed,
    required this.totalNonLocalConfirmed,
    required this.totalDeath,
    required this.lastUpdated,
    required this.lastUpdatedString,
  });

  EmbedBuilder generateEmbed() {
    final DateTime time = dateTimeToOffset(offset: 8, datetime: lastUpdated);
    final Covid19Info? _yesterday = yesterday;

    final bool outbreak = confirmed > (_yesterday?.confirmed ?? 0);
    final bool localOutbreak =
        localConfirmed > (_yesterday?.localConfirmed ?? 0);
    final bool nonLocalOutbreak =
        nonLocalConfirmed > (_yesterday?.nonLocalConfirmed ?? 0);
    final bool deathOutbreak = death > (_yesterday?.death ?? 0);

    final DateFormat dateFormat = DateFormat.yMMMMEEEEd("zh-TW").add_jms();
    final String upArrow = '⬆';
    final String downArrow = '⬇';

    EmbedBuilder embed = EmbedBuilder();
    embed.title = 'Covid-19 疫情資訊 (台灣)';
    embed.description = '更新時間： ${dateFormat.format(time)}';
    embed.color = outbreak ? DiscordColor.red : DiscordColor.green;

    embed.addField(
        name: "新增病例",
        content: '${outbreak ? upArrow : downArrow} $confirmed',
        inline: true);
    embed.addField(
        name: "本土確診",
        content: '${localOutbreak ? upArrow : downArrow} $localConfirmed',
        inline: true);
    embed.addField(
        name: "境外移入",
        content: '${nonLocalOutbreak ? upArrow : downArrow} $nonLocalConfirmed',
        inline: true);

    embed.addField(
        name: "累計確診", content: totalConfirmed.toString(), inline: true);
    embed.addField(
        name: "累計本土確診", content: totalLocalConfirmed.toString(), inline: true);
    embed.addField(
        name: "累計境外移入",
        content: totalNonLocalConfirmed.toString(),
        inline: true);

    embed.addField(
        name: "死亡",
        content: '${deathOutbreak ? upArrow : downArrow} $death',
        inline: true);
    embed.addField(name: "累計死亡", content: totalDeath.toString(), inline: true);

    embed.addField(name: "疫情趨勢", content: outbreak ? '升溫' : '緩和');
    embed.timestamp = Util.getUTCTime();
    embed.footer = EmbedFooterBuilder()..text = "資料來源：衛生福利部疾病管制署/Yahoo 奇摩新聞";

    return embed;
  }

  @override
  String toString() {
    return 'Covid19Info(confirmed: $confirmed, localConfirmed: $localConfirmed, nonLocalConfirmed: $nonLocalConfirmed, death: $death, totalConfirmed: $totalConfirmed, totalLocalConfirmed: $totalLocalConfirmed, totalNonLocalConfirmed: $totalNonLocalConfirmed, totalDeath: $totalDeath, lastUpdated: $lastUpdated, lastUpdatedString: $lastUpdatedString)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Covid19Info &&
        other.confirmed == confirmed &&
        other.localConfirmed == localConfirmed &&
        other.nonLocalConfirmed == nonLocalConfirmed &&
        other.death == death &&
        other.totalConfirmed == totalConfirmed &&
        other.totalLocalConfirmed == totalLocalConfirmed &&
        other.totalNonLocalConfirmed == totalNonLocalConfirmed &&
        other.totalDeath == totalDeath &&
        other.lastUpdated == lastUpdated &&
        other.lastUpdatedString == lastUpdatedString;
  }

  @override
  int get hashCode {
    return confirmed.hashCode ^
        localConfirmed.hashCode ^
        nonLocalConfirmed.hashCode ^
        death.hashCode ^
        totalConfirmed.hashCode ^
        totalLocalConfirmed.hashCode ^
        totalNonLocalConfirmed.hashCode ^
        totalDeath.hashCode ^
        lastUpdated.hashCode ^
        lastUpdatedString.hashCode;
  }
}
