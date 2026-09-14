FROM node:22-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    iptables ipset iproute2 dnsutils aggregate \
    curl ca-certificates git jq openssh-client gnupg \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor -o /usr/share/keyrings/adoptium.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb bookworm main" > /etc/apt/sources.list.d/adoptium.list \
    && apt-get update && apt-get install -y --no-install-recommends temurin-25-jdk \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/temurin-25-jdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

RUN usermod -l cpp-website -d /home/cpp-website -m node && groupmod -n cpp-website node
COPY init-firewall.sh /usr/local/bin/init-firewall.sh
RUN chmod +x /usr/local/bin/init-firewall.sh

#RUN mkdir -p /home/cpp-website/.ssh && chmod 700 /home/cpp-website/.ssh
#COPY ssh_config /home/cpp-website/.ssh/config
#RUN chown -R cpp-website:cpp-website /home/cpp-website/.ssh && chmod 600 /home/cpp-website/.ssh/config

WORKDIR /workspace
