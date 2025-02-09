#! /bin/bash
host=""
echo "Please input host domain or IP:"
read host
if [ "$host" = "" ]; then
	host=""
fi

login_name=""
echo "Please input login name:"
read login_name
if [ "$login_name" = "" ]; then
	login_name=""
fi

password=""
echo "Please input password:"
read password
if [ "$password" = "" ]; then
	password=""
fi

port="7070"
echo "Please input ssh listem port:"
read -p "(Default port: 7070):" port
if [ "$port" = "" ]; then
	port="7070"
fi

cat>>/usr/bin/ssh-proxy.sh <<EOF
#! /bin/bash
auto_login_ssh () {
    expect -c "set timeout -1;
        spawn -noecho ssh -D $port -qfnN -o StrictHostKeyChecking=no $2 ${@:3};
        expect {
            *assword:* {send -- $1\r;
                         expect { 
                            *denied* {exit 2;}
                            eof
                         }
            }
            eof         {exit 1;}
        }
        " 
    return $?
}
 
auto_login_ssh $password $login_name@$host
EOF
chmod 755 /usr/bin/ssh-proxy.sh

cat>>~/Library/LaunchAgents/com.hearrain.ssh-proxy.plist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.hearrain.ssh-proxy.plist</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/ssh-proxy</string>
    </array>
    <key>KeepAlive</key>
    <false/>
    <key>RunAtLoad</key>
    <true/>
    <key>StandardErrorPath</key>
    <string>/tmp/ssh-proxy.err</string>
    <key>StandardOutPath</key>
    <string>/tmp/ssh-proxy.out</string>
</dict>
</plist>
EOF
