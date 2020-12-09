# About

Docker containers to help develop ElkArte, it does not install ElkArte in any of them, you should git pull into the persistant volume that is created.  Containers are based on alpine to help minimize the image sizes.  Two volumes are created for persistance, db_data (/var/lib/mysql) and src_html (/var/www) This will create a stack that uses/builds the following containers.

* nginx 1.19 (standard image with custom configs)
* php-fpm 7.4 (built image based off alpine, adds needed extensions)
* mariadb 10.5 (standard image, provides the database, can use mysql as well)
* adminer 4.7 (standard image, provides easy db administartion)
* mailhog (standard image, provides for email testing)

Installed extensions (other than the default ones):

* apcu
* exif
* gd
* imagick
* imap
* memcached
* mysqli
* pgsql
* pspell
* zip
* xdebug

List of all extensions on php-fpm (according to `php -m`):

[PHP Modules]

apcu, Core, ctype, curl, date, dom, exif, fileinfo, filter, ftp, gd, hash, iconv, imagick, json, libxml, mbstring, mysqli, mysqlnd, openssl, pcre, PDO, pdo_mysql, pdo_pgsql, pdo_sqlite, pgsql, Phar, posix, readline, Reflection, session, SimpleXML, sodium, SPL, sqlite3, standard, tokenizer, xdebug, xml, xmlreader, xmlwriter, Zend OPcache, zip, zlib

[Zend Modules]

Xdebug, Zend OPcache

## Development

The default uses elkarte as id/pass/dbname for database, chagne this is you want.  When installing elkarte the database server is db (not localhost).  Its recommended that you git pull the elkarte image to the src_html volume.

Quick notes on host/container permissions.  You should do an ```id -u``` on the host to get your userid #, use that number in the top of the php-fpm Dockerfile.  The resulting php-fpm will create www-user / www-group with those values.  ALthough the user name between host and container may be differenet, the value are the same so permissionsn work as expected.
