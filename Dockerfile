FROM mono:4.4.2.11

MAINTAINER arielvb

RUN apt-get update && apt-get upgrade -y && apt-get install monodevelop python3 python3-pip python3-lxml -y

