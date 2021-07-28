const { MessageEmbed } = require("discord.js");
module.exports = async (oldMessage, newMessage, client) => {
    let chennel = client.channels.cache.find(channel => channel.id === `832849374395760660`);;
    let embed = new MessageEmbed()
        .setTitle(`訊息編輯紀錄`)
        .setDescription(`使用者: ${oldMessage.author} 在 ${oldMessage.channel} 編輯訊息`)
        .addField("原始訊息", oldMessage.content, true)
        .addField("修改後訊息", newMessage.content, true)
        .setTimestamp()
        .setColor("GREEN");
    chennel.send(embed);
};