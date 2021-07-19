# docker-kimai

Installs kimai2 into /var/www/html which can be mounted as a PV in kubernetes. It is imperative that the installation completes, an incomplete install will require wiping the directory/pv and restarting/reinstalling. Once it has been deployed, it will check for the .env file, and, if discovered, not reinstall everything.

Expected variables:

```
DATABASE_URL # formatted database connection string
APP_SECRET # LIKELY DEPRECATED
```
