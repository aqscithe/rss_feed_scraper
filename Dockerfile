FROM public.ecr.aws/n8h1l8f0/aml2-amd64/cargo-lambda:1.0.0


# Build lambda rust app
COPY ./ ./
RUN cargo lambda build --release --arm64

