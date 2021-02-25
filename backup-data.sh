#!/bin/bash
PATH=/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/google-cloud-sdk/bin
HOME=/root

bucket="pmk-server-1"
projectsDir="/var/www"

cd $projectsDir

for project in * ; do
    echo ""
    echo "... upload ${project}/shared/data-protected to ${bucket}"
    gsutil -m cp -c -n -r $projectsDir/$project/shared/data-protected gs://$bucket/$project/data-protected > /dev/null 2>&1
    echo "+++ exported!"
    echo "... upload ${project}/shared/data to ${bucket}"
    gsutil -m cp -c -n -r $projectsDir/$project/shared/data gs://$bucket/$project/data > /dev/null 2>&1
    echo "+++ exported!"
done
