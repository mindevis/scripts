# How to use this percona-mysql docker compose file
## For downloading this docker compose data usage command
```
wget https://raw.githubusercontent.com/mindevis/scripts/main/composes/percona-mysql/init.sh; chmod +x init.sh
```
## Usage for setup Percona MySQL 5.7
```
bash init.sh --setup --version 5.7 --mysql-port 3306 --pma-port 80
```
## Usage for setup Percona MySQL 8.0
```
bash init.sh --setup --version 8.0 --mysql-port 3306 --pma-port 80
```