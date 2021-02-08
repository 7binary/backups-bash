#!/bin/bash
pw="mysql-secret"
bucket="pmk-server-1"
logfile="gsutil.log"
day_number=$(date +'%u')
week_number=$(date +'%V')

PATH=/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/google-cloud-sdk/bin
HOME=/root

echo "" > $logfile
chown webuser:webuser $logfile 
skip_db=("Database" "information_schema" "mysql" "performance_schema" "sys")

for dbname in `echo show databases| mysql -uroot -p$pw`; do
    # CHECK SKIP DATABASES
    if [[ " ${skip_db[@]} " =~ " ${dbname} " ]]; then
            continue
    fi
    echo ""
    echo "Dump $dbname..."

    # VARS
    fileDayTar="${dbname}_day_${day_number}.sql.gz"
    fileWeekTar="${dbname}_week_${week_number}.sql.gz"

    # DAYLY DUMP
    mysqldump -uroot -p$pw --insert-ignore --skip-lock-tables --single-transaction=TRUE $dbname | gzip > $fileDayTar

    echo "=> dumped ${dbname} > ${fileDayTar}"
    echo "... exporting to ${bucket}"
    gsutil cp $fileDayTar gs://$bucket/backups/$fileDayTar > $logfile 2>&1
    echo "+++ exported!"

    # WEEKLY DUMP
    mv $fileDayTar $fileWeekTar
    echo "=> copied ${fileDayTar} > ${fileWeekTar}"
    echo "... exporting to ${bucket}"
    gsutil cp $fileWeekTar gs://$bucket/backups/$fileWeekTar > $logfile 2>&1
    echo "+++ exported!"
    rm -f *.sql.gz
done;
