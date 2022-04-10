import 'dart:async';

import 'package:nyxx/nyxx.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';
import 'package:nyxx_lavalink/nyxx_lavalink.dart';
import 'package:nyxx_pagination/nyxx_pagination.dart';
import 'package:rpmtw_discord_bot/handlers/music_handler.dart';

class MusicQueuePage extends ComponentPaginationAbstract {
  final List<EmbedBuilder> embeds;
  final List<ITrack> tracks;

  @override
  int get maxPage => embeds.length;

  MusicQueuePage(
      IInteractions interactions, this.embeds, this.tracks, IUser user)
      : super(interactions, user: user, timeout: Duration(seconds: 30));

  @override
  ComponentMessageBuilder getMessageBuilderForPage(
          int page, ComponentMessageBuilder currentBuilder) =>
      currentBuilder..embeds = [embeds[page - 1]];

  @override
  FutureOr<void> updatePage(int page, ComponentMessageBuilder currentBuilder,
      IButtonInteractionEvent target) {
    target.respond(getMessageBuilderForPage(page, currentBuilder));
  }

  @override
  ComponentMessageBuilder initHook(ComponentMessageBuilder builder) {
    final buttonId = '${customPreId}_skipButton';
    final skipButton = ButtonBuilder('改聽這首歌', buttonId, ButtonStyle.success);

    interactions.events.onButtonEvent
        .where((event) => event.interaction.customId == buttonId)
        .listen((event) async {
      ITrack track = tracks[currentPage - 1];
      MusicHandler.play(track, forces: true);

      await event.respond(MessageBuilder.empty());
    });
    builder.content = '歌曲隊列 (共有 ${embeds.length} 首)';
    builder.componentRows?.add(ComponentRowBuilder()..addComponent(skipButton));

    return builder;
  }
}
