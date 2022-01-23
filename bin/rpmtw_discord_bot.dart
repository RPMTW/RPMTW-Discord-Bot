import 'package:dotenv/dotenv.dart';
import 'package:nyxx/nyxx.dart';
import 'package:rpmtw_discord_bot/events/events.dart';
import 'package:rpmtw_discord_bot/interactions.dart';
import 'package:rpmtw_discord_bot/utilities/data.dart';

void main(List<String> arguments) {
  Data.init();
  INyxxWebsocket client = NyxxFactory.createNyxxWebsocket(
    env['DISCORD_TOKEN']!,
    GatewayIntents.allUnprivileged,
    options: ClientOptions(
     // dispatchRawShardEvent: true
    ),
  );

  client.registerPlugin(Logging());
  client.registerPlugin(CliIntegration());
  client.registerPlugin(IgnoreExceptions());
  client.connect();

  /// Register all commands
  Interactions.register(client);

  /// Register all events
  Events.register(client);
}
