# How to use this gitea docker compose file
## For downloading this docker compose data usage command
```
wget https://raw.githubusercontent.com/mindevis/scripts/main/composes/gitea/scripts/init.sh && chmod +x init.sh
```
## Usage for setup Percona MySQL 5.7 without phpMyAdmin
```
bash init.sh --setup --git-ssh-port 2264 --git-http-port 80 --git-https-port 443 --domain domain.tld --database percona --version 5.7 --mysql-port 3306
```
## Usage for setup Percona MySQL 8.0 without phpMyAdmin
```
bash init.sh --setup --git-ssh-port 2264 --git-http-port 80 --git-https-port 443 --domain domain.tld --database percona --version 8.0 --mysql-port 3306
```
### If need setup docker network with custom CIDR usage 
```
--network 10.2.26.0./24
```
