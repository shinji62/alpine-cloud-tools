FROM google/cloud-sdk:alpine

LABEL maintainer="Etourneau Gwenn"

ENV TERRAFORM011_VERSION=0.11.14
ENV TERRAFORM_VERSION=0.12.7
ENV ANSIBLE_VERSION=2.7.6
ENV AWLESS_VERSION=0.1.11
ENV GOMPLATE_VERSION=3.1.0
ENV YJ_VERSION=3.1.0
ENV SAFE_VERSION=1.1.0
ENV AWS_CLI_VERSION=1.14.5


RUN gcloud components install alpha --quiet
RUN apk upgrade
RUN apk --no-cache add --update alpine-sdk jq openssl openssl-dev openssh-client libffi-dev gnupg gettext libintl openjdk8 python2 python2-dev py2-pip py2-virtualenv \
    && rm -rf /var/cache/apk/*

RUN pip install --upgrade pip


#Small hack to add v3 support to openssl
RUN echo $'[ v3_req ]\n\
basicConstraints = CA:FALSE\n\
keyUsage = digitalSignature, nonRepudiation, keyEncipherment\n\n\
[ v3_ca ]\n\
basicConstraints = critical,CA:TRUE\n\
subjectKeyIdentifier = hash\n\
authorityKeyIdentifier = keyid:always,issuer:always\n'\
>> /etc/ssl/openssl.cnf

RUN wget "https://github.com/wallix/awless/releases/download/v${AWLESS_VERSION}/awless-linux-amd64.tar.gz" \
    && tar -C /bin/ -xvzf ./awless-linux-amd64.tar.gz \
    && rm ./awless-linux-amd64.tar.gz
RUN chmod +x /bin/awless

RUN wget "https://github.com/hairyhenderson/gomplate/releases/download/v${GOMPLATE_VERSION}/gomplate_linux-amd64-slim" -O /bin/gomplate
RUN chmod +x /bin/gomplate

RUN wget "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM011_VERSION}_linux_amd64.zip" -O /tmp/terraform.zip \
    && unzip /tmp/terraform.zip -d /bin \
    && rm /tmp/terraform.zip \
    && mv /bin/terraform /bin/terraform0.11

RUN wget "https://releases.hashicorp.com/terraform/${TERRAFORM012_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -O /tmp/terraform.zip \
    && unzip /tmp/terraform.zip -d /bin \
    && rm /tmp/terraform.zip 

RUN pip install ansible==${ANSIBLE_VERSION} jmespath

RUN wget "https://github.com/sclevine/yj/releases/download/v${YJ_VERSION}/yj-linux" -O /bin/yj
RUN chmod +x /bin/yj

RUN pip install --upgrade awscli==${AWS_CLI_VERSION}
