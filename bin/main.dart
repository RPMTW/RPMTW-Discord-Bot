import 'package:nyxx/nyxx.dart';
import 'package:rpmtw_discord_bot/events/events.dart';
import 'package:rpmtw_discord_bot/handlers/bot_stop_handler.dart';
import 'package:rpmtw_discord_bot/handlers/covid19_handler.dart';
import 'package:rpmtw_discord_bot/handlers/universe_handler.dart';
import 'package:rpmtw_discord_bot/interactions.dart';
import 'package:rpmtw_discord_bot/util/data.dart';
// ignore: depend_on_referenced_packages
import 'package:logging/logging.dart' as logging;

void main(List<String> arguments) async {
  await DataUtil.init();
  if (kDebugMode) {
    logging.Logger.root.level = logging.Level.ALL;
  }
  final client = NyxxFactory.createNyxxWebsocket(
    DataUtil.dotEnv['DISCORD_TOKEN']!,
    GatewayIntents.allUnprivileged |
        GatewayIntents.guildMembers |
        GatewayIntents.messageContent,
    options: ClientOptions(),
  );

  client
    ..registerPlugin(Logging())
    ..registerPlugin(BotStopHandler())
    ..registerPlugin(CliIntegration())
    ..registerPlugin(IgnoreExceptions());

  await client.connect();

  /// Register all events
  Events.register(client);
  Covid19Handler.timer();
  Interactions.register(client);

  await UniverseChatHandler.init(client);
}
