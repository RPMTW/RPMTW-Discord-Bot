module.exports = async (https, config, msg, MessageEmbed) => {
    let add = "coffeekevin\n"

    let options = {
        host: 'api.crowdin.com',
        path: "/api/v2/projects/442446/members",
        method: 'GET',
        headers: {
            'Authorization': `Bearer ${config.crowdin_token}` //才不要給你token xd
        }
    }, request
    request = https.get(options, function (res) {
        let body = "";
        res.on('data', function (data) {
            body += data;
            body = JSON.parse(body);
        });
        res.on('end', function () {
            let m = "";
            for (let i = 0; i < body.data.length; i++) {
                m += `${body.data[i].data.username}(${body.data[i].data.fullName})\n`
            }
            m += add
            let num = body.data.length + 1
            let embed = new MessageEmbed()
                .setTitle(`PRMTW 貢獻者(依照加入時間排序)`)
                .setDescription(`\`\`\`${m}\`\`\``)
                .setThumbnail("https://media.discordapp.net/attachments/793138981750571008/816269692095561748/pack.png")
                .setFooter(`共有${num}位貢獻者`)
                .setTimestamp()
                .setColor("DARK_BLUE");
            msg.channel.send(embed);
        })
        res.on('error', function (e) {
            console.log("Error: " + e.message);
        });
    });
}