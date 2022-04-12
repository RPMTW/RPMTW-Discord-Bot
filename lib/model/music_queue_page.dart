import 'dart:async';

import 'package:nyxx/nyxx.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';
import 'package:nyxx_lavalink/nyxx_lavalink.dart';
import 'package:nyxx_pagination/nyxx_pagination.dart';
import 'package:rpmtw_discord_bot/extension/track_info_extension.dart';
import 'package:rpmtw_discord_bot/handlers/music_handler.dart';
import 'package:rpmtw_discord_bot/model/music_result.dart';

class MusicQueuePage extends ComponentPaginationAbstract {
  final MusicResult result;

  @override
  int get maxPage => result.infos.length;

  MusicQueuePage(IInteractions interactions, this.result, IUser user)
      : super(interactions, user: user, timeout: Duration(seconds: 30));

  @override
  ComponentMessageBuilder getMessageBuilderForPage(
          int page, ComponentMessageBuilder currentBuilder) =>
      currentBuilder..embeds = [result.infos[page - 1].generateEmbed()];

  @override
  FutureOr<void> updatePage(int page, ComponentMessageBuilder currentBuilder,
      IButtonInteractionEvent target) {
    target.respond(getMessageBuilderForPage(page, currentBuilder));
  }

  @override
  ComponentMessageBuilder initHook(ComponentMessageBuilder builder) {
    final buttonId = '${customPreId}_playButton';
    final playButton = ButtonBuilder('▶️', buttonId, ButtonStyle.primary);

    interactions.events.onButtonEvent
        .where((event) => event.interaction.customId == buttonId)
        .listen((event) async {
      ITrackInfo track = result.infos[currentPage - 1];
      MusicHandler.playByIdentifier(track.identifier, force: true);

      await event.respond(MessageBuilder.empty());
    });
    builder.content = '歌曲隊列 (共有 ${result.infos.length} 首)';
    final ComponentRowBuilder rowBuilder = builder.componentRows!.first;
    builder.componentRows!.clear();
    builder.componentRows!.add(rowBuilder..addComponent(playButton));

    return builder;
  }
}
