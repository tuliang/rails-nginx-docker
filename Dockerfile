FROM ubuntu:14.04
MAINTAINER tuliang(info@tuliang.org)

RUN apt-get update

# Install ruby dependencies
RUN apt-get install -y wget curl \
    build-essential git git-core \
    zlib1g-dev libssl-dev libreadline-dev libxml2-dev libxslt1-dev gawk g++ libreadline6-dev libyaml-dev libsqlite3-dev sqlite3 autoconf libgdbm-dev libncurses5-dev automake libtool bison libffi-dev gcc libxslt-dev memcached

# Install ruby-install
RUN cd /tmp &&\
  wget -O ruby-install-0.4.3.tar.gz https://github.com/postmodern/ruby-install/archive/v0.4.3.tar.gz &&\
  tar -xzvf ruby-install-0.4.3.tar.gz &&\
  cd ruby-install-0.4.3/ &&\
  make install

# Install MRI Ruby 2.2.0
RUN ruby-install ruby 2.2.0 -- --enable-shared

# Add Ruby binaries to $PATH
ENV PATH /opt/rubies/ruby-2.2.0/bin:$PATH

# Add options to gemrc
RUN echo "gem: --no-document" > ~/.gemrc

# Install bundler
RUN gem install bundler

# Install nodejs
RUN apt-get install -qq -y nodejs

# Intall software-properties-common for add-apt-repository
RUN apt-get install -qq -y software-properties-common

# Install foreman
RUN gem install foreman

# Install MySQL(for mysql, mysql2 gem)
RUN apt-get install -qq -y libmysqlclient-dev

# Install Nginx.
RUN add-apt-repository -y ppa:nginx/stable
RUN apt-get install -qq -y nginx
RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf
RUN chown -R www-data:www-data /var/lib/nginx
# Add default nginx config
ADD /config/docker/nginx-sites.conf /etc/nginx/sites-enabled/default

# Install Rails App
WORKDIR /app
ADD Gemfile /app/Gemfile  
ADD Gemfile.lock /app/Gemfile.lock  
RUN bundle install
ADD . /app