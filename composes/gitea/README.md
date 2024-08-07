# How to use this gitea docker compose file
## For downloading this docker compose data usage command
```
wget https://raw.githubusercontent.com/mindevis/scripts/main/composes/gitea/scripts/init.sh && chmod +x init.sh
```
## Usage for setup Gitea
```
bash init.sh --setup --domain domain.tld --ssh-port 22 --http-port 80
```
## Usage for setup Gitea with database
```
bash init.sh --setup --ssh-port 22 --http-port 80 --domain domain.tld --db mysql --db-version 5.7 --db-port 3306
```
### If need expose database port in host system usage 
```
--expose-db-port true
```
### If need setup Gitea with https usage 
```
--ssl true
--ssl-port 443
```
### If need setup docker network with custom CIDR usage 
```
--network 10.2.26.0./24
```
