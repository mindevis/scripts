# How to use this docusaurus docker compose file
## For downloading this docker compose data usage command
```
wget https://raw.githubusercontent.com/mindevis/scripts/main/composes/docusaurus/scripts/init.sh && chmod +x init.sh
```
## Usage for setup Docusaurus
```
bash init.sh --setup --port 3000
```
### If need setup docker network with custom CIDR usage 
```
--network 10.2.26.0./24
```
