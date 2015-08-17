#!/bin/bash

echo "******************************************************"
echo "                 Ubuntu Dev Machine                   "
echo "******************************************************"
echo ""
echo "I'll ask all the questions at this point, and then go take some rest..."

echo -n "Do you want to setup ruby development environment?"
read rubyEnv
echo -n "Do you want to setup node.js development environment?"
read nodeEnv
echo -n "Do you want to setup php development environment?"
read phpEnv
echo -n "Would you like to install Google Chrome?"
read gChrome
echo -n "Would you like to install Sublime Text 3?"
read sublime
echo -n "Would you like to install MongoDB?"
read mongodb
echo -n "Would you like to setup git?"
read setupGit
echo -n "What password should we set in MySQL and PostgreSQL?"
read dbPassword

if [ $setupGit == "y" ]; then
  echo -n "What is your name? "
  read gitName
  echo -n "What is your email? "
  read gitEmail
fi

sudo -s <<HERE

  sudo add-apt-repository ppa:webupd8team/java --yes

  apt-get update
  apt-get upgrade --yes

  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections

  apt-get install --yes build-essential gcc git imagemagick subversion curl zsh oracle-java8-installer phantomjs xpdf postgresql libxslt-dev libxml2-dev meld vim memcache virtualbox vagrant
  apt-get install oracle-java8-set-default --yes

  if [ $phpEnv == "y" ]; then
    debconf-set-selections <<< "mysql-server mysql-server/root_password password $(dbPassword)"
    debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $(dbPassword)"

    apt-get install --yes mysql-server mysql-client apache2 php5 libapache2-mod-php5 php5-mysql php5-curl php5-gd php5-intl php-pear php5-imagick php5-imap php5-mcrypt php5-memcache php5-ps php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl php5-xcache

    service apache2 restart

    a2enmod rewrite headers deflate security

    sed -i 's/diplay_errors = Off/display_errors = On/g' /etc/php5/apache2/php.ini
    sed -i 's/diplay_startup_errors = Off/display_startup_errors = On/g' /etc/php5/apache2/php.ini
    sed -i 's/memory_limit = 128M/memory_limit = 512M/g' /etc/php5/apache2/php.ini

    service apache2 restart
  fi

HERE

if [ $setupGit == "y" ]; then
  git config --global user.name $gitName
  git config --global user.email $gitEmail

  cat /dev/zero |  ssh-keygen -b 4096 -t rsa -C $gitEmail -q -N ""
fi

curl -L http://install.ohmyz.sh | sh

if [ $rubyEnv == "y" ]; then
  \curl -sSL https://get.rvm.io | bash -s stable

  source ~/.rvm/scripts/rvm

  rvm install 1.9.3 --disable-binary
  rvm install 2.1.5 --disable-binary
  rvm install 2.2 --disable-binary

  rvm use 2.2 --default
fi

if [ $nodeEnv -eq "y" ]; then

  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.26.0/install.sh | bash

  source ~/.nvm/nvm.sh

  nvm install iojs
  nvm use iojs
  nvm alias default iojs
fi
