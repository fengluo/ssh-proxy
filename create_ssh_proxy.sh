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

cat>>ssh-proxy.sh <<EOF
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
chmod 755 ssh-proxy.sh