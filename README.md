# sqlite-nfs-chemotherapy
An answer to a problem that probably should exist but I'm lazy so here ya go.

## Why are you here?

Your shit is *fucked.* You were dockerizing all of the things in your shiny new swarm running in your homelab. Everything was going great... until it wasn't. Suddenly, your servarr containers are screaming about database errors. You try and restore a backup (you configured automatic backups, right? right?!) and it might fix it for a while, but the corruption returns. You realize that the Servarr suite uses SQLite, a flatfile database engine that relies on locking a database file. NFS (v3 anyway) is horrible for SQLite and if people find out you attempted to use it they'll say you are human garbage. We are... but that's besides the point.

The Servarr suite, Plex, Vaultwarden, and maaaaany other applications use SQLite as their database engine because it's simple - and stupid. But that's a good thing! Unless you're using NFS or SMB and there's literally anything else going on on the destination filesystem. Then it's not so simple. Then it dies, taking your data down with it. This may result in a horrifically slow application (looking at you, Sonarr...) or a completely destroyed database that causes the application to die pre-emptively as soon as it gets a look at it.

Death is bad. Why not suffer from metaphorical cancer instead? Introducing... **sqlite-nfs-chemotherapy**!

## What is this?

It's my hastily written hunk of shit that essentially copies the database files to `/tmp`, symlinks them to the their original path, and copies the local database file (yes, with the `sqlite` command and not just `rsync` or `cp`, even if I wanted too...) back to the NFS mount periodically. The result is *less* corruption and less slowness! Notice I said less and not zero.

## What isn't this?

This doesn't allow you to have multiple replicas of the servarr suite, or any other SQLite based application running in a container. Why would you ever want to do that? Why would you ever **want** to do that? Stop it. Get some help. 

# Disclaimer

This is horrible and if you decide to use it you are horrible, like me. Probably worse, honestly. It'll take a literal shit on your databases and tell your children that they were adopted. May God have mercy on your soul if you decide to use this in your "production" environment. Back your stuff up. Repeatedly. Every nanosecond. You have been warned.
