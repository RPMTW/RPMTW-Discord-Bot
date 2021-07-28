module.exports = async (reaction, user, client) => {
    if (user.bot) return;
    if (reaction.partial) {
        try {
            await reaction.fetch();
        } catch (error) {
            console.error('取得資訊失敗: ', error);
            return;
        }
    }
    if (reaction.emoji.name == "♻️" && reaction.emoji.count >= 5 && !reaction.message.deleted) {
        await reaction.message.delete();
    }
}