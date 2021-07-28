module.exports = async (vd, v, log) => {
  log.send(`**${v.member.user.tag}**(\`${v.member.id}\`) 離開 **${vd.channel.name}**(\`${vd.channel.id})\``);
};