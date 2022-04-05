import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:hive/hive.dart';
import 'package:nyxx/nyxx.dart';
import 'package:rpmtw_api_client/rpmtw_api_client.dart';
import 'package:rpmtw_discord_bot/utilities/log.dart';
import 'package:rpmtw_discord_bot/utilities/extension.dart';

Snowflake get rpmtwDiscordServerID => 815819580840607807.toSnowflake();
Snowflake get logChannelID => 934595900528025640.toSnowflake();
Snowflake get siongsngUserID => 645588343228334080.toSnowflake();
Snowflake get voiceChannelID => 832895058281758740.toSnowflake();

late final Logger _logger;
Logger get logger => _logger;
late bool kDebugMode;

class Data {
  static late final Box _chefBox;

  static Box get chefBox => _chefBox;

  static Future<void> init() async {
    load();
    RPMTWApiClient.init();
    String path = Directory.current.path;
    Hive.init(path);
    _chefBox = await Hive.openBox('chefBox');

    kDebugMode = env['DEBUG_MODE']?.toBool() ?? false;
  }

  static Future<void> initOnReady(INyxxWebsocket client) async {
    ITextChannel channel =
        await client.fetchChannel<ITextChannel>(logChannelID);
    _logger = Logger(client, channel);
  }
}
