import 'package:dotenv/dotenv.dart';
import 'package:nyxx/nyxx.dart';
import 'package:rpmtw_api_client/rpmtw_api_client.dart';

Snowflake get rpmtwDiscordServerID => 815819580840607807.toSnowflake();

class Data {
  static void init() {
    load();
    RPMTWApiClient.init();
  }
}
