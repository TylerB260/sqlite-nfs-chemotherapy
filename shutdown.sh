#!/usr/bin/with-contenv /bin/bash
echo Chemotherapy: Death is imminent. Preparing to rest in peace...

write_database() {
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

write_database
echo Chemotherapy: Databases have been written to the NFS share, goodbye!
