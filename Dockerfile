FROM centos

RUN yum -y update
RUN yum -y groupinstall "Development Tools"
RUN yum -y install ImageMagick ImageMagick-devel sudo

# Install RVM, Ruby 2.1.1
RUN yum -y install curl git which tar
RUN sed -i '0,/enabled=.*/{s/enabled=.*/enabled=1/}' /etc/yum.repos.d/CentOS-Base.repo
RUN yum install -y http://fedora.mirror.nexicom.net/epel/6/x86_64/epel-release-6-8.noarch.rpm
RUN yum update -y
#ADD ./rvm_install.sh rvm_install.sh
#RUN chmod +x rvm_install.sh
#RUN ./rvm_install.sh
#RUN /bin/bash -l -c "curl -L https://get.rvm.io | bash -s stable"
RUN /bin/bash -l -c "curl -sSL https://get.rvm.io | bash -s stable --ruby"
RUN /bin/bash -l -c "rvm install 2.1.1"

# Install MongoDB
ADD ./10gen.txt /
RUN cat /10gen.txt >> /etc/yum.repos.d/mongodb.repo
RUN yum -y --enablerepo=10gen install mongo-10gen mongo-10gen-server
RUN mkdir -p /data/db
RUN /sbin/chkconfig mongod on

# Install Mecab
RUN yum -y install wget
WORKDIR /usr/local/src
ENV  MAKE_OPTS -j12
RUN wget --quiet http://mecab.googlecode.com/files/mecab-0.996.tar.gz
RUN wget --quiet http://mecab.googlecode.com/files/mecab-ipadic-2.7.0-20070801.tar.gz
RUN wget --quiet http://mecab.googlecode.com/files/mecab-ruby-0.996.tar.gz
RUN cd /usr/local/src && tar xzf mecab-0.996.tar.gz && cd mecab-0.996 && ./configure --enable-utf8-only && make && make install
RUN cd /usr/local/src && tar xzf mecab-ipadic-2.7.0-20070801.tar.gz && cd mecab-ipadic-2.7.0-20070801 && ./configure --with-charset=utf8 && make && make install
RUN /bin/bash -l -c "cd /usr/local/src && tar xzf mecab-ruby-0.996.tar.gz && cd mecab-ruby-0.996 && ruby extconf.rb && make && make install"
RUN echo "/usr/local/lib" >>  /etc/ld.so.conf && ldconfig

# Install Shirasagi
RUN git clone --depth 1 https://github.com/shirasagi/shirasagi /var/www/shirasagi
WORKDIR /var/www/shirasagi
RUN cp config/samples/* config/
RUN /bin/bash -l -c "bundle --without test development"
RUN /bin/bash -l -c "bin/deploy"
ADD ./starter.sh /var/www/shirasagi/starter.sh
RUN chmod +x ./starter.sh
