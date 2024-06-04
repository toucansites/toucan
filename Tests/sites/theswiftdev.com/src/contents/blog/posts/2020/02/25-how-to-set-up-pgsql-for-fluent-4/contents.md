---
slug: how-to-set-up-pgsql-for-fluent-4
title: How to set up pgSQL for Fluent 4?
description: This is a tutorial for beginners about using PostgreSQL. I'll show you how to automatically backup and restore the database.
publication: 2020-02-25 16:20:00
tags: Fluent, pgSQL
---

> NOTE: If you are already familiar with PostgreSQL, but you don't know much about how to use databases in Vapor, you should [read my other tutorial about Fluent for beginners](https://theswiftdev.com/a-tutorial-for-beginners-about-the-fluent-postgresql-driver-in-vapor-4/).

## A quick intro to PostgreSQL

[PostgreSQL](https://www.postgresql.org/) is an open source database, it's available for macOS, [Linux](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-postgresql-on-ubuntu-18-04) and some other operating systems. You can install it by using the de-facto package manager on every platform. 📦

```sh
# Linux
sudo apt-get install postgresql postgresql-contrib
sudo service postgresql start
# check service status
sudo service --status-all
sudo service postgresql status

# macOS
brew install postgresql
brew services start postgresql
# check service status
brew services list
```

You'll also need to set a proper password for the `postgres` user, which is the admin user by default with godlike permissions. You can change the root password, you just have to log in as a root & alter the postgres user record with the new pass. 🔑

```sh
# Linux
sudo -u postgres psql postgres
# macOS
psql -U postgres

# psql (12.1)
# Type "help" for help.
#
# postgres=#

# ALTER ROLE
alter user postgres with password 'mypassword';

# exit
\q
```

From now on you'll be able to access pgSQL as root on both platforms like this:

```sh
psql -h localhost -U postgres
```

It is recommended to use a dedicated user for every single database that you create instead of working with a shared root user. Let me show you how to create a new DB with an associated user.

```sh
# List of databases
\l
# Show current database
select current_database();
# Create new database
create database mydb;
# Change database
\c mydb
# Create user
create user myuser with encrypted password 'mypassword';
# Grant privileges for user on the database
grant all privileges on database mydb to myuser;
# Quit from psql console
\q
```

That's it, you can manage your database by using the newly created `myuser` account.

```sh
# Log in back to psql console with myuser using mydb
psql -h localhost -U myuser mydb
# List all tables
\dt
# Describe table structure (will be useful later on)
\d+ <table>
```

You can learn more about SQL commands using this [pgSQL tutorial](https://www.postgresqltutorial.com/) site.

> WARN: The command below can completely wipe your database, be extremely careful!

Now you are ready to play around with Fluent, but before we start I'd like to show you some more tips & tricks. During development, things can go wrong and you might need a fresh start for your DB. Here's how to drop & reinitiate everything. 😱

```sh
# Reset database
\c mydb
drop schema public cascade;
create schema public;
grant all on schema public to postgres;
grant all on schema public to myuser;
grant all on schema public to public;
```

The snippet above will delete the [public schema](https://www.postgresqltutorial.com/postgresql-schema/), next it'll recreate it and add all the necessary permissions for the required users. It's pretty straightforward but still dangerous. ⚠️

> NOTE : You can execute SQL scripts straight from the terminal by using the following command: `psql -h localhost -U myuser mydb -c "select * from mytable;"`

You can wipe everything from the command line using this "one-liner":

```sh 
# Run psql command from the command line
psql -h localhost -U postgres mydb\
    -c "drop schema public cascade; \
    create schema public; \
    grant all on schema public to postgres; \
    grant all on schema public to myuser; \
    grant all on schema public to public;"
```

I prefer to have daily backups from all my databases, this little shell script can do the job.

```sh
#!/bin/bash

# Backup database
BACKUP_DIR=/Users/tib/backups
FILE_SUFFIX=_pg_backup.sql
OUTPUT_FILE=${BACKUP_DIR}/`date +"%Y_%m_%d__%H_%M"`${FILE_SUFFIX}
PGPASSWORD="mypass" pg_dump -U myuser -h localhost mydb -F p -f ${OUTPUT_FILE}
gzip $OUTPUT_FILE

# Remove old backups
DAYS_TO_KEEP=30
find $BACKUP_DIR -maxdepth 1 -mtime +$DAYS_TO_KEEP -name "*${FILE_SUFFIX}.gz" -exec rm -rf '{}' ';'
```

You can easily [restore](https://stackoverflow.com/questions/2732474/restore-a-postgres-backup-file-using-the-command-line) a database from a backup by entering the following lines to the terminal:

```sh
# Restore database
gunzip -k file.gz
psql -U myuser -d mydb -1 -f mybackup.sql
```

Sometimes after I restarted my mac it happened to me that the PostgreSQL stopped working. I had to run the snippet below to fix the issue. The first line stops the service, the second initialize a new database, and the third will start the service again. Alternatively, you can start the database again with the `brew services start postgresql` command.

```
pg_ctl -D /usr/local/var/postgres stop -s -m fast
initdb /usr/local/var/postgres
pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start
```

I'm not a DevOps guru, feel free to tweet me if you know why this happened to me. 😅

