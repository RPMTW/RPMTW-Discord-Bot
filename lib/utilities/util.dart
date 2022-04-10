// ignore_for_file: implementation_imports

import 'package:nyxx/nyxx.dart';
import 'package:rpmtw_discord_bot/utilities/data.dart';

import 'package:nyxx/src/internal/http/http_request.dart';
import 'package:nyxx/src/internal/http_endpoints.dart';

class Util {
  static DateTime getUTCTime() {
    return DateTime.now().toUtc();
  }

  // https://github.com/nyxx-discord/nyxx/pull/328
  static Future<void> editGuildMember(
      Snowflake guildId, Snowflake memberId, MemberBuilder builder,
      {String? auditReason}) async {
    HttpEndpoints httpEndpoints = dcClient.httpEndpoints as HttpEndpoints;

    await httpEndpoints.executeSafe(BasicRequest(
        "/guilds/$guildId/members/$memberId",
        method: "PATCH",
        auditLog: auditReason,
        body: builder.build()));
  }
}
