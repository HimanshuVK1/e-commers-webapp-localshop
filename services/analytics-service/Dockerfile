# Stage 1: Build dependencies
FROM python:3.11-slim as builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# Stage 2: Runtime
FROM python:3.11-slim
WORKDIR /app

# Create non-root user
RUN groupadd -g 65532 nonroot && \
    useradd -r -u 65532 -g nonroot nonroot

# Copy dependencies and source
COPY --from=builder /root/.local /home/nonroot/.local
COPY src/ ./src/

# Update PATH for local installs
ENV PATH=/home/nonroot/.local/bin:$PATH
ENV PYTHONPATH=/app/src

USER nonroot
EXPOSE 8008

CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8008"]
