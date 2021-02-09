#!/bin/bash
bucket="pmk-server-1"
dirProjects="/var/www/"
dirBackups="/home/webuser/.backups/conf"
dirNginx="/etc/nginx/sites-available/"
dayNumber=$(date +'%u')
weekNumber=$(date +'%V')
owner="webuser"

echo ""
echo "> Preparing folders..."
mkdir -p $dirBackups
chown $owner:$owner $dirBackups
cd $dirBackups

mkdir -p ./env
mkdir -p ./nginx
mkdir -p ./config

chown $owner:$owner ./env
chown $owner:$owner ./nginx
chown $owner:$owner ./config

rm -rf ./env/*
rm -rf ./nginx/*
rm -rf ./config/*

echo "> Backup .env files..."
shopt -s dotglob
find $dirProjects* -prune -type d | while IFS= read -r d; do
  dirName=$(echo "$d" | grep -oP "^$dirProjects\K.*")
  envPath="${d}/shared/.env"
  cp $envPath "./env/${dirName}_day_${dayNumber}.env" 2>/dev/null || :
  cp $envPath "./env/${dirName}_week_${weekNumber}.env" 2>/dev/null || :
done

echo "> Backup NginX project config files..."
for projectPath in $dirNginx*; do
  projectName=${projectPath##*/}
  cp $projectPath "./nginx/${projectName}_day_${dayNumber}" 2>/dev/null || :
  cp $projectPath "./nginx/${projectName}_week_${weekNumber}" 2>/dev/null || :
done

echo "> Backup server config files..."
cp /etc/nginx/nginx.conf "./config/nginx_day_${dayNumber}.conf"
cp /etc/nginx/nginx.conf "./config/nginx_week_${dayNumber}.conf"

cp /etc/php/7.3/fpm/php.ini "./config/php_7.3_day_${dayNumber}.ini"
cp /etc/php/7.3/fpm/php.ini "./config/php_7.3_week_${dayNumber}.ini"

cp /etc/mysql/conf.d/mysql.cnf "./config/mysql_day_${dayNumber}.cnf"
cp /etc/mysql/conf.d/mysql.cnf "./config/mysql_week_${weekNumber}.cnf"

cp /etc/mysql/mysql.conf.d/mysqld.cnf "./config/mysqld_day_${dayNumber}.cnf"
cp /etc/mysql/mysql.conf.d/mysqld.cnf "./config/mysqld_week_${weekNumber}.cnf"

cp /etc/php/7.3/fpm/pool.d/www.conf "./config/www.conf_7.3_day_${dayNumber}.conf"
cp /etc/php/7.3/fpm/pool.d/www.conf "./config/www.conf_7.3_week_${weekNumber}.conf"

cp /etc/nginx/fastcgi_params "./config/fastcgi_params_day_${dayNumber}"
cp /etc/nginx/fastcgi_params "./config/fastcgi_params_week_${weekNumber}"

echo "> Upload ${dirBackups} to Google Cloud Storage into gs://${bucket}/conf"
gsutil -m cp -c -n -r $dirBackups gs://$bucket/ > /dev/null 2>&1
echo "> DONE!"
