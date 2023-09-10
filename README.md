# sqlite-nfs-chemotherapy
An answer to a problem that probably *should* exist but I'm lazy and I know you are too, so here ya go. This script enables applications that use SQLite to live on an NFS / SMB share without having horrible performance and / or corruption. Saying that this allows them to "live" on the NFS share is a bit deceiving, but it serves my needs so I'm sure it will help someone out there on the internet.

# Disclaimer

This is horrible and if you decide to use it you are horrible, like me. Probably worse, honestly. It'll take a literal shit on your databases and tell your children that they were adopted. May God have mercy on your soul if you decide to use this in your "production" environment. Back your stuff up. Repeatedly. Every nanosecond. You have been warned.

## Supported Containers 

This is from my own personal testing, no officialy endorsement, yadda yadda yadda. Renaming the database is pretty much all you need to do for the linuxservers.io containers. 

- linuxserver/radarr: `/config/radarr.db` and `/config/logs.db`
  - Tested, working wonderfully, no issues.
- linuxserver/sonarr: `/config/sonarr.db` and `/config/logs.db`
  - Tested, working wonderfully, no issues.
- linuxserver/prowlarr: `/config/prowlarr.db` and `/config/logs.db`
  - Tested, working wonderfully, no issues.
- linuxserver/heimdall: `/config/www/app.sqlite`
  - Tested, working wonderfully, no issues.
- linuxserver/overseerr: `/config/db/db.sqlite3`
  - Tested, working wonderfully, no issues.
- linuxserver/sabnzbd: `/config/admin/history1.db`
  - Pretty much pointless, not enough I/O to warrant this and SABnzbd waits until it can write before screaming like the *arrs do.
 
For others, depending on the base image, your mileage may vary.

- jc21/nginx-proxy-manager: `/data/nginx/data/database.sqlite`
  - Untested, likely not necessary due to low I/O, not seeing any I/O errors like the *arrs.
- vaultwarden/server: `/config/dq.sqlite3`
  - Need to place the scripts in `/etc/vaultwarden.d/` instead.
  - Likely not necessary due to low I/O, not seeing any I/O errors like the *arrs.
  - Startup script has substitution error, crashes, needs work.
  - Shutdown script still WIP, beware.

## Why are you here?

Your shit is *fucked.* You were dockerizing all of the things in your shiny new swarm running in your homelab. Everything was going great... until it wasn't. Suddenly, your Servarr containers are screaming about database errors. You try and restore a backup (you configured automatic backups, right? right?!) and it might fix it for a while, but the corruption returns. You realize that the Servarr suite uses SQLite, a flatfile database engine that relies on locking a database file. NFS (v3 anyway) is horrible for SQLite and if people find out you attempted to use it they'll say you are human garbage. We are... but that's besides the point.

The Servarr suite, Plex, Vaultwarden, and maaaaany other applications use SQLite as their database engine because it's simple - and stupid. But that's a good thing! Unless you're using NFS or SMB and there's literally anything else going on on the destination filesystem. Then it's not so simple. Then it dies, taking your data down with it. This may result in a horrifically slow application (looking at you, Sonarr...) or a completely destroyed database that causes the application to die pre-emptively as soon as it gets a look at it.

Death is bad. Why not suffer from metaphorical cancer instead? Introducing... **sqlite-nfs-chemotherapy**!

## What is this?

It's my hastily written hunk of shit that essentially copies the database file to `/tmp`, symlinks it back to their original path, and copies the local database file (yes, with the `sqlite` command and not just `rsync` or `cp`, even though I really wanted to...) back to the original NFS / SMB mount periodically. The result is *less* corruption and less slowness! 

Notice I said less - not zero. 

## What *isn't* this?

This doesn't allow you to have multiple replicas of the Servarr suite, or any other SQLite based application running in a container. Why would you ever want to do that? **Why would you ever *want* to do that?** Stop it. Get some help. 

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
- `PUID` = `(container's user)` - What user (id) should own the symlink? If you're using LinuxServer.io containers you've seen this before. If you don't specify anything its smart enough to figure it out.
   - If you get read only database errors, this is likely why. Especially likely if you're using NFS since permissions are probably trash.
- `PGID` = `(container's group)` - What group (id) should own the symlink? Again, the script is somehow smart enough to figure it out on its own if you don't speciy anything.
   - Same disclaimer as above - if you get readonly issues, this may be related. 
- `POSIX` = `644` - What permissions should be assigned to the symlink?

## How do I use this?

1. Rename the original database file so that it ends with _remote.
   - This is to delineate this as the "master" copy of the database.
2. Define the environment variable(s) `CHEMO_DB1` through `CHEMO_DB5` if you're feeling adventurous.
   - These are simply paths to the database file(s) you renamed, but without the _remote.
   - If you've got more than 5 in one container then you're doing something wrong. Seek help.
   - Make sure to review the other environment variables as well!
3. If you're using LinuxServer.io containers, or other containers with s6-overlay utilies, add mounts for the `startup.sh`, `tumor.sh`, and `shutdown.sh` scripts as shown below.
   - `/mnt/wherever_you_keep_your_stuff/start.sh` -> `/etc/cont-init.d/startup.sh`
   - `/mnt/wherever_you_keep_your_stuff/tumor.sh` -> `/custom-services.d/tumor.sh`
     - Yes, I should switch this to the s6 `/etc/services.d/` folder, but I am lazy, as mentioned before. Sue me.
   - `/mnt/wherever_you_keep_your_stuff/shutdown.sh` -> `/etc/cont-finish.d/shutdown.sh`
   - I was originally using the LinuxServer.io documentation, but the s6-overlay utility suite they use has some more functionality listed here: [just-containers/s6-overlay](https://github.com/just-containers/s6-overlay)
   - Additionally, feel free to read their documentation too because I am not to be trusted: [Customizing our Containers - Custom Scripts](https://www.linuxserver.io/blog/2019-09-14-customizing-our-containers#custom-scripts)
   - If you've got some other method of including the scripts, great. I just work here, dude.
4. Back your stuff up for the umpteenth time before relying on some random script you found on GitHub.
   - I am not responsible for your wife divorcing you or your mother giving you up for adoption. Seriously.
   - These scripts have the potential to go horrifically wrong, so you're on your own.

## What now?

Hopefully your SQLite containers are now attending their regularly scheduled chemotherapy appointments and are running smoothly. I hope for your sake that everything goes well and that there isn't a freak occurence of quadruple the dosage being given or something equally bad.
