  const Discord = require('discord.js');
const client = new Discord.Client()
const config = require(`${process.cwd()}/config.json`)
const log = new Discord.WebhookClient("832853964819136532", process.env['LogToken']);
const fs = require("fs");
const keep_alive = require('./keep.js')

//const {MessageEmbed} = require("discord.js");

client.commands = new Discord.Collection();
const commandFiles = fs.readdirSync('./commands').filter(file => file.endsWith('.js')); //commands
for (const file of commandFiles) {
    const command = require(`./commands/${file}`);
    client.commands.set(command.name, command);
}
require("./events")(client,log);//事件偵測
require("./SlashCommand")(client,log);//SlashCommand處理
require("./Voice/dynamic")(client, log)

client.login(process.env['DiscordToken']).then(r => {
    console.log(`${client.user.username} 登入成功`)
    log.send(`${client.user.username} 登入成功`)
})