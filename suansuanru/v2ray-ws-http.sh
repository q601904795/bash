#!/bin/bash

check_system() {
    if grep -Eqii "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
        OS='CentOS'
    elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
        OS='Debian'
    elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
        OS='Ubuntu'
    else
        OS='unknow'
    fi
}


check_system

[[ $OS == "Debian" ]] || [[ $OS == "Ubuntu" ]] && cmd='apt' && $cmd update -y 
[[ $OS == "CentOS" ]] && cmd='yum'

$cmd install curl lrzsz zip unzip psmisc uuid -y

bash <(curl -s -L https://raw.githubusercontent.com/q601904795/bash/master/suansuanru/lajiv2ray-install.sh)
rm -rf /usr/local/etc/v2ray/*.json
echo '
{
  "log": {
    "access": "/var/log/v2ray/access.log",
    "error": "/var/log/v2ray/error.log",
    "loglevel": "warning"
  },
  "dns": {},
  "stats": {},
  "inbounds": [
    {
      "port": 8848,
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "'`uuid`'",
            "alterId": 233
          }
        ]
      },
      "tag": "in-0",
      "streamSettings": {
        "network": "ws",
        "security": "aes-128-gcm",
        "wsSettings": {
          "path": "/static"
        }
      },
      "listen": "127.0.0.1"
    }
  ],
  "outbounds": [
    {
      "tag": "direct",
      "protocol": "freedom",
      "settings": {}
    },
    {
      "tag": "blocked",
      "protocol": "blackhole",
      "settings": {}
    }
  ],
  "routing": {
    "domainStrategy": "AsIs",
    "rules": [
      {
        "type": "field",
        "ip": [
          "geoip:private"
        ],
        "outboundTag": "blocked"
      }
    ]
  },
  "policy": {},
  "reverse": {},
  "transport": {}
}
' > /usr/local/etc/v2ray/config.json
ulimit -n 512000
service v2ray restart
uuid=`cat /usr/local/etc/v2ray/config.json | grep "id" | cut -d '"' -f 4`
ip=`curl -s http://whatismyip.akamai.com`
echo "
连接信息：
IP: $ip
端口:80
用户id:$uuid
额外id:233
加密方式:aes-128-gcm
传输协议:ws
伪装类型:none
伪装域名:$domain
路径:/static
底层传输安全:No

重复查看URL 请使用cat /etc/v2url.txt
"
txt='
{\n
  "v": "2",\n
  "ps": "'$domain'",\n
  "add": "'$ip'",\n
  "port": "80",\n
  "id": "'$uuid'",\n
  "aid": "233",\n
  "net": "ws",\n
  "type": "none",\n
  "host": "'$domain'",\n
  "path": "/static",\n
  "tls": ""\n
}'

encode=`echo -e $txt | base64`
url="vmess://$encode"
echo $url > /etc/v2url.txt
sed -i 's/[ ][ ]*//g' /etc/v2url.txt
cat /etc/v2url.txt
 
