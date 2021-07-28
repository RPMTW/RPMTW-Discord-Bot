module.exports = async (oldMessage, newMessage, client) => {
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
};