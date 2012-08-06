#!/bin/sh


cd seeds/files/dev-vm/
tar cvf config.tar config
tar cvf scripts.tar scripts
cd -


rsync -avz -e ssh ./seeds/ root@mirror.citiviz.vpn:/srv/seeds/
rsync -avz -e ssh root@mirror.citiviz.vpn:/srv/repo/ ./repo/
