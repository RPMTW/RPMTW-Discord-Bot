module.exports = async (https, config, msg, MessageEmbed) => {
  msg.channel.send("查詢資料中...").then(msg.delete());
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
        .setFooter(`由${msg.author.tag}查詢的資料`, `${msg.author.displayAvatarURL({ dynamic: true })}`)
        .setTimestamp()
        .setColor("DARK_BLUE");
      msg.channel.send(embed);
    })
    res.on('error', function(e) {
      console.log("Error: " + e.message);
    });
  });
}