FROM nvidia/cuda:12.8.1-cudnn-runtime-ubuntu24.04 AS builder

ARG DEBIAN_FRONTEND=noninteractive
ARG COMFYUI_REF=master
ARG PYTORCH_INDEX_URL=https://download.pytorch.org/whl/cu128

ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    COMFYUI_DIR=/opt/ComfyUI \
    WORKSPACE=/workspace

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        libgl1 \
        libglib2.0-0 \
        python3 \
        python3-pip \
        python3-venv \
    && rm -rf /var/lib/apt/lists/*

RUN git init "${COMFYUI_DIR}" \
    && git -C "${COMFYUI_DIR}" remote add origin https://github.com/Comfy-Org/ComfyUI.git \
    && git -C "${COMFYUI_DIR}" fetch --depth 1 origin "${COMFYUI_REF}" \
    && git -C "${COMFYUI_DIR}" checkout --detach FETCH_HEAD \
    && rm -rf "${COMFYUI_DIR}/.git" \
    && python3 -m venv /opt/venv \
    && /opt/venv/bin/pip install --upgrade pip setuptools wheel \
    && /opt/venv/bin/pip install --index-url "${PYTORCH_INDEX_URL}" \
        torch torchvision torchaudio \
    && /opt/venv/bin/pip install -r "${COMFYUI_DIR}/requirements.txt"

FROM nvidia/cuda:12.8.1-cudnn-runtime-ubuntu24.04

ARG DEBIAN_FRONTEND=noninteractive

ENV PYTHONUNBUFFERED=1 \
    COMFYUI_DIR=/opt/ComfyUI \
    WORKSPACE=/workspace

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        libgl1 \
        libglib2.0-0 \
        python3 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/ComfyUI /opt/ComfyUI
COPY --from=builder /opt/venv /opt/venv

COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod 0755 /entrypoint.sh

WORKDIR /opt/ComfyUI
EXPOSE 8188

HEALTHCHECK --interval=30s --timeout=5s --start-period=90s --retries=3 \
    CMD python3 -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8188/', timeout=3)" || exit 1

ENTRYPOINT ["/entrypoint.sh"]
