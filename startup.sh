#!/usr/bin/with-contenv /bin/bash
echo Chemotherapy: Installing SQLite3...

# escalators escalators escalators escalators...
if (type -p apk > /dev/null); then apk add -U --no-cache sqlite; fi
if (type -p apt > /dev/null); then apt install sqlite -y; fi

# eeeeeeeeels. well shit. todo: add yum/dnf support for rhel flavors.
if (type -p sqlite3 > /dev/null); then echo Chemotherapy: Not sure what distro we are on... help!; fi

PUID="${PUID:-$(id -u)}"
PGID="${PGID:-$(id -g)}"
POSIX="${POSIX:-644}"

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
      echo Chemotherapy: Checking for $dbpath/$dbname.${dbext}_remote: DOES NOT EXIST! 
      echo STOP!!! You need to rename the database file to $dbname\_remote otherwise your database will actually get cancer!
      echo A symlink will be created with the original filename - the symlink is ephemeral and WILL be removed when this script runs.
      echo I almost deleted your database file, but this handy dandy check prevented me from doing so. Let this be a lesson - back up your shit!
      sleep infinity
    fi

    cp -fv $dbpath/$dbname.${dbext}_remote /tmp/$dbuniq.db_local
    rm -fv $dbpath/$dbname.${dbext} # NOT the remote, this is the symlink! Did you even read the message above?
    ln -sv /tmp/$dbuniq.db_local $dbpath/$dbname.${dbext}  

    chown $PUID:$PGID $dbpath/$dbname.${dbext}
    chmod $POSIX $dbpath/$dbname.${dbext}
  fi
done
