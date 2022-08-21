FROM public.ecr.aws/n8h1l8f0/aml2-amd64/cargo-lambda:1.0.1

# Set ENVs
ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG DOPPLER_SERVICE_TOKEN
ARG REGION

# Build lambda rust app
COPY ./ ./
RUN cargo lambda build --release

RUN export HISTIGNORE="doppler*"
RUN echo "$DOPPLER_SERVICE_TOKEN" | doppler configure set token --scope /

RUN doppler secrets
RUN export LAMBDA_IAM_ROLE=`doppler secrets get LAMBDA_IAM_ROLE`
RUN doppler run --command="echo ${LAMBDA_IAM_ROLE}"
RUN doppler run --command="echo ${RSS_FEEDS}"
#RUN doppler run --command="cargo lambda deploy --region ${REGION} --iam-role ${LAMBDA_IAM_ROLE} rss-news-feed-scraper"
RUN cargo lambda deploy --region ${REGION} --iam-role ${LAMBDA_IAM_ROLE} rss-news-feed-scraper
