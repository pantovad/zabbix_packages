# This dockerfile generates an Zabbix packages for s390x
# Build arguments:
#   VERSION: Required. Used to label the image.
#   BUILD_DATE: Required. Used to label the image. Should be in the form 'yyyy-mm-ddThh:mm:ssZ', i.e. a date-time from https://tools.ietf.org/html/rfc3339. The timestamp must be in UTC.
#   VCS_REF: short VCS hash
FROM ubuntu:20.04 AS ubuntu-20.04

ARG VERSION
ARG GITHUB_TOKEN
RUN apt update -y && DEBIAN_FRONTEND=noninteractive apt install -y build-essential equivs git gh wget
RUN wget -P /tmp https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest%2Bubuntu20.04_all.deb && dpkg -i /tmp/zabbix-release_latest+ubuntu20.04_all.deb
RUN wget -P /tmp https://go.dev/dl/go1.22.4.linux-s390x.tar.gz && tar -C /usr/local -xzf /tmp/go1.22.4.linux-s390x.tar.gz
ENV PATH=PATH=$PATH:/usr/local/go/bin

RUN apt update -y
RUN cd /tmp && apt source zabbix && apt build-dep -y zabbix && cd zabbix-* && dpkg-buildpackage -uc -us
RUN cd /tmp && apt source zabbix-agent2-plugin-postgresql && cd zabbix-agent2-plugin-postgresql-* && dpkg-buildpackage -uc -us
RUN cd /tmp && apt source zabbix-agent2-plugin-ember-plus && cd zabbix-agent2-plugin-ember-plus-* && dpkg-buildpackage -uc -us
RUN cd /tmp && apt source zabbix-agent2-plugin-mongodb && cd zabbix-agent2-plzabbix-agent2-plugin-mongodb-* && dpkg-buildpackage -uc -us
RUN cd /tmp && apt source zzabbix-agent2-plugin-mssql && cd zabbix-agent2-plugin-mssql-* && dpkg-buildpackage -uc -us
RUN gh release view ${VERSION} || gh release create ${VERSION} --notes ${VERSION}
RUN cd /tmp && gh release upload ${VERSION} zabbix*s390x*.deb

FROM ubuntu:22.04 AS ubuntu-22.04

ARG VERSION
ARG GITHUB_TOKEN
RUN apt update -y && DEBIAN_FRONTEND=noninteractive apt install -y build-essential equivs git gh wget
RUN wget -P /tmp https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest%2Bubuntu22.04_all.deb && dpkg -i /tmp/zabbix-release_latest+ubuntu22.04_all.deb
RUN wget -P /tmp https://go.dev/dl/go1.22.4.linux-s390x.tar.gz && tar -C /usr/local -xzf /tmp/go1.22.4.linux-s390x.tar.gz
ENV PATH=PATH=$PATH:/usr/local/go/bin

RUN apt update -y
RUN cd /tmp && apt source zabbix && apt build-dep -y zabbix && cd zabbix-* && dpkg-buildpackage -uc -us
RUN cd /tmp && apt source zabbix-agent2-plugin-postgresql && cd zabbix-agent2-plugin-postgresql-* && dpkg-buildpackage -uc -us
RUN cd /tmp && apt source zabbix-agent2-plugin-ember-plus && cd zabbix-agent2-plugin-ember-plus-* && dpkg-buildpackage -uc -us
RUN cd /tmp && apt source zabbix-agent2-plugin-mongodb && cd zabbix-agent2-plzabbix-agent2-plugin-mongodb-* && dpkg-buildpackage -uc -us
RUN cd /tmp && apt source zzabbix-agent2-plugin-mssql && cd zabbix-agent2-plugin-mssql-* && dpkg-buildpackage -uc -us
RUN gh release view ${VERSION} || gh release create ${VERSION} --notes ${VERSION}
RUN cd /tmp && gh release upload ${VERSION} zabbix*s390x*.deb

FROM rockylinux:9.3 AS rhel-9

ARG VERSION
ARG GITHUB_TOKEN
RUN dnf -y install rpm-build dnf-plugins-core gcc golang https://www.rpmfind.net/linux/fedora-secondary/releases/40/Everything/s390x/os/Packages/g/gh-2.45.0-1.fc40.s390x.rpm
RUN dnf config-manager --set-enabled crb
RUN dnf -y builddep https://repo.zabbix.com/zabbix/7.0/rhel/9/SRPMS/zabbix-7.0.0-release1.el9.src.rpm
RUN rpmbuild --rebuild https://repo.zabbix.com/zabbix/7.0/rhel/9/SRPMS/zabbix-7.0.0-release1.el9.src.rpm
RUN rpmbuild --rebuild https://repo.zabbix.com/zabbix/7.0/rhel/9/SRPMS/zabbix-agent2-plugin-ember-plus-7.0.0-release1.el9.src.rpm
RUN rpmbuild --rebuild https://repo.zabbix.com/zabbix/7.0/rhel/9/SRPMS/zabbix-agent2-plugin-mongodb-7.0.0-release1.el9.src.rpm
RUN rpmbuild --rebuild https://repo.zabbix.com/zabbix/7.0/rhel/9/SRPMS/zabbix-agent2-plugin-mssql-7.0.0-release1.el9.src.rpm
RUN rpmbuild --rebuild https://repo.zabbix.com/zabbix/7.0/rhel/9/SRPMS/zabbix-agent2-plugin-postgresql-7.0.0-release1.el9.src.rpm
RUN gh release view ${VERSION} || gh release create ${VERSION} --notes ${VERSION}
RUN gh release upload ${VERSION} /root/rpmbuild/RPMS/s390x/zabbix*.rpm /root/rpmbuild/RPMS/noarch/zabbix*.rpm
