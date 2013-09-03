#!/bin/bash

GITHUB_ACCESS_TOKEN="a09e2e7b5488f777a79b82edd506e61ccdfcbe43"

exit

# System stuff

## Set locale first, or Postgresql will get in trouble later on regarding UTF8-encoded databases.
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
locale-gen en_US.UTF-8

if [ ! -f '/home/kartverk/done_packages' ]; then
	echo  "Installing needed packages to handle map data"
	# Packages

	## Install postgreqsql database
	apt-get -y install postgresql-9.1
	## Install PostGIS 2.1
	apt-get -y install python-software-properties
	apt-add-repository -y ppa:sharpie/for-science
	apt-add-repository -y  ppa:sharpie/postgis-nightly
	apt-get update
	apt-get -y install postgresql-9.1-postgis

	## Install gdal
	apt-get -y install libgdal1-1.7.0 libgdal1-dev gdal-bin
	## Install tilestache (also includes mapnik 2.2.0)
	apt-get -y tilestache

	## Install git, unzip, subversion and zerofree
	apt-get -y install git unzip subversion zerofree

	# Install needed Python packages
	apt-get install python-pip python-dev

	## Install Python package pillow needed for tilestache
	pip install pillow

	touch '/home/kartverk/done_packages'
fi

if [ ! -f '/home/kartverk/done_postgres' ]; then
	echo  "Setting up database"
	# Postgres/PostGIS setup

	echo  "\t * Creating PostGIS template"
	## Create PostGIS template
	sudo -u postgres createdb -E UTF8 template_postgis2
	sudo -u postgres createlang -d template_postgis2 plpgsql
	sudo -u postgres psql -d postgres -c "UPDATE pg_database SET datistemplate='true' WHERE datname='template_postgis2'"
	sudo -u postgres psql -d template_postgis2 -f /usr/share/postgresql/9.1/contrib/postgis-2.1/postgis.sql
	sudo -u postgres psql -d template_postgis2 -f /usr/share/postgresql/9.1/contrib/postgis-2.1/spatial_ref_sys.sql
	sudo -u postgres psql -d template_postgis2 -f /usr/share/postgresql/9.1/contrib/postgis-2.1/rtpostgis.sql
	sudo -u postgres psql -d template_postgis2 -f /usr/share/postgresql/9.1/contrib/postgis-2.1/legacy.sql
	sudo -u postgres psql -d template_postgis2 -c "GRANT ALL ON geometry_columns TO PUBLIC;"
	sudo -u postgres psql -d template_postgis2 -c "GRANT ALL ON geography_columns TO PUBLIC;"
	sudo -u postgres psql -d template_postgis2 -c "GRANT ALL ON spatial_ref_sys TO PUBLIC;"

	echo  "\t * Creating user 'kartverk' with password 'bengler'"
	## Create kartverk user, role and database
	sudo -u postgres psql -c "CREATE ROLE kartverk LOGIN INHERIT CREATEDB;"
	sudo -u postgres psql -c "ALTER USER kartverk WITH PASSWORD 'bengler';"
	#sudo -u postgres psql -c "GRANT kartverk TO kartverk;"
	echo  "\t * Creating database 'kartverk'"
	sudo -u kartverk createdb -O kartverk -E UTF8 -T template_postgis2 kartverk

	touch '/home/kartverk/done_postgres'

fi

echo  "Setting up GitHub user to fetch additional code"
# Git setup
git config --global user.name "Tilde Nielsen" # Bengler's test user
git config --global user.email tildeniels1@gmail.com

if [ ! -f '/home/kartverk/done_dataseed' ]; then
	echo  "Seeding map data. This will take a very long time!"
	echo "\t * Generating and activating humongous (25 GB) swapfile needed to parse BIG GeoJSON files"

	# Create swapfile of 25GB with block size 1MB
	dd if=/dev/zero of=/swapfile bs=1024 count=26214400

	# Set up the swap file
	mkswap /swapfile

	# Enable swap file immediately
	swapon /swapfile

	# Prepare to cook map data
	echo "\t * Fetching seed code from GitHub"

	cd /home/kartverk
	sudo -u kartverk git clone "https://$GITHUB_ACCESS_TOKEN@github.com/bengler/kartverk_data_seed"
	cd /home/kartverk/kartverk_data_seed

	echo "\t * Starting seed. Please be patient..."

	sudo -u kartverk ./seed.sh kartverk kartverk bengler

	echo "\t * Deactivatin and removing humongous swap file"
	swapoff /swapfile
	rm -rf /swapfile
	touch '/home/kartverk/done_dataseed'
	echo "\t * Seed done!"
fi

if [ ! -f '/home/kartverk/done_services' ]; then
	echo  "Setting up map services to run locally"
	# Set up services that we need running
	cd /home/kartverk
	echo  "\t * Fetching service code from GitHub"
	sudo -u kartverk git clone "https://$GITHUB_ACCESS_TOKEN@github.com/bengler/kartverk_vm_services"
	cd /home/kartverk/kartverk_vm_services
	./bootstrap.sh

	touch '/home/kartverk/done_services'

fi
