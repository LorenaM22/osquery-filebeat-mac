#!/bin/bash

#comprobar que hay dos argumentos
if [ -z "$3" ]
then 
	echo "Argumentos insufucientes"
	echo $3
	echo $1
	echo $2
fi
#Global vars
FILEBEAT_VERSION="7.10.0"

#Install brew
echo "[+] - Installing brew"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

#Install osquery
echo "[+] - Installing osquery"
brew install --cask osquery

cd /var/osquery

#Download osquery.conf
echo "[+] - Downloading osquery.conf"
sudo curl -L -O https://raw.githubusercontent.com/LorenaM22/osquery-filebeat-mac/master/osquery.conf

#Ejecutar osquery daemon
echo "[+] - Starting osquery daemon"
sudo osqueryctl start

#Install filebeat
cd /Users/$3/Downloads

#Download filebeat
echo "[+] - Downloading filebeat"
sudo curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.11.1-darwin-x86_64.tar.gz

#Extract zip
echo "[+] - Unzipping filebeat"
sudo tar xzvf filebeat-7.11.1-darwin-x86_64.tar.gz

sudo cp -r filebeat-7.11.1-darwin-x86_64 /Users/$3/Desktop/filebeat

#Get filebeat config
cd /Users/$3/Desktop/filebeat
sudo rm filebeat.yml

echo "[+] - Downloading filebeat.yml"
sudo curl -L -O https://raw.githubusercontent.com/LorenaM22/osquery-filebeat-mac/master/filebeat.yml

#Set logstash server
echo "[+] - Setting Logstash in filebeat config"
sudo sed -i ' ' "s/logstash_ip_addr/${1}/g" filebeat.yml
sudo sed -i ' ' "s/logstash_port/${2}/g" filebeat.yml
sudo sed -i ' ' "s/username/${3}/g" filebeat.yml

#Download certs
echo "[+] - Downloading filebeat certs"
sudo curl -L -O https://raw.githubusercontent.com/LorenaM22/osquery-filebeat-mac/master/certs.zip
sudo tar xzvf certs.zip
sudo mkdir certs
sudo mv beat* certs
sudo mv ca* certs

#osquery module
echo "[+] - Downloading osquery module"
cd modules.d
sudo rm osquery*
sudo curl -L -O https://raw.githubusercontent.com/LorenaM22/osquery-filebeat-mac/master/osquery.yml
sudo chown root osquery.yml

#Start filebeat service
echo "[+] - Starting filebeat service"
cd ..
sudo chown root filebeat.yml
sudo ./filebeat -e
 exit 8
