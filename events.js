const config = require(`${process.cwd()}/config.json`)
const talk = new Set();
const fs = require("fs");
const { MessageEmbed } = require("discord.js");
module.exports = async (client, log) => {

  client.on("message", async (msg) => {
    if (!msg.author.bot && msg.channel.type === "dm") await msg.channel.send('請不要私訊機器人!')

    if (msg.author.bot) return; //如果是機器人就返回
    const SiongSng = client.users.cache.find(u => u.id === '645588343228334080');
    /*
    動態指令
     */
    const args = msg.content.slice(config.Prefix.length).trim().split(/ +/);
    const command = args.shift().toLowerCase();
    if (client.commands.has(command)) {
      try {
        client.commands.get(command).execute(msg, args);
      } catch (error) {
        console.error(error);
        await msg.reply('執行指令時發生了意外錯誤!');
      }
    }
    if (msg.mentions.has(SiongSng)) {
      let embed = new MessageEmbed()
        .setTitle(`標記菘菘提示訊息`)
        .setDescription(`我們偵測到您 ${msg.author} 標記了 ${SiongSng}，提醒您非急事請勿使用標記功能來標記菘菘。 ~~它可是很忙ㄉ~~`)
        .setColor(`RED`);
      msg.channel.send(embed);
    }
    if (msg.reference) {//如果該訊息是回覆的訊息
      msg.channel.messages.fetch(msg.reference.messageID).then(message => {
        if (msg.mentions.has(message.author)) {
          let embed = new MessageEmbed()
            .setTitle(`回覆訊息標記提示訊息`)
            .setDescription(`提醒您 ${msg.author}，使用回覆訊息時請不要使用標記功能，以免造成困擾，除非上下文距離很遠。`)
            .addField(`標記者`, `${msg.author}`, true)
            .addField(`被標記者`, `${message.author}`, true)
            .addField(`被標記的訊息內容`, message.content, false)
            .setImage("https://media.discordapp.net/attachments/815819581440262146/868455209725218886/tenor.gif")
            .setTimestamp()
            .setColor(`RED`);
          msg.channel.send(embed).then((EmbedMsg) => {
            EmbedMsg.delete({ timeout: 15e3 })
          });
        }
      })
        .catch(console.error);
    }
  });

  client.on("messageUpdate", async (oldMessage, newMessage) => { //訊息更新(編輯)
    await require("./events/messageUpdate")(oldMessage, newMessage, client);
  });

  client.on("messageDelete", async (messageDelete) => { //訊息刪除
    await require("./events/messageDelete")(messageDelete, client);
  });
  // client.on("voiceStateUpdate", async (vd, v) => {
  //   await require("./events/voiceStateUpdate")(vd, v, log);
  // });
}
