#!/bin/bash
#======================header========================================|
#AUTOR
# Jefferson 'Slackjeff' Rocha <root@slackjeff.com.br>
#
#HACKTuite
# Static Microblog V.0.6
#====================================================================|

#======================> GLOBAL VARS
export main_archive="${HOME}/hacktuite"
export temp_archive="/tmp/temp_hacktuite_archive"

#===========================> LIBS
# Load conf ;)
source "${HOME}/hacktuite/hacktuite.conf"

#===========================> TEST
[[ -e "$temp_archive" ]] && rm "$temp_archive" # Clean trash file.

##########################
# CORE FUNCTIONS
##########################
# New post
NEW_POST()
{

    # Write post.
    if [[ "$ENABLE_EDITOR" = '0' ]]; then
        echo -e "\n\e[31;1mTYPE (ENTER) and (CTRL + D) FOR END OF FILE.\e[m"
        post=$(cat > $temp_archive)
        post=$(sed -z 's/\n/ /g' $temp_archive 2>/dev/null)
        if [[ -z "$post" ]]; then
            echo "Null Post? grrrrrt."
        fi
    else
        "$MY_EDITOR" "$temp_archive"
        post=$(sed -z 's/\n/ /g' $temp_archive 2>/dev/null)
    fi

    inc=0
    for image_or_video in 'IMAGE' 'VIDEO' 'NO THKS'; do
        inc=$(( inc + 1 ))
        echo -e " (\e[31;1m$inc\e[m) $image_or_video"
    done
    read -p $'\nAdd IMAGE or VIDEO in your post? ' add_image_or_video
    add_image_or_video="${add_image_or_video,,}" # Lowercase
    # Active Key
    if [[ "$add_image_or_video" = '1' ]]; then
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
    elif [[ "$add_image_or_video" = '2' ]]; then
        video="on"
        while true; do
            read -ep "Full Video directory: " video_directory
            if [[ ! -e "$video_directory" ]]; then
                echo "Video don't Exist."
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
        date_post="$(date "+%d/%B/%Y at %H:%M:%S")"

        # Image on Post?
        if [[ "$image" = 'on' ]]; then
            cp -v "$image_directory" "${main_archive}/img/"
            # Capture only name of picture.
            pushd "${main_archive}/img/" &>/dev/null
            for cap in *; do
                if [[ "$image_directory" =~ .*${cap}.* ]]; then
                    image_directory="$cap"
                fi
            done
            popd &>/dev/null
            # For sed
            pattern='<ul class="posts">' # Search pattern
            thepost="<li>(<b class="date">${date_post}</b>)<br><br>${post}<br><a href="img/${image_directory}"><img src="img/${image_directory}" class="image"></a></li>" # New post insert
            # Insert Post in html.
            sed -i "/^${pattern}.*/a \\\t${thepost}" "${main_archive}/index.html"
        # Video on post
        elif [[ "$video" = 'on' ]]; then # 
            cp -v "$video_directory" "${main_archive}/video/"
            # Capture only name of video.
            pushd "${main_archive}/video/" &>/dev/null
            for cap in *; do
                if [[ "$video_directory" =~ .*${cap}.* ]]; then
                    video_directory="$cap"
                fi
            done
            popd &>/dev/null
            # For sed
            pattern='<ul class="posts">' # Search pattern
            thepost="<li>(<b class="date">${date_post}</b>): ${post}<br><video controls width="50%" height="20%" class=\'video\'><source src="video/${cap}" type="video/mp4"></video></li>"
            # Insert Post in html.
            sed -i "/^${pattern}.*/a \\\t${thepost}" "${main_archive}/index.html"          
        else
            # For sed
            pattern='<ul class="posts">' # Search pattern
            thepost="<li>(<b class="date">${date_post}</b>): ${post}</li>" # New post insert

            # Insert Post in html.
            sed -i "/^${pattern}.*/a \\\t${thepost}" "${main_archive}/index.html"
        fi

        # Need send to server or only local archives?
        if [[ "$SEND_TO_SERVER" = '0' ]]; then
           read -p "Your post has been sent successfully! [ENTER TO CONTINUE]"
           return 0
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

##############################
######### HTML
##############################

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
<meta http-equiv="content-type" content="text/html; charset=UTF-8"/>
    <meta name="author" content="hacktuite co."/>
    <meta name="description" content="hacktuite The TRUE Decentralized Static Microblog.">
    <meta name="keywords" content="microblog, shell, hacktuite">
    <meta name="description" content="Hacktuite, $NICK"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="shortcut icon" type="image/png" href="favicon.jpg"/>
    <style>
        body {background-color: white; color: black; font-family: sans-serif; font-size: 1.2em; max-width: 40em; margin-left: auto; margin-right: auto;}
        .logo {color: black; border: 3px dotted; padding: 1%;}
        ul>li{list-style: none;padding: 2%; background-color: #d6d6d6; margin: 3%;}
        li {}
        .image{max-width: 90%; margin-top: 4%; margin-bottom: 2%;}
        .video{max-width: 90%; margin: 2%;}

        @media screen and (max-device-width: 480px) {
            body {font-size: 135%;}
            .logo{font-size: 10px;}
            .image{width: 100%;}
            .video{width: 100%;}
        }
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

