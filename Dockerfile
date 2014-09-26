FROM centos:centos7
MAINTAINER danny <danny.code1@gmail.com>

# timezone
RUN rm /etc/localtime
RUN ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

# locale
RUN localedef -f UTF-8 -i ja_JP ja_JP.UTF-8

# epel
RUN rpm --import http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7
RUN rpm -ivh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-2.noarch.rpm

# remi
RUN rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm

# user
RUN useradd app
RUN yum -y install sudo
RUN echo "app ALL=(ALL) ALL" > /etc/sudoers.d/app
RUN echo 'app:app' | chpasswd
RUN echo "export LANG=ja_JP.UTF-8" >> /home/app/.bashrc
RUN mkdir /home/app/.ssh
RUN chmod 700 /home/app/.ssh
RUN touch /home/app/.ssh/config
RUN chmod 600 /home/app/.ssh/config
RUN chown -R app:app /home/app/.ssh

# sendmail
RUN yum -y install sendmail

# dev package
RUN yum install -y bind-utils tar make libxml2-devel libxslt-devel libcurl-devel ImageMagick-devel

# ssh
RUN yum -y install openssh-server
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ''
RUN ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N ''

# bower
RUN yum install -y nodejs npm
RUN npm install -g bower

# mariadb
RUN yum install -y mariadb mariadb-server mariadb-devel
RUN mysql_install_db --user=mysql --ldata=/var/lib/mysql/

# devtools
RUN yum install -y zsh screen emacs-nox git
RUN chsh app -s /bin/zsh

# dotfiles
RUN cd /home/app && git clone https://github.com/f96q/dotfiles.git
RUN chown -R app:app /home/app/dotfiles
RUN su - app -c 'cd /home/app/dotfiles && sh setup.sh'

# ruby
RUN yum remove ruby
RUN yum -y install libyaml
ADD ruby-2.1.3-2.el7.centos.x86_64.rpm /tmp/ruby-2.1.3-2.el7.centos.x86_64.rpm
RUN rpm -ihv /tmp/ruby-2.1.3-2.el7.centos.x86_64.rpm
RUN rm /tmp/ruby-2.1.3-2.el7.centos.x86_64.rpm
RUN gem install bundler

ADD start.sh /start.sh
RUN chmod 755 /start.sh
