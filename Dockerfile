################################
#      DEPENDENCY BUILDER      #
################################


FROM amazonlinux:2.0.20220719.0

# Install rust and cargo
RUN amazon-linux-extras install rust1 -y
RUN cargo install cargo-lambda
RUN export PATH=$PATH:/root/.cargo/bin

# Install zig and ensure it can be found
RUN yum install tar xz -y
RUN curl -O https://ziglang.org/download/0.9.1/zig-linux-aarch64-0.9.1.tar.xz
RUN tar --xz -xvf zig-linux-aarch64-0.9.1.tar.xz
RUN mv /zig-linux-aarch64-0.9.1/zig /usr/local/bin/
RUN mv /zig-linux-aarch64-0.9.1/lib/ /usr/local/bin/

# Install OpenSSL
#RUN yum install openssl -y
#RUN set OPENSSL_LIB_DIR=/usr/lib64/openssl/engines
#RUN set OPENSSL_DIR=/usr/bin
#
#RUN echo $OPENSSL_DIR
#RUN echo $OPENSSL_LIB_DIR

# Build lambda rust app
COPY ./ ./
RUN cargo lambda build --release --arm64


CMD ["target/release/discord_news_bot"]
