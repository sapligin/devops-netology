FROM centos:centos7

RUN yum makecache && \
    yum -y install wget && \
    yum -y install perl-Digest-SHA

RUN wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.1.2-linux-x86_64.tar.gz && \
    wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.1.2-linux-x86_64.tar.gz.sha512 && \
    shasum -a 512 -c elasticsearch-8.1.2-linux-x86_64.tar.gz.sha512 && \
    tar -xzf elasticsearch-8.1.2-linux-x86_64.tar.gz && \
    cd elasticsearch-8.1.2/

RUN groupadd -g 1000 elastic && useradd elastic -u 1000 -g 1000 && \
	chown -R elastic:elastic /elasticsearch-8.1.2 && \ 
	chmod o+x /elasticsearch-8.1.2 
	
RUN mkdir -p /var/lib/elasticsearch/data/ && \ 
	chown -R elastic:elastic /var/lib/elasticsearch/
	
RUN mkdir - p /elasticsearch-8.1.2/snapshots/ && \ 
	chown -R elastic:elastic /elasticsearch-8.1.2/snapshots/
    
COPY elasticsearch.yml /elasticsearch-8.1.2/config/     
    
USER elastic

CMD ["/elasticsearch-8.1.2/bin/elasticsearch"]

EXPOSE 9200 9300
