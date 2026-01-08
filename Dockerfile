# QCA_LeeQ - Quantum Calibration Agent with LeeQ Integration
#
# Build: docker build -t qca-leeq .
# Run:   docker run -it -p 8000:8000 -e OPENAI_API_KEY=sk-xxx qca-leeq

FROM python:3.12-slim

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy submodules
COPY LeeQ /app/LeeQ
COPY CalibrationNTKAgent /app/CalibrationNTKAgent

# Install LeeQ
RUN pip install --no-cache-dir -e /app/LeeQ

# Install CalibrationNTKAgent dependencies
RUN pip install --no-cache-dir -e /app/CalibrationNTKAgent

# Install additional dependencies that may be missing
RUN pip install --no-cache-dir python-frontmatter langchain-sandbox PyYAML

# Fix mllm compatibility (add p_map export)
RUN MLLM_UTILS_INIT=$(python -c "import mllm.utils; print(mllm.utils.__file__)") && \
    if ! grep -q "p_map" "$MLLM_UTILS_INIT"; then \
        echo "from .maps import p_map" >> "$MLLM_UTILS_INIT"; \
    fi

# Copy configuration files
COPY config /app/config

# Copy entrypoint script
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV EPII_EXPERIMENT_SET=leeq
ENV QCA_CONFIG_DIR=/app/config

# Expose web UI port
EXPOSE 8000

# Use entrypoint script
ENTRYPOINT ["/app/entrypoint.sh"]

# Default command - interactive TUI
CMD ["tui"]
