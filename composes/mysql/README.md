# How to use this mysql docker compose file
## For downloading this docker compose data usage command
```
wget https://raw.githubusercontent.com/mindevis/scripts/main/composes/mysql/init.sh && chmod +x init.sh
```
## Usage for setup Percona MySQL 5.7 with phpMyAdmin
```
bash init.sh --setup --version 5.7 --mysql-port 3306 --pma-enable true --pma-port 80
```
## Usage for setup Percona MySQL 5.7 without phpMyAdmin
```
bash init.sh --setup --version 5.7 --mysql-port 3306 --pma-enable false --pma-port 80
```
## Usage for setup Percona MySQL 8.0 with phpMyAdmin
```
bash init.sh --setup --version 8.0 --mysql-port 3306 --pma-enable true --pma-port 80
```
## Usage for setup Percona MySQL 8.0 without phpMyAdmin
```
bash init.sh --setup --version 8.0 --mysql-port 3306 --pma-enable false --pma-port 80
```
