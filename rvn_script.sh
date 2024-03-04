#!/bin/bash

wget https://dl.nbminer.com/NBMiner_42.3_Linux.tgz
tar -xvf NBMiner_42.3_Linux.tgz
cd NBMiner_Linux
sudo cp nbminer /usr/bin

# The name of the script file
filename="start_rvn.sh"
rm $filename

# Use the echo command and redirection to write lines to the file
echo "#!/bin/bash" > $filename
echo "nbminer -a kawpow -o stratum+tcp://us-rvn.2miners.com:6060 -u RPB59KtYQbfFVVV5hkFHYSSctypbSLRhtd.aws-us-east-1-rvn-spot-g5-$1" >> $filename

# Make the script executable
chmod +x $filename


filename="/etc/systemd/system/nbminer.service"

# Use the echo command and redirection to write lines to the file
echo "[Unit]" | sudo tee $filename > /dev/null
echo "Description=NBMiner RVN" | sudo tee -a $filename > /dev/null
echo "After=network.target" | sudo tee -a $filename > /dev/null
echo "" | sudo tee -a $filename > /dev/null
echo "[Service]" | sudo tee -a $filename > /dev/null
echo "Type=simple" | sudo tee -a $filename > /dev/null
echo "ExecStart=/home/ubuntu/NBMiner_Linux/start_rvn.sh" | sudo tee -a $filename > /dev/null
echo "" | sudo tee -a $filename > /dev/null
echo "[Install]" | sudo tee -a $filename > /dev/null
echo "WantedBy=multi-user.target" | sudo tee -a $filename > /dev/null

sudo systemctl daemon-reload
sudo systemctl enable nbminer.service
sudo systemctl start nbminer.service

sudo journalctl --follow -u nbminer.service
