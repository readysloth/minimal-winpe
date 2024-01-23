FROM ubuntu

RUN apt update && apt install -y wget libhivex-bin libwin-hivex-perl wimtools
