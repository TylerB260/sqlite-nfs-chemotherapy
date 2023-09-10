# sqlite-nfs-chemotherapy
An answer to a problem that probably *should* exist but I'm lazy and I know you are too, so here ya go.

# Disclaimer

This is horrible and if you decide to use it you are horrible, like me. Probably worse, honestly. It'll take a literal shit on your databases and tell your children that they were adopted. May God have mercy on your soul if you decide to use this in your "production" environment. Back your stuff up. Repeatedly. Every nanosecond. You have been warned.

## Why are you here?

Your shit is *fucked.* You were dockerizing all of the things in your shiny new swarm running in your homelab. Everything was going great... until it wasn't. Suddenly, your servarr containers are screaming about database errors. You try and restore a backup (you configured automatic backups, right? right?!) and it might fix it for a while, but the corruption returns. You realize that the Servarr suite uses SQLite, a flatfile database engine that relies on locking a database file. NFS (v3 anyway) is horrible for SQLite and if people find out you attempted to use it they'll say you are human garbage. We are... but that's besides the point.

The Servarr suite, Plex, Vaultwarden, and maaaaany other applications use SQLite as their database engine because it's simple - and stupid. But that's a good thing! Unless you're using NFS or SMB and there's literally anything else going on on the destination filesystem. Then it's not so simple. Then it dies, taking your data down with it. This may result in a horrifically slow application (looking at you, Sonarr...) or a completely destroyed database that causes the application to die pre-emptively as soon as it gets a look at it.

Death is bad. Why not suffer from metaphorical cancer instead? Introducing... **sqlite-nfs-chemotherapy**!

## What is this?

It's my hastily written hunk of shit that essentially copies the database file to `/tmp`, symlinks it back to their original path, and copies the local database file (yes, with the `sqlite` command and not just `rsync` or `cp`, even if I really wanted to...) back to the NFS mount periodically. The result is *less* corruption and less slowness! Notice I said less and not zero.

## What isn't this?

This doesn't allow you to have multiple replicas of the servarr suite, or any other SQLite based application running in a container. Why would you ever want to do that? **Why would you ever *want* to do that?** Stop it. Get some help. 

---

# Configuration

## How can I customize this?

Boy, I am glad you asked! Environment variables! Are you surprised?

- `CHEMO_DB1` = `/config/cool_database.db` - Path to the original SQLite3 database file, **WITHOUT** the `_remote` suffix. e.g. `radarr.db`, `database.sqlite3`, or `app.sqlite`.
- `CHEMO_DB2` = `/data/even_cooler_db.sqlite` - Additional database file.
- `CHEMO_DB3` = `/etc/why_so_many_dbs.sqlite3` - Additional database file.
- `CHEMO_DB4` = `/var/stop_mounting_dbs.db` - Additional database file.
- `CHEMO_DB5` = `/bin/why_are_you_the_way_that_you_are.potato` - Additional database file.
- `CHEMO_CADENCE` = `900` - How often are your databases written back to the NFS share? **This is an integer in seconds.**
- `CHEMO_ENTRYPOINT` = `` - Overwriting the container's entrypoint? be a good person and call it from here so your stuff works.
- `PUID` = `(container's user)` - What user (id) should own the symlink? If you're using LinuxServer.io containers you've seen this before. If you don't specify anything its smart enough to figure it out.
- `PGID` = `(container's group)` - What group (id) should own the symlink? Again, the script is somehow smart enough to figure it out on its own if you don't speciy anything.
- `POSIX` = `644` - What permissions should be assigned to the symlink?

## How do I use this?

1. Rename the original database file so that it ends with _remote.
   - This is to delineate this as the "master" copy of the database.
2. Define the environment variable(s) `CHEMO_DB1` through `CHEMO_DB5` if you're feeling adventurous.
   - These are simply paths to the database file(s) you renamed, but without the _remote.
   - If you've got more than 5 in one container then you're doing something wrong. Seek help.
   - Make sure to review the other environment variables as well!
3. Add a mount for the `tumor.sh` script so that it can be called when the container is up and running.
   - If you've got some other method of including the script, great. I just work here, dude.
4. If you're using the LinuxServer.io containers, refer to their documentation on adding custom init scripts.
   - Add a mount in the `/custom-cont-init.d/` directory, pick a name that makes you feel special.
   - Read their documentation because I am not to be trusted: [Customizing our Containers - Custom Scripts](https://www.linuxserver.io/blog/2019-09-14-customizing-our-containers#custom-scripts)
5. If you're **NOT** using a LinuxServer.io container, check the publisher for something similar or just hijack their entrypoint like we're doing in the next script and cross your fingers.
   - This may or may not work, your mileage may vary.
7. Next, set the commandline arguments for the container or service to be the following: `/bin/bash /tmp/tumor.sh`
   - If your container doesn't have `bash`, then you're probably way too damn smart to need this joke of a script. And if you're that smart, why are you here?
8. Back your stuff up for the umpteenth time before relying on some random script you found on GitHub.
   - I am not responsible for your wife divorcing you or your mother giving you up for adoption. Seriously.
   - This script has the potential to go horrifically wrong, so you're on your own.

## What now?

Hopefully your SQLite containers are now attending their regularly scheduled chemotherapy appointments and are running smoothly. I hope for your sake that everything goes well and that there isn't a freak occurence of quadruple the dosage being given or something equally bad.
