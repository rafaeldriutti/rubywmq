# syntax=docker/dockerfile:1
#
# Build image for compiling rubywmq's native extension on AlmaLinux 9.
#
# Prereq: the IBM MQ Client package tarball (e.g.
# "9.4.5.0-IBM-MQC-LinuxX64.tar.gz") must be present in ./deps, then build
# with:
#
#   docker build --build-arg MQ_TARBALL=9.4.5.0-IBM-MQC-LinuxX64.tar.gz -t rubywmq-build .
#
FROM almalinux:9

ARG MQ_TARBALL=9.4.5.0-IBM-MQC-LinuxX64.tar.gz

# Ruby's default external encoding follows the container locale; with none
# set it falls back to US-ASCII, which chokes on non-ASCII bytes in the MQ
# header files while generating ext/wmq_reason.c.
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Ruby 3.3 (matches .tool-versions) + native extension build toolchain
# Requires AlmaLinux 9.4+ (AppStream ruby:3.3 module stream).
RUN dnf module enable -y ruby:3.3 \
    && dnf install -y \
       ruby \
       ruby-devel \
       rubygems \
       rubygem-rake \
       rubygem-bundler \
       gcc \
       gcc-c++ \
       make \
       tar \
       gzip \
    && dnf clean all

# IBM MQ Client (Runtime + SDK for headers/libs) installed via its RPMs.
# MQSeriesRuntime and MQSeriesSDK provide /opt/mqm/inc and /opt/mqm/lib64.
COPY deps/${MQ_TARBALL} /tmp/mqm.tar.gz
RUN mkdir -p /tmp/mqm \
    && tar -xzf /tmp/mqm.tar.gz -C /tmp/mqm \
    && cd /tmp/mqm/MQClient \
    && ./mqlicense.sh -text_only -accept \
    && rpm -ivh MQSeriesRuntime-*.rpm MQSeriesSDK-*.rpm MQSeriesClient-*.rpm MQSeriesGSKit-*.rpm \
    && cd / && rm -rf /tmp/mqm /tmp/mqm.tar.gz

ENV LD_LIBRARY_PATH=/opt/mqm/lib64:/opt/mqm/lib:${LD_LIBRARY_PATH}

WORKDIR /app
COPY . .

RUN bundle install \
    && cd ext && ruby extconf.rb && make && make install && cd .. \
    && gem build rubywmq.gemspec \
    && gem install ./rubywmq-*.gem

CMD ["ruby", "-e", "require 'wmq'; puts WMQ::VERSION"]
