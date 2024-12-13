FROM paperist/texlive-ja:latest

RUN apt update && \
    apt install -y ghostscript && \
    rm -rf /var/lib/apt