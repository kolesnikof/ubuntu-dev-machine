echo -p "Do you want to install ruby development environment?" rubyEnv
echo -p "Do you want to install node.js development environment?" nodeEnv
echo -p "Do you want to install php development environment?" phpEnv
echo -p "Would you like to install Google Chrome?" gChrome
echo -p "Would you like to install Sublime Text 3?" sublime
echo -p "Would you like to install MongoDB?" mongodb
echo -p "Would you like to setup git?" setupGit
echo -p "What password should we set in MySQL and PostgreSQL?" dbPassword

if [ setupGit -eq "y" ]; then
  echo -p "What is your name? " gitName
  echo -p "What is your email? " gitEmail
fi

sudo -s <<HERE

  sudo add-apt-repository ppa:webupd8team/java --yes

  apt-get update
  apt-get upgrade --yes

  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections

  apt-get install --yes build-essential gcc git imagemagick subversion curl zsh oracle-java8-installer phantomjs xpdf postgresql libxslt-dev libxml2-dev meld vim memcache virtualbox vagrant
  apt-get install oracle-java8-set-default --yes
  
HERE

curl -L http://install.ohmyz.sh | sh

if [ rubyEnv -eq "y" ]; then
  \curl -sSL https://get.rvm.io | bash -s stable

  source ~/.rvm/scripts/rvm


  rvm install 1.9.3 --disable-binary
  rvm install 2.0.0 --disable-binary
  rvm install 2.1.1 --disable-binary

  rvm use 2.0.0 --default
fi

if [ nodeEnv -eq "y" ]; then

  curl https://raw.githubusercontent.com/creationix/nvm/v0.12.2/install.sh | bash

  source ~/.nvm/nvm.sh

  nvm install 0.10
  nvm use 0.10  
  nvm alias default 0.10

fi

if [ phpEnv -eq "y" ]; then

sudo -s <<HERE

  debconf-set-selections <<< "mysql-server mysql-server/root_password password $dbPassword"
  debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $dbPassword"

  apt-get install --yes mysql-server mysql-client apache2 php5 libapache2-mod-php5 php5-mysql php5-curl php5-gd php5-intl php-pear php5-imagick php5-imap php5-mcrypt php5-memcache php5-ps php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl php5-xcache

  service apache2 restart

  a2enmod rewrite headers deflate security

  sed -i 's/diplay_errors = Off/display_errors = On/g' /etc/php5/apache2/php.ini
  sed -i 's/diplay_startup_errors = Off/display_startup_errors = On/g' /etc/php5/apache2/php.ini
  sed -i 's/memory_limit = 128M/memory_limit = 512M/g' /etc/php5/apache2/php.ini

  service apache2 restart
  
HERE

fi

if [ mongodb -eq "y" ]; then



fi

if [ setupGit -eq "y" ]; then
  git config --global user.name $gitName
  git config --global user.email $gitEmail

  cat /dev/zero |  ssh-keygen -b 4096 -t rsa -C $gitEmail -q -N ""
fi
