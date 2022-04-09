import 'dart:async';

import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:instant/instant.dart';
import 'package:nyxx/nyxx.dart';
import 'package:rpmtw_discord_bot/model/covid19_info.dart';
import 'package:rpmtw_discord_bot/utilities/data.dart';
import 'package:rpmtw_discord_bot/utilities/util.dart';

class Covid19Handler {
  static const String _url =
      'https://news.campaign.yahoo.com.tw/2019-nCoV/taiwancase.php';

  static Future<Covid19Info> fetch() async {
    http.Response response = await http.get(Uri.parse(_url));
    String html = response.body;

    Document document = HtmlParser(html).parse();

    int _parseInt(String text) {
      try {
        return int.parse(text.replaceAll(RegExp(r'[^\d]'), ''));
      } catch (e) {
        return 0;
      }
    }

    int _parseField(int index, bool isTitle) {
      Element _element =
          document.getElementsByTagName('dl').first.children[index];

      Element element;

      if (isTitle) {
        element = _element.getElementsByClassName("num").first;
      } else {
        element = _element.getElementsByTagName('p').first;
      }

      return _parseInt(element.text);
    }

    int confirmed = _parseField(1, true);

    int localConfirmed = _parseField(2, true);

    int nonLocalConfirmed = _parseField(3, true);

    int death = _parseField(4, true);

    int totalConfirmed = _parseField(0, true);
    int totalLocalConfirmed = _parseField(2, false);
    int totalNonLocalConfirmed = _parseField(3, false);

    int totalDeath = _parseField(4, false);

    String lastUpdatedString =
        document.getElementsByClassName("sub").first.text.trim();

    return Covid19Info(
        confirmed: confirmed,
        localConfirmed: localConfirmed,
        nonLocalConfirmed: nonLocalConfirmed,
        death: death,
        totalConfirmed: totalConfirmed,
        totalDeath: totalDeath,
        totalLocalConfirmed: totalLocalConfirmed,
        totalNonLocalConfirmed: totalNonLocalConfirmed,
        lastUpdatedString: lastUpdatedString,
        lastUpdated: Util.getUTCTime());
  }

  static Future<_Covid19FetchStatus> _save() async {
    Covid19Info info = await fetch();
    Box box = Data.covid19Box;
    bool duplicate = info.yesterday == info;

    if (!duplicate) {
      await box.put(info.lastUpdated.millisecondsSinceEpoch.toString(), info);
    }

    return _Covid19FetchStatus(info, duplicate);
  }

  static Future<Covid19Info> latest() async {
    Box box = Data.covid19Box;
    if (box.isEmpty) {
      return (await _save()).info;
    } else {
      List<int> timeList = box.keys.map((e) => int.parse(e)).toList()..sort();

      int lastUpdated = timeList.last;
      Covid19Info info = box.get(lastUpdated.toString());
      if (info.lastUpdated.difference(Util.getUTCTime()).inDays > 1) {
        return (await _save()).info;
      } else {
        return info;
      }
    }
  }

  static void timer() {
    Timer.periodic(Duration(minutes: 1), (timer) async {
      /// UTC+8 (Taipei Time)
      DateTime now = dateTimeToOffset(offset: 8, datetime: Util.getUTCTime());

      /// 中央流行疫情指揮中心通常在每天的下午兩點或三點公佈 Covid-19 疫情狀況
      bool enable = now.hour == 14 || now.hour == 15;
      if (enable) {
        try {
          _Covid19FetchStatus status = await _save();

          if (!status.duplicate) {
            ITextChannel channel =
                await dcClient.fetchChannel<ITextChannel>(chatChannelID);
            channel.sendMessage(MessageBuilder()
              ..content = '指揮中心發布了最新的疫情資訊囉！'
              ..embeds = [status.info.generateEmbed()]);

            timer.cancel();
          }
        } catch (e, stackTrace) {
          await logger.error(error: e, stackTrace: stackTrace);
        }
      }
    });
  }
}

class _Covid19FetchStatus {
  final Covid19Info info;
  final bool duplicate;

  const _Covid19FetchStatus(this.info, this.duplicate);
}
