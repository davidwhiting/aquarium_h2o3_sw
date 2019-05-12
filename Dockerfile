FROM ubuntu:18.04
MAINTAINER David.Whiting <david.whiting@h2o.ai>

# Linux
RUN \
  apt-get -y update && \
  apt-get -y install \
    apt-transport-https \
    apt-utils \
    software-properties-common \
    gnupg \
    vim

# RStudio
RUN \
## change keyserver command
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9 && \
  echo "deb https://cran.rstudio.com/bin/linux/ubuntu bionic-cran35/" >> /etc/apt/sources.list

# Java8
RUN \
  apt-get -y install \
    openjdk-8-jre \
    openjdk-8-jdk

# Linux
RUN \
  apt-get -y install \
    cpio \
    curl \
    dirmngr \
    gdebi-core \
    git \
    net-tools \
    sudo \
    vim \
    wget \
    zip

# R
RUN \
  apt-get -y install \
    r-base \
    r-base-dev \
    r-cran-jsonlite \
    r-cran-rcurl && \
  mkdir -p /usr/local/lib/R/site-library && \
  chmod 777 /usr/local/lib/R/site-library

# Log directory used by run.sh
RUN \
  mkdir /log && \
  chmod o+w /log

# RStudio
RUN \
  apt-get -y install locales && \
  locale-gen en_US.UTF-8 && \
  update-locale LANG=en_US.UTF-8 && \
  wget https://download2.rstudio.org/server/trusty/amd64/rstudio-server-1.2.1335-amd64.deb && \
  gdebi --non-interactive rstudio-server-1.2.1335-amd64.deb && \
  echo "server-app-armor-enabled=0" >> /etc/rstudio/rserver.conf


# ----- USER H2O -----

# h2o user
RUN \
  useradd -ms /bin/bash h2o && \
  usermod -a -G sudo h2o && \
  echo "h2o:h2o" | chpasswd && \
  echo 'h2o ALL=NOPASSWD: ALL' >> /etc/sudoers

RUN \
  apt-get -y install bzip2

USER h2o
WORKDIR /home/h2o

# Miniconda
ENV MINICONDA_FILE=Miniconda3-4.5.4-Linux-x86_64.sh
RUN \
  wget https://repo.continuum.io/miniconda/${MINICONDA_FILE} && \
  bash ${MINICONDA_FILE} -b -p /home/h2o/Miniconda3 && \
  /home/h2o/Miniconda3/bin/conda create -y --name pysparkling python=2.7 anaconda && \
  /home/h2o/Miniconda3/bin/conda create -y --name h2o python=3.6 anaconda && \
  /home/h2o/Miniconda3/envs/h2o/bin/jupyter notebook --generate-config && \
  sed -i "s/#c.NotebookApp.token = '<generated>'/c.NotebookApp.token = 'h2o'/" .jupyter/jupyter_notebook_config.py && \
  rm ${MINICONDA_FILE}

# H2O
# http://h2o-release.s3.amazonaws.com/h2o/rel-yates/3/h2o-3.24.0.3.zip
ENV H2O_BRANCH_NAME=rel-yates
ENV H2O_BUILD_NUMBER=3
ENV H2O_PROJECT_VERSION=3.24.0.${H2O_BUILD_NUMBER}
ENV H2O_DIRECTORY=h2o-${H2O_PROJECT_VERSION}

export H2O_BRANCH_NAME=rel-yates
export H2O_BUILD_NUMBER=3
export H2O_PROJECT_VERSION=3.24.0.${H2O_BUILD_NUMBER}
export H2O_DIRECTORY=h2o-${H2O_PROJECT_VERSION}

RUN \
  wget http://h2o-release.s3.amazonaws.com/h2o/${H2O_BRANCH_NAME}/${H2O_BUILD_NUMBER}/h2o-${H2O_PROJECT_VERSION}.zip && \
  unzip ${H2O_DIRECTORY}.zip && \
  rm ${H2O_DIRECTORY}.zip && \
  bash -c "source /home/h2o/Miniconda3/bin/activate h2o && pip install ${H2O_DIRECTORY}/python/h2o*.whl"
  R CMD INSTALL ${H2O_DIRECTORY}/R/h2o*.gz

# Spark
ENV SPARK_VERSION=2.4.0
ENV SPARK_HADOOP_VERSION=2.7
ENV SPARK_DIRECTORY=spark-${SPARK_VERSION}-bin-hadoop${SPARK_HADOOP_VERSION}
ENV SPARK_HOME=/home/h2o/bin/spark

export SPARK_VERSION=2.4.0
export SPARK_HADOOP_VERSION=2.7
export SPARK_DIRECTORY=spark-${SPARK_VERSION}-bin-hadoop${SPARK_HADOOP_VERSION}
export SPARK_HOME=/home/h2o/bin/spark

