FROM factual/docker-cdh5-dev
RUN apt-get update && \
 apt-get install -yq --no-install-recommends \
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
 lmodern && \
 apt-get clean && \
 rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
 apt-get install -yq --no-install-recommends \
 pandoc \
 python-dev \
 vim \
 unzip \
 libav-tools \
 fonts-dejavu \
 tzdata \
 gfortran \
 gcc && \
 apt-get clean && \
 rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
 apt-get install -yq --no-install-recommends \
 texlive-fonts-extra \
 texlive-fonts-recommended \
 texlive-generic-recommended \
 texlive-latex-base \
 texlive-latex-extra \
 texlive-xetex && \
 apt-get clean && \
 rm -rf /var/lib/apt/lists/*

RUN apt-get purge -y nodejs npm && \
 curl -sL https://deb.nodesource.com/setup_6.x | bash - && \
 apt-get install -yq --no-install-recommends \
    nodejs && \
 apt-get clean && \
 rm -rf /var/lib/apt/lists/*

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
 conda update --quiet --yes conda && \
 conda update --quiet --yes anaconda && \ 
 conda clean -tipsy

# R packages including IRKernel which gets installed globally.
RUN conda config --system --append channels r && \
 conda install --quiet --yes \
 -c defaults \
 -c conda-forge \ 
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
 r-randomforest \
 geopandas \
 jupyterlab \
 pyspark \
 pymc3 \
 ipywidgets \
 beakerx && \
 conda clean -tipsy 

# Install facets which does not have a pip or conda package at the moment
RUN cd /tmp && \
 git clone https://github.com/PAIR-code/facets.git && \
 cd facets && \
 jupyter nbextension install facets-dist/ --sys-prefix && \
 rm -rf facets

# Install jupyter Spark Kernels
#RUN pip install --no-cache-dir \
# https://dist.apache.org/repos/dist/dev/incubator/toree/0.2.0/snapshots/dev1/toree-pip/toree-0.2.0.dev1.tar.gz && \
# jupyter toree install --sys-prefix --interpreters=Scala,PySpark,SparkR,SQL

# Install pip packages *after* conda packages to avoid
# having conda solve the environment.
RUN pip install \
 sparkmagic \
 hdbscan \
 fastcluster \
 ggplot \
 dash \
 dash-renderer \
 dash-html-components \
 dash-core-components \
 plotly \
 folium \
 --no-cache-dir && \
 jupyter nbextension enable --py --sys-prefix widgetsnbextension

RUN cd /opt/conda/lib/python3.6/site-packages && \
 jupyter-kernelspec install sparkmagic/kernels/sparkkernel && \
 jupyter-kernelspec install sparkmagic/kernels/pyspark3kernel && \
 jupyter-kernelspec install sparkmagic/kernels/sparkrkernel && \
 jupyter serverextension enable --py sparkmagic && \
 jupyter labextension install @jupyterlab/plotly-extension 


# Import matplotlib the first time to build the font cache.
RUN MPLBACKEND=Agg python -c "import matplotlib.pyplot" 
WORKDIR /home
ENV MAVEN_OPTS="-Xmx512m"

