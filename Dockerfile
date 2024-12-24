FROM docker.io/library/debian as builder


RUN mkdir /work

COPY ./pull_modify_iso.sh /work
COPY ./preseed.cfg /work

RUN chmod +x /work/pull_modify_iso.sh

RUN apt update;\
    apt install -y curl xorriso dpkg-dev apt-utils;\
    apt clean

FROM builder

WORKDIR /work

CMD ./pull_modify_iso.sh