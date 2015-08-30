FROM miek/alpine-armv6l:3.2

MAINTAINER Stephan Zeissler

RUN apk update && apk add python gcc musl-dev python-dev openssl-dev
ADD http://heanet.dl.sourceforge.net/project/sabnzbdplus/sabnzbdplus/0.7.20/SABnzbd-0.7.20-src.tar.gz /tmp/sabnzb-src.tar.gz 

RUN tar xfz /tmp/sabnzb-src.tar.gz -C /tmp
RUN mv /tmp/SABnzbd-0.7.20 /sabnzb

# Dependency: Cheetah
ADD https://pypi.python.org/packages/source/C/Cheetah/Cheetah-2.4.4.tar.gz /tmp/Cheetah.tar.gz
RUN tar xfz /tmp/Cheetah.tar.gz -C /tmp
RUN cd /tmp/Cheetah-2.4.4 && python setup.py install

# Dependency: SSL
RUN apk add py-pip libffi libffi-dev ca-certificates && pip install setuptools && ln -s /usr/lib/libffi-3.2.1 /usr/lib/libffi 
ADD https://github.com/pyca/pyopenssl/archive/0.15.1.tar.gz /tmp/pyopenssl.tar.gz
RUN tar xfz /tmp/pyopenssl.tar.gz -C /tmp && cd /tmp/pyopenssl-0.15.1 && python setup.py install

# Dependencies: Tools
RUN apk add unrar unzip 

ADD par2/par2 /usr/local/bin/par2
# I build the binary in a separate alpine container and exported it with `docker cp`:
#RUN apk add g++ automake autoconf make
#ADD https://github.com/Parchive/par2cmdline/archive/v0.6.14.tar.gz /tmp/par2.tar.gz
#RUN tar xfz /tmp/par2.tar.gz && cd /tmp/par2cmdline-0.6.14 && aclocal && automake --add-missing && autoconf && ./configure && make && make check && make install

# Runtime Config
VOLUME /sabnzb-data
VOLUME /sabnzb-incoming
VOLUME /sabnzb-inprogress
VOLUME /sabnzb-complete

RUN touch /sabnzb-data/sabnzbd.ini

EXPOSE 80
WORKDIR /sabnzb
ENTRYPOINT ["python", "SABnzbd.py", "--server", "0.0.0.0:80", "--config-file", "/sabnzb-data/sabnzb.ini"]

