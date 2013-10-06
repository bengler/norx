#!/bin/bash

name="norx"

hidden_dir="/home/$name/.$name"

export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
locale-gen en_US.UTF-8

if [ ! -d $hidden_dir ]; then
  sudo -u $name mkdir $hidden_dir
fi

if [ ! -f "$hidden_dir/.done_profile" ]; then
    # Set locale to when user logs into the VM through SSH
  echo "Setting default locale for $name account"
  echo '
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
' >> /home/$name/.profile
  touch "$hidden_dir/.done_profile"
fi

if [ ! -f "$hidden_dir/.done_packages" ]; then

  echo  "Installing needed packages"

  apt-get -y install python-software-properties build-essential

  # Add some repositories
  apt-add-repository -y ppa:sharpie/postgis-nightly
  add-apt-repository -y ppa:mapnik/v2.1.0
  add-apt-repository -y ppa:chris-lea/node.js
  add-apt-repository -y ppa:ubuntugis/ubuntugis-unstable

  apt-get update

  ## Install postgreqsql database
  apt-get -y install postgresql-9.1

  ## Install PostGIS 2.1
  apt-get -y install postgresql-9.1-postgis-2.0

  ## Install gdal
  apt-get -y install libgdal1h libgdal-dev gdal-bin

  # Install mapnik
  sudo apt-get -y install libmapnik mapnik-utils python-mapnik libmapnik-dev

  ## Install some tools needed to install services
  apt-get -y install git subversion unzip zerofree curl

  ## Install node
  apt-get -y install nodejs

  # Install needed Python packages
  apt-get install -y libboost-python-dev python-pip python-dev

  # Install python modules
  pip install pillow TileStache pyproj

  echo  "Installing Elastic Search server with JDBC-bindings for Postgres"

  apt-get install -y openjdk-7-jre-headless
  wget --quiet https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-0.90.3.deb -O /tmp/elasticsearch-0.90.3.deb
  dpkg -i /tmp/elasticsearch-0.90.3.deb
  cd /usr/share/elasticsearch/bin
  ./plugin -url http://bit.ly/19iNdvZ -install river-jdbc
  cd ..
  cd plugins/river-jdbc
  wget --quiet http://jdbc.postgresql.org/download/postgresql-9.1-903.jdbc4.jar

  touch "$hidden_dir/.done_packages"
fi


if [ ! -f "$hidden_dir/.done_postgres" ]; then
  echo  "Setting up database"
  # Postgres/PostGIS setup

  echo  "    * Creating PostGIS template"
  ## Create PostGIS template
  sudo -u postgres createdb -E UTF8 template_postgis2
  sudo -u postgres createlang -d template_postgis2 plpgsql
  sudo -u postgres psql -d postgres -c "UPDATE pg_database SET datistemplate='true' WHERE datname='template_postgis2'"
  sudo -u postgres psql -d template_postgis2 -f /usr/share/postgresql/9.1/contrib/postgis-2.0/postgis.sql
  sudo -u postgres psql -d template_postgis2 -f /usr/share/postgresql/9.1/contrib/postgis-2.0/spatial_ref_sys.sql
  sudo -u postgres psql -d template_postgis2 -f /usr/share/postgresql/9.1/contrib/postgis-2.0/rtpostgis.sql
  sudo -u postgres psql -d template_postgis2 -f /usr/share/postgresql/9.1/contrib/postgis-2.0/legacy.sql
  sudo -u postgres psql -d template_postgis2 -c "GRANT ALL ON geometry_columns TO PUBLIC;"
  sudo -u postgres psql -d template_postgis2 -c "GRANT ALL ON geography_columns TO PUBLIC;"
  sudo -u postgres psql -d template_postgis2 -c "GRANT ALL ON spatial_ref_sys TO PUBLIC;"

  echo  "    * Creating Postgres user '$name' with password 'bengler'"
  sudo -u postgres psql -c "CREATE ROLE root LOGIN INHERIT CREATEDB;"
  sudo -u postgres psql -c "ALTER USER root WITH PASSWORD 'bengler';"

  sudo -u postgres psql -c "CREATE ROLE $name LOGIN INHERIT CREATEDB;"
  sudo -u postgres psql -c "ALTER USER $name WITH PASSWORD 'bengler';"

  echo  "    * Creating database '$name'"
  sudo -u $name createdb -O $name -E UTF8 -T template_postgis2 $name

  touch "$hidden_dir/.done_postgres"

fi

if [ ! -f "$hidden_dir/.done_dataseed" ]; then
  echo  "Seeding map data. This will take a very long time!"

  # Prepare to cook map data
  echo "    * Fetching seed code from GitHub"

  cd /home/$name
  sudo -u $name mkdir data

  sudo -u $name git clone git://github.com/bengler/norx_data.git data

  cd data

  echo "    * Starting seed. Please be patient...this is going to take a long time!"

  sudo -u $name ./seed.sh $name $name bengler

  if [  -f '/home/$name/data' ]; then
    touch "$hidden_dir/.done_dataseed"
    echo "   * Seed done!"
  fi
fi

if [ ! -f "$hidden_dir/.done_services" ]; then

  echo  "Setting up map services"
  # Set up services that we need running
  cd /home/$name
  sudo -u $name mkdir services
  echo  "    * Fetching services-repository from GitHub"
  sudo -u $name git clone git://github.com/bengler/norx_services.git services
  cd /home/$name/services
  chown -R $name *
  ./bootstrap.sh $name
  if [ -d '/home/$name/services' ]; then
    touch "$hidden_dir/.done_services"
    echo "   * Services done!"
  fi
fi
