FROM httpd:2.4.41-alpine

RUN apk update &&\
    apk add --update curl jq coreutils git make musl-dev go findutils nano

RUN wget https://github.com/google/go-jsonnet/releases/download/v0.17.0/go-jsonnet_0.17.0_Linux_x86_64.tar.gz -O jsonnet.tar.gz
RUN tar -xzf jsonnet.tar.gz &&\
    rm jsonnet.tar.gz &&\
    mv jsonnet /usr/bin/jsonnet &&\
    chmod +x /usr/bin/jsonnet

RUN wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq &&\
    chmod +x /usr/bin/yq

COPY httpd.conf /usr/local/apache2/conf/httpd.conf
COPY forward_env_start_httpd /usr/local/apache2/
COPY sync /usr/local/apache2/cgi-bin
COPY finalize /usr/local/apache2/cgi-bin
COPY sync.jsonnet /usr/local/apache2/cgi-bin/
COPY finalize.jsonnet /usr/local/apache2/cgi-bin/
COPY live /usr/local/apache2/cgi-bin

RUN mkdir /grafonnet_tmp && chmod 777 /grafonnet_tmp/
COPY vendor /grafonnet_tmp/vendor

CMD ["/usr/local/apache2/forward_env_start_httpd"]
