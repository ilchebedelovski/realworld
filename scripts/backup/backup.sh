#!/bin/sh

# Initializing infrastructure on DigitalOcean
# Author: Ilche Bedelovski

cd "$(dirname "$0")"

backup_file="/data/db-$(date +"%Y%m%d%H%M").sql"

# Check if the application is deployed and the database exist
if psql -h $PG_HOST -p $PG_PORT -U $PG_USER -lqt | cut -d \| -f 1 | grep -qw $DB_NAME; then

  # Creating databse dump file
  pg_dump -h $PG_HOST -p $PG_PORT -U $PG_USER -Z6 -Fc $DB_NAME -f $backup_file

  # Uploading the databse to DigitalOcean Space bucket
  python s3cmd/s3cmd --config /config/.s3cfg put $backup_file s3://$BUCKET_NAME/

  echo -e "Backup created and uploaded to DigitalOcean bucket\n"

  # Removing the dump file
  rm -f $backup_file

else

  echo -e "The specified database is still not created\n"

fi
