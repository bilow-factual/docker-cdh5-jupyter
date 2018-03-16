FROM factual/docker-cdh5-dev
RUN apt-get update && apt-get -yq dist-upgrade \
 && apt-get install -yq --no-install-recommends \
    wget \
    bzip2 \
    ca-certificates \
    sudo \
    locales \
    fonts-liberation \
    build-essential \
    emacs \
    git \
    inkscape \
    jed \
    libsm6 \
    libxext-dev \
    libxrender1 \
    lmodern \
    pandoc \
    python-dev \
    texlive-fonts-extra \
    texlive-fonts-recommended \
    texlive-generic-recommended \
    texlive-latex-base \
    texlive-latex-extra \
    texlive-xetex \
    vim \
    unzip \
    libav-tools \
    fonts-dejavu \
    tzdata \
    gfortran \
    gcc \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

# Configure environment
ENV CONDA_DIR=/opt/conda \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8
ENV PATH=$CONDA_DIR/bin:$PATH

ENV ANACONDA_VERSION 4.3.1
RUN cd /tmp && \
    wget --quiet https://repo.continuum.io/archive/Anaconda3-${ANACONDA_VERSION}-Linux-x86_64.sh && \
    echo "9209864784250d6855886683ed702846 *Anaconda3-${ANACONDA_VERSION}-Linux-x86_64.sh" | md5sum -c - && \
    /bin/bash Anaconda3-${ANACONDA_VERSION}-Linux-x86_64.sh -f -b -p $CONDA_DIR && \
    rm Anaconda3-${ANACONDA_VERSION}-Linux-x86_64.sh && \
    $CONDA_DIR/bin/conda config --system --set show_channel_urls true && \
    $CONDA_DIR/bin/conda update --all --quiet --yes && \
    conda clean -tipsy

RUN conda update conda && \
    conda update anaconda && \
    conda install -y geopandas jupyterlab && \
    conda clean -tipsy

# Import matplotlib the first time to build the font cache.
RUN MPLBACKEND=Agg python -c "import matplotlib.pyplot" 

# R packages including IRKernel which gets installed globally.
RUN conda config --system --append channels r && \
    conda install --quiet --yes \
    rpy2 \
    r-base \
    r-irkernel \
    r-plyr \
    r-devtools \
    r-tidyverse \
    r-shiny \
    r-rmarkdown \
    r-forecast \
    r-rsqlite \
    r-reshape2 \
    r-nycflights13 \
    r-caret \
    r-rcurl \
    r-crayon \
    r-randomforest && \
    conda clean -tipsy 

# Install facets which does not have a pip or conda package at the moment
RUN cd /tmp && \
    git clone https://github.com/PAIR-code/facets.git && \
    cd facets && \
    jupyter nbextension install facets-dist/ --sys-prefix && \
    rm -rf facets

RUN conda install --yes --quiet \
    -c conda-forge \ 
    ipywidgets beakerx && \
    conda clean -tipsy

# Install jupyter Spark Kernels
#RUN pip install --no-cache-dir \
#    https://dist.apache.org/repos/dist/dev/incubator/toree/0.2.0-incubating-rc3/toree-pip/toree-0.2.0.tar.gz && \
#    jupyter toree install --sys-prefix --interpreters=Scala,PySpark,SparkR,SQL
RUN pip install sparkmagic --no-cache-dir && \
    jupyter nbextension enable --py --sys-prefix widgetsnbextension

RUN wget --quiet http://repo1.maven.org/maven2/com/madgag/bfg/1.13.0/bfg-1.13.0.jar && \
    mv bfg-1.13.0.jar /usr/bin/bfg.jar

WORKDIR /home

