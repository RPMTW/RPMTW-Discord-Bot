import 'package:nyxx/nyxx.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';
import 'package:rpmtw_discord_bot/utilities/data.dart';

class Interactions {
  static SlashCommandBuilder get hello {
    SlashCommandBuilder _cmd =
        SlashCommandBuilder("hello", "跟你打招呼", [], guild: rpmtwDiscordServerID);
    _cmd.registerHandler((event) async {
      String userTag = event.interaction.userAuthor!.tag;
      await event.respond(MessageBuilder.content("嗨，$userTag ！"));
    });
    return _cmd;
  }

  static void register(INyxxWebsocket client) {
    IInteractions interactions =
        IInteractions.create(WebsocketInteractionBackend(client));

    interactions.registerSlashCommand(hello);
    interactions.syncOnReady();
  }
}
