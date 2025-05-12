# How to use this pmm server docker compose file
## For downloading this docker compose data usage command
```
wget https://raw.githubusercontent.com/mindevis/scripts/main/composes/percona/monitoring/scripts/init.sh && chmod +x init.sh
```
## Usage for setup pmm server
```
bash init.sh --setup
```
### If need setup docker network with custom CIDR usage 
```
--network 10.2.26.0./24
```
