**The TRUE Decentralized Static Microblog, write in Shell Bash** .

## What?
Are you tired of the great microblogging social media that is exploiting you? Do you just want to share some thought, somewhere simple, without these big companies getting your data?
Or do you want to go back to the past, where you were looking for what you would like to read without throwing anything in your face?
HackTUITE was written for this purpose, fully decentralized and minimalist. You host your own html page on your own server.

## For Example:
[http://slackjeff.com.br/hacktuite/](http://slackjeff.com.br/hacktuite/ "http://slackjeff.com.br/hacktuite/")

# DEPS:
- GNU bash >= 4.3.48 
- Sed >= 4.2.2
- Rsync >= 3.1.3

## Install 
1. FOR INSTALL use '**setup**' and follow the instructions.
2. Copy/Move script **hacktuite.sh** present in your HOME in $HOME/hacktuite, to /usr/bin or /usr/local/bin, or local of your choice.

## Documentation
Please acess [Github Wiki](https://github.com/slackjeff/hacktuite/wiki "Github Wiki")

## Future implementations
* Today hacktuite uses rsync to synchronize with the your server.
A future implementation will be supported to synchronize with the git repository. This is if you are going to use github pages to host your hacktuite.
* Post support video. (Still needs a future vote).
* Instead of receiving only input via cat, if a key in .conf is enabled it will be possible to write the post with the user's favorite text editor.
