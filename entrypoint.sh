#!/bin/bash
set -e

# QCA_LeeQ Entrypoint Script
# Launches web UI in background and provides CLI/TUI interface

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check for OpenAI API key
if [ -z "$OPENAI_API_KEY" ]; then
    echo -e "${YELLOW}Warning: OPENAI_API_KEY not set. LLM features will not work.${NC}"
    echo -e "${YELLOW}Set it with: -e OPENAI_API_KEY=sk-xxx${NC}"
fi

# Function to cleanup background processes
cleanup() {
    echo -e "\n${YELLOW}Shutting down...${NC}"
    if [ ! -z "$WEBUI_PID" ]; then
        kill $WEBUI_PID 2>/dev/null || true
    fi
    exit 0
}

trap cleanup SIGINT SIGTERM

# Start web UI in background
start_webui() {
    echo -e "${GREEN}Starting QCA Web UI on port 8000...${NC}"
    cd /app/CalibrationNTKAgent
    python -m quantum_calibration_agent.cli.main serve --host 0.0.0.0 --port 8000 &
    WEBUI_PID=$!
    sleep 2
    if kill -0 $WEBUI_PID 2>/dev/null; then
        echo -e "${GREEN}Web UI started successfully (PID: $WEBUI_PID)${NC}"
        echo -e "${GREEN}Access at: http://localhost:8000${NC}"
    else
        echo -e "${RED}Failed to start Web UI${NC}"
    fi
}

# Main logic based on command
case "${1:-tui}" in
    tui)
        # Start web UI in background, then run TUI
        start_webui
        echo -e "${GREEN}Starting QCA TUI...${NC}"
        cd /app/CalibrationNTKAgent
        exec python -m quantum_calibration_agent.cli.main tui
        ;;
    serve)
        # Only run web UI (foreground)
        echo -e "${GREEN}Starting QCA Web UI on port 8000 (foreground)...${NC}"
        cd /app/CalibrationNTKAgent
        exec python -m quantum_calibration_agent.cli.main serve --host 0.0.0.0 --port 8000
        ;;
    exec)
        # Start web UI in background, then execute command
        start_webui
        shift
        echo -e "${GREEN}Executing: qca exec $@${NC}"
        cd /app/CalibrationNTKAgent
        python -m quantum_calibration_agent.cli.main exec "$@"
        cleanup
        ;;
    shell)
        # Start web UI in background, drop to shell
        start_webui
        echo -e "${GREEN}Dropping to shell. Use 'qca' commands or exit to stop.${NC}"
        exec /bin/bash
        ;;
    *)
        # Pass through to qca CLI
        cd /app/CalibrationNTKAgent
        exec python -m quantum_calibration_agent.cli.main "$@"
        ;;
esac
