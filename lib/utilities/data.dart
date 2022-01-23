import 'package:dotenv/dotenv.dart';
import 'package:nyxx/nyxx.dart';
import 'package:rpmtw_api_client/rpmtw_api_client.dart';
import 'package:rpmtw_discord_bot/utilities/log.dart';

Snowflake get rpmtwDiscordServerID => 815819580840607807.toSnowflake();
Snowflake get logChannelID => 934595900528025640.toSnowflake();
late Logger _logger;
Logger get logger => _logger;

class Data {
  static void init() {
    load();
    RPMTWApiClient.init();
  }

  static Future<void> initOnReady(INyxxWebsocket client) async {
    _logger = Logger(client);
    await _logger.init();
  }
}
