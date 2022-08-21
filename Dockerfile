FROM public.ecr.aws/n8h1l8f0/aml2-amd64/cargo-lambda:1.0.1

# Set ENVs
ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG DOPPLER_SERVICE_TOKEN
ARG REGION

RUN export HISTIGNORE="doppler*"
RUN echo "$DOPPLER_SERVICE_TOKEN" | doppler configure set token --scope /

RUN doppler secrets download --no-file --format env | grep RSS_FEEDS
RUN doppler secrets download --no-file --format env | grep DISCORD_CHANNEL_WEBHOOK

# Build lambda rust app
COPY ./ ./

RUN sed -i 's/\$DISCORD_CHANNEL_WEBHOOK/('"$DISCORD_CHANNEL_WEBHOOK"')/G' src/lib.rs
RUN sed -i 's/\$RSS_FEEDS/('"$RSS_FEEDS"')/G' src/lib.rs
RUN cargo lambda build --release



RUN doppler secrets download --no-file --format env | grep LAMBDA_IAM_ROLE
RUN cargo lambda deploy -v --region ${REGION} --iam-role ${LAMBDA_IAM_ROLE} rss-news-feed-scraper
