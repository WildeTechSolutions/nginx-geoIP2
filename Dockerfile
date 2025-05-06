FROM nginx:latest

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    git \
    curl \
    unzip \
    libmaxminddb-dev \
    build-essential \
    libpcre3 \
    libpcre3-dev \
    zlib1g-dev \
    libssl-dev

# Download Nginx source matching installed version
RUN nginx_version=$(nginx -v 2>&1 | awk -F/ '{print $2}') && \
    wget http://nginx.org/download/nginx-${nginx_version}.tar.gz && \
    tar -xzvf nginx-${nginx_version}.tar.gz && \
    cd nginx-${nginx_version} && \
    git clone https://github.com/leev/ngx_http_geoip2_module.git

# Configure, compile, and install the module
RUN cd nginx-$(nginx -v 2>&1 | awk -F/ '{print $2}') && \
    ./configure --with-compat --add-dynamic-module=ngx_http_geoip2_module && \
    make modules && \
    cp objs/ngx_http_geoip2_module.so /etc/nginx/modules/

# Cleanup
RUN rm -rf /var/lib/apt/lists/* nginx-* ngx_http_geoip2_module


CMD ["nginx", "-g", "daemon off;"]