# https://archive.apache.org/dist/spark/spark-2.4.0/spark-2.4.0-bin-hadoop2.7.tgz
RUN \
  mkdir bin && \
  cd bin && \
  mkdir -p ${SPARK_HOME} && \
  wget https://archive.apache.org/dist/spark/spark-2.4.0/spark-2.4.0-bin-hadoop2.7.tgz && \
#  wget http://mirrors.sonic.net/apache/spark/spark-${SPARK_VERSION}/${SPARK_DIRECTORY}.tgz && \
  tar zxvf spark-2.4.0-bin-hadoop2.7.tgz -C ${SPARK_HOME} --strip-components 1 && \
#  tar zxvf ${SPARK_DIRECTORY}.tgz -C ${SPARK_HOME} --strip-components 1 && \
  rm ${SPARK_DIRECTORY}.tgz && \
  bash -c "source /home/h2o/Miniconda3/bin/activate pysparkling && pip install tabulate future colorama"


# Sparkling Water
# https://s3.amazonaws.com/h2o-release/sparkling-water/rel-2.4/10/sparkling-water-2.4.10.zip
ENV SPARKLING_WATER_BRANCH_NUMBER=2.4
ENV SPARKLING_WATER_BRANCH_NAME=rel-${SPARKLING_WATER_BRANCH_NUMBER}
ENV SPARKLING_WATER_BUILD_NUMBER=10
ENV SPARKLING_WATER_PROJECT_VERSION=${SPARKLING_WATER_BRANCH_NUMBER}.${SPARKLING_WATER_BUILD_NUMBER}
ENV SPARKLING_WATER_DIRECTORY=sparkling-water-${SPARKLING_WATER_PROJECT_VERSION}

export SPARKLING_WATER_BRANCH_NUMBER=2.4
export SPARKLING_WATER_BRANCH_NAME=rel-${SPARKLING_WATER_BRANCH_NUMBER}
export SPARKLING_WATER_BUILD_NUMBER=10
export SPARKLING_WATER_PROJECT_VERSION=${SPARKLING_WATER_BRANCH_NUMBER}.${SPARKLING_WATER_BUILD_NUMBER}
export SPARKLING_WATER_DIRECTORY=sparkling-water-${SPARKLING_WATER_PROJECT_VERSION}

RUN \
  cd bin && \
  wget http://h2o-release.s3.amazonaws.com/sparkling-water/${SPARKLING_WATER_BRANCH_NAME}/${SPARKLING_WATER_BUILD_NUMBER}/${SPARKLING_WATER_DIRECTORY}.zip && \
  unzip ${SPARKLING_WATER_DIRECTORY}.zip && \
  mv ${SPARKLING_WATER_DIRECTORY} sparkling-water && \
  rm ${SPARKLING_WATER_DIRECTORY}.zip && \
  /home/h2o/Miniconda3/envs/pysparkling/bin/ipython profile create pyspark 

COPY --chown=h2o conf/pyspark/00-pyspark-setup.py /home/h2o/.ipython/profile_pyspark/startup/
COPY --chown=h2o conf/pyspark/kernel.json /home/h2o/Miniconda3/envs/h2o/share/jupyter/kernels/pyspark/
ENV SPARKLING_WATER_HOME=/home/h2o/bin/sparkling-water

######################################################################
# ADD CONTENT FOR INDIVIDUAL HANDS-ON SESSIONS HERE
######################################################################

# Prologue
RUN \
  mkdir h2o-3-hands-on && \
  mkdir sparkling-water-hands-on

#RUN \
#  cd h2o-3-hands-on && \
#  mkdir data && \
#  cd data && \
#  wget https://s3.amazonaws.com/h2o-public-test-data/bigdata/laptop/lending-club/LoanStats3a.csv

#RUN \
#  cd sparkling-water-hands-on && \
#  mkdir data && \
#  cd data && \
#  wget https://s3.amazonaws.com/h2o-training/events/h2o_world/TimeSeries/all_stocks_2006-01-01_to_2018-01-01.csv

## H2O-3 Demo
#COPY --chown=h2o h2o-3-hands-on/LendingClubTraining.ipynb h2o-3-hands-on/

## Sparkling Water Demo
#COPY --chown=h2o sparkling-water-hands-on/ForecastingVolume.ipynb sparkling-water-hands-on/

######################################################################

# ----- RUN INFORMATION -----

USER h2o
WORKDIR /home/h2o
ENV JAVA_HOME=/usr

# Entry point
COPY run.sh /run.sh

ENTRYPOINT ["/run.sh"]
  
EXPOSE 54321
EXPOSE 54327
EXPOSE 8888
EXPOSE 8787
EXPOSE 4040
