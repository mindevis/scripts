# How to use this atlassian docker compose file
## For downloading this docker compose data usage command
```
wget https://raw.githubusercontent.com/mindevis/scripts/main/composes/atlassian/scripts/init.sh && chmod +x init.sh
```
## Usage for setup Jira Software without PostgreSQL
```
bash init.sh --setup --package jira-software --jira-port 8080 --pg-enable false
```
## Usage for setup Jira Software with PostgreSQL
```
bash init.sh --setup --package jira-software --jira-port 8080 --pg-enable true
```
## Activate Jira Software
```
docker exec -it jira-software bash -c "java -jar /atlassian-agent.jar -d -m "email@email.com" -m "test.ru1" -o testru2 -p jira -s SERVER ID"
```
### If need setup docker network with custom CIDR usage 
```
--network 10.2.26.0./24
```
