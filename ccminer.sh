apt update
apt install zip nano -y
mkdir ccminer
wget -P ccminer https://github.com/1NF1N18Y/ccminer-Points/releases/download/v0.1-beta/test-release.zip &&
unzip ccminer/test-release.zip -d ccminer
chmod +x /ccminer/ccminer
