#!/bin/bash
#======================header========================================|
#AUTOR
# Jefferson 'Slackjeff' Rocha <root@slackjeff.com.br>
#
#HACKTuite
# Static Microblog V.0.1
#====================================================================|



#===========================> VARS
nick='slackjeff'
server='slackjeff@slackjeff.com.br'
main_archive="hacktuite.html"

#===========================> FUNCS
HEAD_HTML()
{
    cat <<END>> "$main_archive"
<!DOCTYPE html>
<html lang="pt-br">
<head>
	<title>${nick} HackTuite</title>
	<meta charset="utf-8">
	<style>
		body{background-color: black; color: #00feb9; font-size: 1.1em; margin: 1%;}
		.logo{color: #00feb9; border: 3px dotted; padding: 1%;}
        li{padding: 0.8%;}
	</style>
</head>
END
}

LOGO_HTML()
{
    cat <<'EOF' >> "$main_archive"
<body>
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

BODY_HTML()
{
    cat <<END>> "$main_archive"
<h1>Postagens de $nick</h1>
<ul class="posts">
END
}

END_HTML()
{
    cat <<END>> "$main_archive"
</ul>
</body>
</html>
END
}

#===========================> TESTS
# Index archive exist? No? Create.
if [[ ! -e "$main_archive" ]]; then
    HEAD_HTML
    LOGO_HTML
    BODY_HTML
    END_HTML
fi

#===========================> MAIN
clear
echo "Welcome to the HackTUITE, the true static microblog."
echo -e "----------------------------------------------------\n"

# Write post.
post=$(cat > /tmp/temp_archive)
post=$(cat /tmp/temp_archive | sed -z 's/\n/ /g')
[[ -z "$post" ]] && { echo "Null Post? grrrrrt."; exit ;}

read -p "Send post? [y/n] " send_post
send_post="${send_post,,}" # lowercase
if [[ "$send_post" = 'y' ]]; then
    # Date of post
    date_post="$(date "+%d/%b/%Y às %H:%M:%S")"
    # For sed
    pattern='<ul class="posts">' # Search pattern
    thepost="<li>(<b>${date_post}</b>): ${post}</li>" # New post insert

    # Insert Post in html.
    sed -i "/^${pattern}.*/a \\\t${thepost}" "$main_archive"

    # SEND FOR SERVER
    scp "$main_archive" "${server}":public_html/
fi
