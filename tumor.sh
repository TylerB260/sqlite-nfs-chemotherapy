#!/bin/bash
CHEMO_CADENCE=900 # how often are the databases written?

echo Chemotherapy: The synchronization tumor is lurking...

write_database() {
  echo Chemotherapy: Time for your appointment! Writing databases to NFS share...
  
  for I in 1 2 3 4 5; do
    if [ ! -z "$CHEMO_DB$I" ]; then
      dbuniq="CHEMO_DB$I"
      dbfull=$CHEMO_DB$I
      dbpath=$(dirname -- "$dbfull")
      dbfile=$(basename -- "$dbfull")
      dbname="${dbfile%.*}"
      dbext="${dbfile##*.}"
      
      echo /tmp/$dbuniq.db_local -> $dbpath/$dbname.${dbext}_remote
      sqlite3 "/tmp/$dbuniq.db_local" ".backup $dbpath/$dbname.${dbext}_remote"
    fi
  done
}

while [ true ]; do
  write_database
  echo Chemotherapy: Synchronization appointment completed, waiting $CHEMO_CADENCE seconds...
  sleep $CHEMO_CADENCE
done

chemo_death() {
  echo Chemotherapy: Death is imminent. Preparing to rest in peace...
  write_database
  echo Chemotherapy: Databases have been written to the NFS share, goodbye!
}

trap chemo_death SIGINT SIGTERM SIGHUP SIGKILL
