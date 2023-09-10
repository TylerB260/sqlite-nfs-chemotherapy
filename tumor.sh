#!/usr/bin/with-contenv /bin/bash
echo Chemotherapy: The synchronization tumor is lurking...

CHEMO_CADENCE="${CHEMO_CADENCE:-900}"

write_database() {
  echo Chemotherapy: Time for your appointment! Writing databases to NFS share...
  
  for I in 1 2 3 4 5; do
    dbuniq='CHEMO_DB'$I
    dbfull=${!dbuniq}

    if [ ! -z "$dbfull" ]; then
      dbpath=$(dirname -- "$dbfull")
      dbfile=$(basename -- "$dbfull")
      dbname="${dbfile%.*}"
      dbext="${dbfile##*.}"
      
      echo Chemotherapy: Copying database /tmp/$dbuniq.db_local to $dbpath/$dbname.${dbext}_remote
      sqlite3 "/tmp/$dbuniq.db_local" ".backup $dbpath/$dbname.${dbext}_remote"
    fi
  done
}

while [ true ]; do
  sleep $CHEMO_CADENCE
  write_database
  echo Chemotherapy: Synchronization appointment completed, waiting $CHEMO_CADENCE seconds...
done
