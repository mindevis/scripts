# How to use this Grafana Loki Application docker compose file
## For downloading this docker compose data usage command
```
wget https://raw.githubusercontent.com/mindevis/scripts/main/composes/grafana/loki/scripts/init.sh && chmod +x init.sh
```
## Usage for setup loki app
```
bash init.sh --setup
```
### If need setup docker network with custom CIDR usage 
```
--network 10.2.26.0./24
```
