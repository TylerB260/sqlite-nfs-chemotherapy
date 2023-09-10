#!/bin/bash
echo Chemotherapy: Installing sqlite...
apk add -U --no-cache sqlite

for I in 1 2 3 4 5; do
  dbuniq="CHEMO_DB$I"
  dbfull=${!dbuniq}

  if [ ! -z "$dbfull" ]; then
    echo Chemotherapy: Patient $dbuniq checking in: $dbfull
    dbpath=$(dirname -- "$dbfull")
    dbfile=$(basename -- "$dbfull")
    dbname="${dbfile%.*}"
    dbext="${dbfile##*.}"

    if [ ! -f "$dbpath/$dbname.${dbext}_remote" ]; then
      echo Chemotherapy: STOP!!! You need to rename this file to $dbname\_remote otherwise your database will actually get cancer!!!
      echo A symlink will be created with the original filename - the symlink is ephemeral and WILL be removed when this script runs.
      echo Let this be a lesson - back up your shit!
      sleep infinity
    fi

    cp -fv $dbpath/$dbname.${dbext}_remote /tmp/$dbuniq.db_local
    rm -fv $dbpath/$dbname.${dbext} # NOT the remote, this is the symlink! Did you even read the message above?
    ln -sv /tmp/$dbuniq.db_local $dbpath/$dbname.${dbext}  

    chown $PUID:$PGID $dbpath/$dbname.${dbext}
    chmod 644 $dbpath/$dbname.${dbext}
  fi
done
