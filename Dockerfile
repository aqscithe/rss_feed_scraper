################################
#      DEPENDENCY BUILDER      #
################################

FROM rust:1.63.0-buster

COPY ./ ./
RUN cargo build --release

CMD ["target/release/discord_news_bot"]
