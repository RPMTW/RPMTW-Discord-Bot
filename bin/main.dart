import 'package:dotenv/dotenv.dart';
import 'package:nyxx/nyxx.dart';
import 'package:rpmtw_discord_bot/events/events.dart';
import 'package:rpmtw_discord_bot/handlers/bot_stop_handler.dart';
import 'package:rpmtw_discord_bot/handlers/covid19_handler.dart';
//import 'package:rpmtw_discord_bot/handlers/cosmic_handler.dart';
import 'package:rpmtw_discord_bot/interactions.dart';
import 'package:rpmtw_discord_bot/utilities/data.dart';
import 'package:logging/logging.dart' as logging;

void main(List<String> arguments) async {
  await Data.init();
  if (kDebugMode) {
    logging.Logger.root.level = logging.Level.ALL;
  }
  INyxxWebsocket client = NyxxFactory.createNyxxWebsocket(
    env['DISCORD_TOKEN']!,
    GatewayIntents.all,
    options: ClientOptions(),
  );

  client.registerPlugin(Logging());
  client.registerPlugin(BotStopHandler());
  client.registerPlugin(CliIntegration());
  // client.registerPlugin(IgnoreExceptions());
  client.connect();

  /// Register all commands
  Interactions.register(client);

  /// Register all events
  Events.register(client);
  Covid19Handler.timer();

  // CosmicChatHandler.init(client);
}
