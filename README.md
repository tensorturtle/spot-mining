# spot-mining
Playbook for RVN mining on AWS EC2 spot instances

# Infrastructure Setup

We use Ohio: `us-east-2` region.

Go to AWS Console -> EC2 -> Spot Requests -> `Request Spot Instances`

AMI: Deep Learning OSS Nvidia driver AMI GPU PyTorch 2.1.0 (Ubuntu 20.04)

In `Target capacity`, tick `Maintain target capacity` and Interruption behavior: `Stop`

In `Instance type requirements` tick `Manually select instance types`. Delete pre-existing ones and add `g5.xlarge`.

# Instance Initial Setup

## NBMiner for Raven (RVN)

Install NBMiner: https://github.com/NebuTech/NBMiner

Download `NBMiner_42.3_Linux.tgz`:
```
wget https://dl.nbminer.com/NBMiner_42.3_Linux.tgz
tar -xvf NBMiner_42.3_Linux.tgz
```

```
cd NBMiner_Linux
```

Copy `nbminer` executable to a PATH location:
```
sudo cp nbminer /usr/bin
```

Edit `start_rvn.sh` with your pool URL and wallet ID. Also, remove the `./` in front of `nbminer` since we put it on PATH already.
Also, add `#!/bin/bash` at the top.

```
vim start_rvn.sh
```

It should now look something like:
```
#!/bin/bash
nbminer -a kawpow -o stratum+tcp://asia-rvn.2miners.com:6060 -u RPB59KtYQbfFVVV5hkFHYSSctypbSLRhtd.aws-seoul-rvn-spot-p2-1
```

To persist this program, create a systemd service.
```
sudo vim /etc/systemd/system/nbminer.service
```
And copy-paste:
```
[Unit]
Description=NBMiner RVN
After=network.target

[Service]
Type=simple
ExecStart=/home/ubuntu/NBMiner_Linux/start_rvn.sh

[Install]
WantedBy=multi-user.target
```


Make sure this starts on boot
```
sudo systemctl daemon-reload
sudo systemctl enable nbminer.service
sudo systemctl start nbminer.service
```

Monitor the process:
```
sudo journalctl --follow -u nbminer.service
```

## lolMiner for Nexa

```
cd ~
wget https://github.com/Lolliedieb/lolMiner-releases/releases/download/1.84/lolMiner_v1.84_Lin64.tar.gz
tar -xvf lolMiner_v1.84_Lin64.tar.gz
mv 1.84 lolMiner
cd lolMiner
sudo cp lolMiner /usr/bin
```
Create a `mine_nexa_2miners.sh`:
```
vim mine_nexa_2miners.sh
```
It should look something like:
```
#!/bin/bash
lolMiner --algo NEXA --pool nexa.2miners.com:5050 --user nexa:nqtsq5g5vld08wyr26uxhqml9jczc2x2ldgf0kn4vhpj5mam.aws-seoul-p3
```
Give it execution privilege:
```
sudo chmod +x mine_nexa_2miners.sh
```
To persist this program, create a systemd service.
```
sudo vim /etc/systemd/system/lolminer.service
```
And copy-paste:
```
[Unit]
Description=lolMiner Nexa
After=network.target

[Service]
Type=simple
ExecStart=/home/ubuntu/lolMiner/mine_nexa_2miners.sh

[Install]
WantedBy=multi-user.target
```


Make sure this starts on boot
```
sudo systemctl daemon-reload
sudo systemctl enable lolminer.service
sudo systemctl start lolminer.service
```

Monitor the process:
```
sudo journalctl --follow -u lolminer.service
```



# Reconnecting after Interruption

The above configuration ensures that even if this spot instance is interrupted, it should start mining again once it automatically comes back.

However, the IP address may change.
