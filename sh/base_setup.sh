#!/bin/bash

# System stuff

## Set locale first, or Postgresql will get in trouble later on regarding UTF8-encoded databases.
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
locale-gen en_US.UTF-8

## Increase swap space

if [ ! -f '/home/kartverk/done_swapfile' ]; then
	# Create swapfile of 10GB with block size 1MB
	/bin/dd if=/dev/zero of=/swapfile bs=1024 count=10485760

	# Set up the swap file
	/sbin/mkswap /swapfile

	# Enable swap file immediately
	/sbin/swapon /swapfile

	# Enable swap file on every boot
	/bin/echo '/swapfile          swap            swap    defaults        0 0' >> /etc/fstab

	touch '/home/kartverk/done_swapfile'
fi

if [ ! -f '/home/kartverk/done_packages' ]; then

	# Packages

	## Install postgreqsql database
	apt-get -y install postgresql-9.1
	## Install PostGIS 2.1
	apt-get -y install python-software-properties
	apt-add-repository -y ppa:sharpie/for-science
	apt-add-repository -y  ppa:sharpie/postgis-nightly
	apt-get update
	apt-get -y install postgresql-9.1-postgis
	## Install Mapnik
	add-apt-repository -y ppa:mapnik/v2.2.0
	apt-get update
	apt-get -y install libmapnik mapnik-utils python-mapnik
	## Install gdal
	apt-get -y install libgdal1-1.7.0 libgdal1-dev gdal-bin
	## Install git and unzip
	apt-get -y install git unzip

	touch '/home/kartverk/done_packages'
fi

if [ ! -f '/home/kartverk/done_postgres' ]; then

	# Postgres/PostGIS setup

	## Create PostGIS template
	sudo -u postgres createdb -E UTF8 template_postgis2
	sudo -u postgres createlang -d template_postgis2 plpgsql
	sudo -u postgres psql -d postgres -c "UPDATE pg_database SET datistemplate='true' WHERE datname='template_postgis2'"
	sudo -u postgres psql -d template_postgis2 -f /usr/share/postgresql/9.1/contrib/postgis-2.1/postgis.sql
	sudo -u postgres psql -d template_postgis2 -f /usr/share/postgresql/9.1/contrib/postgis-2.1/spatial_ref_sys.sql
	sudo -u postgres psql -d template_postgis2 -f /usr/share/postgresql/9.1/contrib/postgis-2.1/rtpostgis.sql
	sudo -u postgres psql -d template_postgis2 -c "GRANT ALL ON geometry_columns TO PUBLIC;"
	sudo -u postgres psql -d template_postgis2 -c "GRANT ALL ON geography_columns TO PUBLIC;"
	sudo -u postgres psql -d template_postgis2 -c "GRANT ALL ON spatial_ref_sys TO PUBLIC;"

	## Create kartverk user, role and database
	sudo -u postgres psql -c "CREATE ROLE kartverk LOGIN INHERIT CREATEDB;"
	sudo -u postgres psql -c "ALTER USER kartverk WITH PASSWORD 'bengler';"
	#sudo -u postgres psql -c "GRANT kartverk TO kartverk;"
	sudo -u kartverk createdb -O kartverk -E UTF8 -T template_postgis2 kartverk

	touch '/home/kartverk/done_postgres'

fi

# Git setup
git config --global user.name "Tilde Nielsen" # Bengler's test user
git config --global user.email tildeniels1@gmail.com

if [ ! -f '/home/kartverk/done_dataseed' ]; then

	# Prepare to cook map data
	cd /home/kartverk
	sudo -u kartverk git clone https://a09e2e7b5488f777a79b82edd506e61ccdfcbe43@github.com/bengler/kartverk_data_seed
	cd /home/kartverk/kartverk_data_seed
	sudo -u kartverk ./seed.sh kartverk kartverk bengler

	touch '/home/kartverk/done_dataseed'

fi
