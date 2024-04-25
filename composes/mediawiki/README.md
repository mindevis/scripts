# How to use this mysql docker compose file
## For downloading this docker compose data usage command
```
wget https://raw.githubusercontent.com/mindevis/scripts/main/composes/mediawiki/scripts/init.sh && chmod +x init.sh
```
## Usage for setup MediaWiki with Percona MySQL 5.7 and phpMyAdmin
```
bash init.sh --setup --package percona --version 5.7 --mysql-port 3306 --pma-enable true --pma-port 80
```
## Usage for setup MediaWiki with Percona MySQL 5.7 without phpMyAdmin
```
bash init.sh --setup --package percona --version 5.7 --mysql-port 3306 --pma-enable false --pma-port 80
```
## Usage for setup MediaWiki with Percona MySQL 8.0 and phpMyAdmin
```
bash init.sh --setup --package percona --version 8.0 --mysql-port 3306 --pma-enable true --pma-port 80
```
## Usage for setup MediaWiki with Percona MySQL 8.0 without phpMyAdmin
```
bash init.sh --setup --package percona --version 8.0 --mysql-port 3306 --pma-enable false --pma-port 80
```
### If need setup docker network with custom CIDR usage 
```
--network 10.2.26.0./24
```
