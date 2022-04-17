import 'dart:async';
import 'dart:math';

import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:instant/instant.dart';
import 'package:nyxx/nyxx.dart';
import 'package:rpmtw_dart_common_library/rpmtw_dart_common_library.dart';
import 'package:rpmtw_discord_bot/model/covid19_info.dart';
import 'package:rpmtw_discord_bot/utilities/data.dart';

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
        element = _element.getElementsByClassName('num').first;
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
        document.getElementsByClassName('sub').first.text.trim();

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
        lastUpdated: RPMTWUtil.getUTCTime());
  }

  static Future<_Covid19FetchStatus> _fetchAndSave() async {
    Covid19Info info = await fetch();
    Box box = Data.covid19Box;

    bool duplicate = _getLatest()?.lastUpdatedString == info.lastUpdatedString;

    if (!duplicate) {
      await box.put(info.lastUpdated.millisecondsSinceEpoch.toString(), info);
    }

    return _Covid19FetchStatus(info, duplicate);
  }

  static Future<Covid19Info> getLatest() async {
    Covid19Info? info = _getLatest();
    if (info == null) {
      return (await _fetchAndSave()).info;
    } else {
      final Duration difference =
          RPMTWUtil.getUTCTime().difference(info.lastUpdated);

      // Only update info if the difference is greater than 1 day and 30 minutes
      if (difference.inDays >= 1 && difference.inMinutes >= 30) {
        return (await _fetchAndSave()).info;
      } else {
        return info;
      }
    }
  }

  static Covid19Info? _getLatest() {
    Box box = Data.covid19Box;
    if (box.isEmpty) {
      return null;
    } else {
      List<int> timeList = box.keys.map((e) => int.parse(e)).toList()..sort();

      final int lastUpdated = timeList.last;
      return box.get(lastUpdated.toString());
    }
  }

  static Covid19Info? getYesterday() {
    Box box = Data.covid19Box;
    try {
      List<int> keys = box.keys.map((e) => int.parse(e)).toList();

      /// Get the max timestamp.
      int maxTimestamp = keys.reduce(max);

      int timestamp;

      if (keys.length == 1) {
        timestamp = maxTimestamp;
      } else {
        timestamp = keys[keys.indexOf(maxTimestamp) - 1];
      }

      return box.get(timestamp.toString());
    } on StateError {
      return null;
    }
  }

  static void timer() {
    Timer.periodic(Duration(minutes: 1), (timer) async {
      /// UTC+8 (Taipei Time)
      DateTime now =
          dateTimeToOffset(offset: 8, datetime: RPMTWUtil.getUTCTime());

      /// 中央流行疫情指揮中心通常在每天的下午兩點或三點公佈 Covid-19 疫情狀況
      bool enable = (now.hour == 14 && now.minute > 12) || now.hour == 15;
      if (enable) {
        try {
          _Covid19FetchStatus status = await _fetchAndSave();

          if (!status.duplicate) {
            ITextChannel channel =
                await dcClient.fetchChannel<ITextChannel>(chatChannelID);
            channel.sendMessage(MessageBuilder()
              ..content = '中央流行疫情指揮中心剛才發布了最新的疫情資訊囉！'
              ..embeds = [status.info.generateEmbed()]);
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
