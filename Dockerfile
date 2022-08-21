FROM public.ecr.aws/n8h1l8f0/aml2-amd64/cargo-lambda:1.0.1

# Set ENVs
ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG DOPPLER_SERVICE_TOKEN
ARG REGION

RUN echo ${REGION}
RUN echo ${AWS_ACCESS_KEY_ID}

# Build lambda rust app
COPY ./ ./
RUN cargo lambda build --release

RUN export HISTIGNORE="doppler*"
RUN echo "$DOPPLER_SERVICE_TOKEN" | doppler configure set token --scope /
RUN doppler run --command="cargo lambda deploy --region ${REGION} --iam-role $LAMBDA_IAM_ROLE rss-news-feed-scraper"
