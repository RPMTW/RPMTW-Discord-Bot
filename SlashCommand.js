const Discord = require("discord.js");
const https = require("https");
const config = require(`${process.cwd()}/config.json`)
const { MessageEmbed } = require("discord.js");
module.exports = async (client, log) => {

  client.on('ready', () => {
    client.api.applications(client.user.id).guilds("815819580840607807").commands.post({
      data: {
        name: "help",
        description: "取得幫助"
      },
      data: {
        name: "ping",
        description: "取得此機器人的延遲"
      },
      data: {
        name: "hello",
        description: "嗨!"
      },
      data: {
        name: "info",
        description: "取得RPMTW翻譯進度資訊"
      }
    });
  });

  client.ws.on('INTERACTION_CREATE', async interaction => {
    if (interaction.data.name === "help") {
      let embed = new MessageEmbed()
        .setTitle(`PRMTW 官方機器人-幫助頁面`)
        .setDescription(`\`!help\` 顯示此幫助頁面\n\`!Contributors\` 顯示PRMTW貢獻者\n\`!info\` 顯示PRMTW的相關資訊`)
        .setThumbnail("https://media.discordapp.net/attachments/793138981750571008/816269692095561748/pack.png")
        .setTimestamp()
        .setColor("DARK_GREY");
      client.api.interactions(interaction.id, interaction.token).callback.post({ data: { type: 5 } })
      await new Discord.WebhookClient(interaction.application_id, interaction.token).send(embed)
    } else if (interaction.data.name === "hello") {
      client.api.interactions(interaction.id, interaction.token).callback.post({ data: { type: 5 } })
      await new Discord.WebhookClient(interaction.application_id, interaction.token).send(`<@!${interaction.member.user.id}> 您好，有什麼需要為您服務的嗎?，輸入\`/help\`取得幫助!`);
    } else if (interaction.data.name === "ping") {
      client.api.interactions(interaction.id, interaction.token).callback.post({ data: { type: 5 } })
      await new Discord.WebhookClient(interaction.application_id, interaction.token).send("請改為使用 `!ping`")
    } else if (interaction.data.name === "info") {
      client.api.interactions(interaction.id, interaction.token).callback.post({ data: { type: 5 } })
      let options = {
        host: 'badges.awesome-crowdin.com',
        path: "/stats-14504298-442446.json",
        method: 'GET',
      }, request
      request = https.get(options, function(res) {
        let body = "";
        res.on('data', function(data) {
          body += data;
          body = JSON.parse(body);
        });
        res.on('end', function() {
          let approvalProgress = body.progress[0].data.approvalProgress; //已核准翻譯進度

          let words_total = body.progress[0].data.words.total //總原始文字數量
          let words_translated = body.progress[0].data.words.translated //已翻譯文字數量

          let translationProgress = String((words_translated / words_total * 100).toFixed(3)) + "%"; //翻譯進度

          let phrases_total = body.progress[0].data.phrases.total //總原始字串數量
          let phrases_translated = body.progress[0].data.phrases.translated //已翻譯字串數量

          let embed = new MessageEmbed()
            .setTitle(`PRMTW 資訊`)
            .setDescription("這個分頁會顯示關於此資源包的相關翻譯資訊")
            .addField("翻譯進度", translationProgress, true)
            .addField("已核准翻譯進度", approvalProgress, true)
            .addField("翻譯字數", words_translated + "/" + words_total + "個文字")
            .addField("翻譯字串", phrases_translated + "/" + phrases_total + "個字串")
            .setFooter(`由${interaction.member.user.username}#${interaction.member.user.discriminator}查詢的資料`, client.users.cache.get(interaction.member.user.id).displayAvatarURL({ dynamic: true }))
            .setTimestamp()
            .setColor("DARK_BLUE");
          new Discord.WebhookClient(interaction.application_id, interaction.token).send(embed)
        })
        res.on('error', function(e) {
          console.log("Error: " + e.message);
        });
      });
    }
  })
}
