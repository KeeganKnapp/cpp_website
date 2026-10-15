FROM node:22-slim

WORKDIR /workspace

RUN apt-get update && apt-get install -y --no-install-recommends \
    iptables ipset iproute2 dnsutils aggregate \
    curl ca-certificates git jq openssh-client gnupg \
    gcc g++ cmake cmake-data make\
    git \
    libjsoncpp-dev uuid-dev zlib1g-dev libssl-dev openssl \
    libmariadb-dev-compat libmariadb-dev \
    && rm -rf /var/lib/apt/lists/*


RUN curl -fsSL https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor -o /usr/share/keyrings/adoptium.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb bookworm main" > /etc/apt/sources.list.d/adoptium.list \
    && apt-get update && apt-get install -y --no-install-recommends temurin-25-jdk \
    && rm -rf /var/lib/apt/lists/*





RUN git clone https://github.com/drogonframework/drogon /opt/drogon \
    && cd /opt/drogon && git submodule update --init \
    && mkdir build && cd build \
    && cmake .. && make -j"$(nproc)" && make install \
    && rm -rf /opt/drogon

RUN cd /workspace/hello-world/controllers

RUN usermod -l cpp-website -d /home/cpp-website -m node && groupmod -n cpp-website node
COPY init-firewall.sh /usr/local/bin/init-firewall.sh
RUN chmod +x /usr/local/bin/init-firewall.sh

#RUN mkdir -p /home/cpp-website/.ssh && chmod 700 /home/cpp-website/.ssh
#COPY ssh_config /home/cpp-website/.ssh/config
#RUN chown -R cpp-website:cpp-website /home/cpp-website/.ssh && chmod 600 /home/cpp-website/.ssh/config



WORKDIR /workspace






