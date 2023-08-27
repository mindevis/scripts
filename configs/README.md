# How to use this configs
## For downloading this configs usage this commands
### HTTP DOCKER
```
curl -o /etc/nginx/sites-available/SITE* https://raw.githubusercontent.com/mindevis/scripts/main/configs/config.http-docker.example
```
### HTTP PHP-FPM
```
curl -o /etc/nginx/sites-available/SITE* https://raw.githubusercontent.com/mindevis/scripts/main/configs/config.http-php-fpm.example
```

### HTTPS DOCKER
```
curl -o /etc/nginx/sites-available/SITE* https://raw.githubusercontent.com/mindevis/scripts/main/configs/config.https-docker.example
```
### HTTPS PHP-FPM
```
curl -o /etc/nginx/sites-available/SITE* https://raw.githubusercontent.com/mindevis/scripts/main/configs/config.https-php-fpm.example
```
## After downloading usage this commands for configure nginx
### FOR DOCKER CONFIG
```
sed -i 's/DOMAIN/Enter domain this/g' /etc/nginx/sites-available/SITE*; sed -i 's/PORT/Enter port this/g' /etc/nginx/sites-available/SITE*
```
### FOR PHP-FPM CONFIG
```
sed -i 's/DOMAIN/g.qdevis.by/g' /etc/nginx/conf.d/SITE*; sed -i "s/VER/$(dpkg -l | grep fpm | awk {'print $2'})/g" /etc/nginx/conf.d/SITE*; sed -i 's/ROOTPATH/Enter this path to site/g' /etc/nginx/conf.d/SITE*
```