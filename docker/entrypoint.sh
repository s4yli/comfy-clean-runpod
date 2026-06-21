#!/usr/bin/env bash
set -Eeuo pipefail

COMFYUI_DIR="${COMFYUI_DIR:-/opt/ComfyUI}"
WORKSPACE="${WORKSPACE:-/workspace}"
DATA_DIR="${WORKSPACE}/comfyui"

mkdir -p "${DATA_DIR}"/{models,input,output,user}

# Seed ComfyUI's empty model directory layout once, without shipping models.
if [[ ! -e "${DATA_DIR}/.model-layout-created" ]]; then
    cp -a "${COMFYUI_DIR}/models/." "${DATA_DIR}/models/"
    touch "${DATA_DIR}/.model-layout-created"
fi

for directory in models input output user; do
    rm -rf "${COMFYUI_DIR:?}/${directory}"
    ln -s "${DATA_DIR}/${directory}" "${COMFYUI_DIR}/${directory}"
done

exec /opt/venv/bin/python "${COMFYUI_DIR}/main.py" \
    --listen 0.0.0.0 \
    --port "${COMFYUI_PORT:-8188}" \
    "$@"

