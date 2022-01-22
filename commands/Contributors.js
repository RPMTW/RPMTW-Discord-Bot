const {MessageEmbed} = require("discord.js");
module.exports = {
    name: 'contributors',
    execute(msg) {
        let num = 55
        let embed = new MessageEmbed()
            .setTitle(`PRMTW 翻譯貢獻者`)
            .setDescription(`請到本網站查看: https://www.rpmtw.ga/%E7%BF%BB%E8%AD%AF%E8%B2%A2%E7%8D%BB%E8%80%85%E6%8E%92%E5%90%8D`)
            .setFooter(`由${msg.author.tag}查詢的資料`, `${msg.author.displayAvatarURL({dynamic: true})}`)
            .setThumbnail("https://media.discordapp.net/attachments/793138981750571008/816269692095561748/pack.png")
            .setTimestamp()
            .setColor("DARK_BLUE");
        msg.channel.send(embed);
    }
}