FROM public.ecr.aws/n8h1l8f0/amzn-linux-2/cargo-lambda:1.0.1

# Build lambda rust app
COPY ./ ./
RUN cargo lambda build --release --arm64