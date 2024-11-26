
### SOFTWARE VERSIONS ---------------------- ###

ARG CUDA_IMAGE=nvidia/cuda:12.5.1-cudnn-devel-ubuntu20.04
ARG CONDA_IMAGE=continuumio/miniconda3:latest
ARG DV_GPU_BUILD=1
ARG DORADO=0.7.2
ARG MINIMAP2=2.28
ARG MODKIT=0.3.3
ARG SAMTOOLS=1.20

### GET CONDA PACKAGES --------------------- ###

FROM ${CONDA_IMAGE} as conda_img

# Update conda
RUN conda update -y conda

# Add channels
RUN conda config --add channels defaults && \
    conda config --add channels bioconda && \
    conda config --add channels conda-forge

# Install mamba
RUN conda install -y mamba

# Installing software
RUN mamba install -y \
    hcc::dorado=${DORADO} \
    hcc::dorado-gpu=${DORADO} \
    git \
    h5py \
    minimap2=${MINIMAP2} \
    ont-fast5-api \
    ont-modkit=${MODKIT} \
    numba \
    numpy \
    pandas \
    pysam \
    pytorch \
    samtools=${SAMTOOLS} \
    tqdm && \
    conda clean -afty

RUN pip install pod5

### COPY CONDA TO CUDA IMAGE --------------- ###

FROM ${CUDA_IMAGE} as cuda_img

COPY --from=conda_img /opt/conda /opt/conda

ENV DV_GPU_BUILD=${DV_GPU_BUILD}

ENV PATH $PATH:/opt/conda/bin

### DOWNLOAD DeepMod2 BINARIES ------------- ###

RUN cd /opt && \
    git clone https://github.com/WGLab/DeepMod2.git

# Adding DeepMod2 to PATH
ENV PATH $PATH:/opt/DeepMod2

### SETTING WORKING ENVIRONMENT ------------ ###

# Set workdir to /home/
WORKDIR /home/

# Launch bash automatically
CMD ["/bin/bash"]
