import 'package:nyxx/nyxx.dart';
import 'package:rpmtw_discord_bot/events/base_event.dart';

class MessageCreateEvent implements BaseEvent<IMessageReceivedEvent> {
  @override
  Future<void> handler(client, event) async {
    String messageContent = event.message.content;

    RegExp urlRegex = RegExp(
        r"(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$");

    if (urlRegex.hasMatch(messageContent)) {
      List<RegExpMatch> matchList =
          urlRegex.allMatches(messageContent).toList();

      List<String> domainWhitelist = [
        "discord.gift",
        "discord.gg",
        "discord.com",
        "discordapp.com",
        "discordapp.net",
        "rpmtw.com",
        "rpmtw.ga",
        "google.com",
      ];

      for (RegExpMatch match in matchList) {
        String domain1 = match.group(2)!.split(".").last;
        String domain2 = match.group(3)!;
        String domain = "$domain1.$domain2";
        print(domain);
        if (!domainWhitelist.contains(domain)) {}
      }
    }
  }
}
