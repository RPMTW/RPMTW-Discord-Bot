const { MessageEmbed } = require("discord.js");
module.exports = async (messageDelete, client) => {
    let chennel = client.channels.fetch("832849374395760660");
    let embed = new MessageEmbed()
        .setTitle(`訊息刪除紀錄`)
        .setDescription(`使用者: ${messageDelete.author} 的訊息在 ${messageDelete.channel} 被刪除了`)
        .addField("刪除的訊息內容", messageDelete.content, true)
        .setTimestamp()
        .setColor("GREEN");
    chennel.send(embed);
};