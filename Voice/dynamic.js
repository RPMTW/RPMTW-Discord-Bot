const fs = require("fs");
module.exports = async (client, log) => {
//建立
    client.on("voiceStateUpdate", (vd, v) => {
        if (v.channel === vd.channel || !v.channel) {
            return;
        }
        fs.readFile(`./Voice/settings.json`, function (err, setFile) {
            if (err) {
                console.log(err);
            }
            let settings = setFile.toString();
            settings = JSON.parse(settings);
            if (!settings || settings.ChannelID !== v.channel.id || !settings.CategoryID) {
                return;
            }
            let name = settings.name || "$ 的頻道";
            name = name.replace(/\$/g, v.member.nickname || v.member.user.username);
            v.guild.channels.create(name, {
                type: 'voice',
                parent: settings.CategoryID,
                permissionOverwrites: [{id: v.member, allow: 871368465}]
            })
                .then(ch => {
                    v.member.voice.setChannel(ch);
                    log.send(`**[創建頻道]** ${v.guild.name}(${v.guild.id}) ${v.member.user.tag}(${v.member.id}): ${ch.name}(${ch.id})`)
                });
        });
    });
//刪除
    client.on("voiceStateUpdate", (vd, v) => {
        try {
            if (!vd.channel || v.channel === vd.channel) {
                return;
            }
            fs.readFile(`./Voice/settings.json`, function (err, setFile) {
                if (err) {
                    console.log(err);
                }
                let settings = setFile.toString();
                settings = JSON.parse(settings);
                if (!settings || !settings.ChannelID || !settings.CategoryID) {
                    return;
                }
                if (vd.channel.id === settings.ChannelID || vd.channel.parentID !== settings.CategoryID) {
                    return;
                }
                if (!vd.channel.members.find(user => user.permissionsIn(vd.channel).has("MANAGE_ROLES"))) {
                    vd.channel.delete();
                    log.send(`**[刪除頻道]** ${vd.guild.name}(${vd.guild.id}): ${vd.channel.name}(${vd.channel.id})`);
                }
            });
        } catch (err) {
            log.send(`**[錯誤]** ${err}`)
        }
    });
}