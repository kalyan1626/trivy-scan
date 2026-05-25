FROM ubuntu:16.04

# Install old vulnerable packages
RUN apt-get update && apt-get install -y \
    apache2 \
    openssl \
    curl \
    bash \
    sudo \
    wget \
    vim \
    telnet \
    ftp \
    mysql-client \
    python2.7

# Hardcoded secrets
ENV AWS_ACCESS_KEY_ID="AKIAIOSFODNN7EXAMPLE"
ENV AWS_SECRET_ACCESS_KEY="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"

# Weak password file
RUN echo "root:root123" | chpasswd

# Create sensitive files
RUN mkdir /app

# Fake API Keys
RUN echo "github_token=ghp_1234567890abcdefghijklmnop" > /app/config.txt

RUN echo "password=admin123" >> /app/config.txt

RUN echo "secret_key=mysecretkey" >> /app/config.txt

# SSH private key simulation
RUN echo "-----BEGIN RSA PRIVATE KEY-----" > /app/id_rsa

RUN echo "MIIEowIBAAKCAQEA1234567890EXAMPLEKEY" >> /app/id_rsa

RUN echo "-----END RSA PRIVATE KEY-----" >> /app/id_rsa

# Dangerous permissions
RUN chmod 777 /app/config.txt

RUN chmod 777 /app/id_rsa

# Run as root
USER root

# Expose unnecessary ports
EXPOSE 21
EXPOSE 22
EXPOSE 23
EXPOSE 80
EXPOSE 3306

# Create vulnerable web page
RUN echo "<h1>Vulnerable Apache Server</h1>" > /var/www/html/index.html

CMD ["/bin/bash"]
