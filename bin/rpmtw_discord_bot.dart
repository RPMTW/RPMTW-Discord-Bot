import 'package:dotenv/dotenv.dart';
import 'package:nyxx/nyxx.dart';

void main(List<String> arguments) {
  load();
  INyxxWebsocket bot = NyxxFactory.createNyxxWebsocket(
      env['DISCORD_TOKEN']!, GatewayIntents.allUnprivileged);

  bot.registerPlugin(Logging());
  bot.registerPlugin(CliIntegration());
  bot.registerPlugin(IgnoreExceptions());
  bot.connect();

  bot.eventsWs.onReady.listen((e) {
    print("Ready!");
  });
}
