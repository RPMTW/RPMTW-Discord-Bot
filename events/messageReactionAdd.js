module.exports = async (reaction, user, client) => {
    if (reaction.partial) {
        try {
            await reaction.fetch();
        } catch (error) {
            console.error('Fetching message failed: ', error);
            return;
        }
    }
    if (!user.bot) {
        console.log(reaction.emoji.id);
        // if (reaction.emoji.id == "") { 
            
        // }
    }
}