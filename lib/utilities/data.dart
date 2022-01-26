import 'dart:convert';
import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:nyxx/nyxx.dart';
import 'package:path/path.dart';
import 'package:rpmtw_api_client/rpmtw_api_client.dart';
import 'package:rpmtw_discord_bot/utilities/log.dart';
import 'package:rpmtw_discord_bot/utilities/extension.dart';

Snowflake get rpmtwDiscordServerID => 815819580840607807.toSnowflake();
Snowflake get logChannelID => 934595900528025640.toSnowflake();
Snowflake get siongsngUserID => 645588343228334080.toSnowflake();
Snowflake get voiceChannelID => 832895058281758740.toSnowflake();

late Logger _logger;
Logger get logger => _logger;
late List<String> phishingLinkList;
late List<String> phishingTermList;
late bool kDebugMode;

class Data {
  static void init() {
    load();
    RPMTWApiClient.init();

    kDebugMode = env['DEBUG_MODE']?.toBool() ?? false;
    String phishingLink =
        File(join(Directory.current.path, "lib", "data", "phishing_link.txt"))
            .readAsStringSync();
    phishingLinkList = LineSplitter().convert(phishingLink);

    String phishingTerms =
        File(join(Directory.current.path, "lib", "data", "phishing_terms.txt"))
            .readAsStringSync();
    phishingTermList = LineSplitter().convert(phishingTerms);
  }

  static Future<void> initOnReady(INyxxWebsocket client) async {
    _logger = Logger(client);
    await _logger.init();
  }
}
