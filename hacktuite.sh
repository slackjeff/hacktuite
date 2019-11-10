#!/bin/bash
#======================header========================================|
#AUTOR
# Jefferson 'Slackjeff' Rocha <root@slackjeff.com.br>
#
#HACKTuite
# Static Microblog V.0.2
#====================================================================|

#======================> GLOBAL VARS
export main_archive="${HOME}/hacktuite"

#===========================> LIBS
# Load conf ;)
source "${HOME}/.config/hacktuite/hacktuite.conf"

##########################
# CORE FUNCTIONS
##########################

# New post
NEW_POST()
{
    # Write post.
    echo -e "\n\e[31;1mTYPE (ENTER) and (CTRL + D) FOR END OF FILE.\e[m"
    post=$(cat > /tmp/temp_hacktuite_archive)
    post=$(sed -z 's/\n/ /g' /tmp/temp_hacktuite_archive 2>/dev/null)
    if [[ -z "$post" ]]; then
        echo "Null Post? grrrrrt."
    fi

    read -p "Add Image in your post? [y/N] " image_in_post
    image_in_post="${image_in_post,,}" # Lowercase
    # Active Key
    if [[ "$image_in_post" = 'y' ]]; then
        image="on"
        while true; do
            read -ep "Full image directory: " image_directory
            if [[ ! -e "$image_directory" ]]; then
                echo "Image don't Exist."
                continue
            else
                break
            fi
        done
    fi

    read -p "Send post? [y/n] " send_post
    send_post="${send_post,,}" # lowercase
    if [[ "$send_post" = 'y' ]] || [[ -z "$send_post" ]]; then
        # Date of post
        date_post="$(date "+%d/%b/%Y às %H:%M:%S")"
        # Image on Post?
        if [[ "$image" = 'on' ]]; then
            cp -v "$image_directory" "${main_archive}/img/"
            # For sed
            pattern='<ul class="posts">' # Search pattern
            thepost="<li>(<b>${date_post}</b>): ${post}<br><a href="${image_directory}"><img src="${image_directory}" class="image"></a></li>" # New post insert

            # Insert Post in html.
            sed -i "/^${pattern}.*/a \\\t${thepost}" "${main_archive}/index.html"
        else
            # For sed
            pattern='<ul class="posts">' # Search pattern
            thepost="<li>(<b>${date_post}</b>): ${post}</li>" # New post insert

            # Insert Post in html.
            sed -i "/^${pattern}.*/a \\\t${thepost}" "${main_archive}/index.html"
        fi

        # SEND FOR SERVER
        if rsync -avzh "$main_archive" "${SERVER}":public_html/; then
           read -p "Your post has been sent successfully! [ENTER TO CONTINUE]"
            return 0
        else
            read -p "Your post has NOT been sent. Some error has occurred. [ENTER TO CONTINUE]"
            return 1
        fi

    fi
}

# new follower registration
FOLLOWERS()
{
    while true; do
        read -p $'What is the nickname of the person you want to follow?\n' name_follow
        name_follow="${name_follow,,}"
        [[ -n "$name_follow" ]] && break
    done

    while true; do
        read -p $'Ok... Now tell the url of the person you want to follow:(with http/https)\n' url_follow
        url_follow="${url_follow,,}"
        [[ -n "$url_follow" ]] && break
    done

    pattern='<ul class="following">' # Search pattern
    thepost="<li><a href=\"${url_follow}\">${name_follow}</a></li>" # New post insert

    # Insert Post in html.
    sed -i "/^${pattern}.*/a \\\t${thepost}" "${main_archive}/followers.html"

}

######### HTML
# The head of html ;)
HEAD_HTML()
{
    local name="$1"
    local archive="$2"

    cat <<EOF>> "${main_archive}/${archive}"
<!DOCTYPE html>
<html lang="pt-br">
<head>
	<title>${NICK} $name</title>
	<meta charset="utf-8">
	<style>
		body{background-color: black; color: #00feb9; font-size: 1.1em; margin: 1%;}
		.logo{color: #00feb9; border: 3px dotted; padding: 1%;}
        li{padding: 0.8%;}
        .image{width: 30%; border-style: dotted; margin: 2%;}
        a:link{color: #3df500;}
        a:visited{color: #3df500;}
	</style>
</head>
<body>
EOF
}

# The body, posts here.
MAIN_BODY_HTML()
{
    local name="$1"
    local archive="$2"

    cat <<EOF>> "${main_archive}/${archive}"
<a href="followers.html">${NICK} is following</a>
<h1>Posts by $NICK</h1>
<ul class="posts">
EOF
}

FOLLOWING_BODY_HTML()
{
    local name="$1"
    local archive="$2"

    cat <<EOF>> "${main_archive}/${archive}"
<h1>FOLLOWING OF $NICK</h1>
<ul class="following">
EOF
}

END_HTML()
{
    local name="$1"
    local archive="$2"

    cat <<EOF>> "${main_archive}/${archive}"
</ul>
</body>
</html>
EOF
}

# The logo of hacktuite
LOGO_HTML()
{
    local name="$1"
    local archive="$2"

    cat <<'EOF' >> "${main_archive}/${archive}"
<pre class="logo">
  _   _            _    _____      _ _         
 | | | | __ _  ___| | _|_   _|   _(_) |_ ___
 | |_| |/ _` |/ __| |/ / | || | | | | __/ _ \
 |  _  | (_| | (__|   <  | || |_| | | ||  __/
 |_| |_|\__,_|\___|_|\_\ |_| \__,_|_|\__\___|
                                             
    The TRUE Static Microblog
</pre>
EOF
}

#===========================> TEST
########################################################
# Index archive exist? No? Create.
########################################################
if [[ ! -e "${main_archive}/index.html" ]]; then
    HEAD_HTML 'HACKTUITE' "/index.html"
    LOGO_HTML '' "/index.html"
    MAIN_BODY_HTML '' "/index.html"
    END_HTML '' "/index.html"
fi

if [[ ! -e "${main_archive}/followers.html" ]]; then
    HEAD_HTML "Following" "/followers.html"
    LOGO_HTML '' "/followers.html"
    FOLLOWING_BODY_HTML '' "/followers.html"
    END_HTML '' "/followers.html"
fi

#===========================> MAIN
while true; do
    clear
    echo -e "------------------------------------------------------------------"
    echo -e "Welcome to the \e[36;1mHackTUITE\e[m, the true decentralized static microblog."
    echo -e "------------------------------------------------------------------"
    echo -e "YOUR USER: ${NICK}"
    echo -e "-----------------------\n"

    count='0'
    for menu in 'NEW POST' 'INSERT NEW FOLLOWER IN YOUR LIST' 'QUIT'; do
        count="$(( count + 1 ))"
        echo -e " (\e[36;1m${count}\e[m) ${menu}"
    done
    read -p $'\nOption: ' user_input
    case "$user_input" in
        1) NEW_POST ;;
        2) FOLLOWERS ;;
        3) exit 0 ;;
    esac
done

