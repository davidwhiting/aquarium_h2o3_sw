FROM ubuntu:18.04
LABEL maintainer="David Whiting <david.whiting@h2o.ai>"

## Below ENV only used when needed in the image. ARG is 
## available during build but will not be set in final 
## image.

ARG BASE=/home/h2o/bin

##############################
## Versioning information
##   Update these values and (hopefully) everything
##   will run correctly below. YMMV.

ARG RSTUDIO_VERSION=1.2.1335

ARG CONDA_PYTHON_H2O=3.6
ARG CONDA_PYTHON_PYSPARKLING=2.7

ARG H2O_BRANCH_NAME=yau
ARG H2O_MAJOR_VERSION=3.26.0
ARG H2O_BUILD_NUMBER=2

ARG SPARK_VERSION=2.4.3
ARG SPARK_HADOOP_VERSION=2.7

ARG SPARKLING_WATER_BRANCH_NUMBER=2.4
ARG SPARKLING_WATER_BUILD_NUMBER=13

ARG ZEPPELIN_VERSION=0.8.1

  # file found at $SPARK_HOME/python/lib/
ARG PY4J_VERSION=0.10.7

##### DON'T CHANGE ARG OR ENV BELOW ############

ARG CONDA_HOME=${BASE}/miniconda3
ENV SPARK_HOME=${BASE}/spark
ARG SPARKLING_WATER_HOME=${BASE}/sparkling-water
ARG ZEPPELIN_HOME=${BASE}/zeppelin

# To keep tzdata from requesting time zones interactively
ARG DEBIAN_FRONTEND=noninteractive

ARG RSTUDIO=rstudio-server-${RSTUDIO_VERSION}-amd64.deb

ARG MINICONDA_FILE=Miniconda3-latest-Linux-x86_64.sh
ARG CONDA=${CONDA_HOME}/bin/conda

ARG H2O_S3_PATH=http://h2o-release.s3.amazonaws.com/h2o
ARG H2O_PROJECT_VERSION=${H2O_MAJOR_VERSION}.${H2O_BUILD_NUMBER}
ARG H2O_DIRECTORY=h2o-${H2O_PROJECT_VERSION}

ARG SPARK_PATH=https://archive.apache.org/dist/spark
#ARG SPARK_PATH=https://www-us.apache.org/dist/spark
ARG SPARK_DIRECTORY=spark-${SPARK_VERSION}-bin-hadoop${SPARK_HADOOP_VERSION}

ARG SPARKLING_WATER_PATH=http://h2o-release.s3.amazonaws.com/sparkling-water
ARG SPARKLING_WATER_BRANCH_NAME=rel-${SPARKLING_WATER_BRANCH_NUMBER}
ARG SPARKLING_WATER_PROJECT_VERSION=${SPARKLING_WATER_BRANCH_NUMBER}.${SPARKLING_WATER_BUILD_NUMBER}
ARG SPARKLING_WATER_DIRECTORY=sparkling-water-${SPARKLING_WATER_PROJECT_VERSION}

ARG KERNEL=${CONDA_HOME}/envs/h2o/share/jupyter/kernels/pyspark/kernel.json
ARG PY4J=py4j-${PY4J_VERSION}-src.zip

#https://www-us.apache.org/dist/zeppelin/zeppelin-0.8.1/zeppelin-0.8.1-bin-all.tgz
ARG ZEPPELIN_PATH=https://www-us.apache.org/dist/zeppelin/zeppelin-${ZEPPELIN_VERSION}
ARG ZEPPELIN=zeppelin-${ZEPPELIN_VERSION}-bin-all.tgz


#########################################

## Linux
RUN \
  apt-get -y update \
  && apt-get -y install \
        apt-transport-https \
        apt-utils \
        software-properties-common \
        bzip2 \
        cpio \
        curl \
        dirmngr \
        gdebi-core \
        git \
        graphviz \
        libcurl4-nss-dev \
        locales \
        net-tools \
        nginx \
        sudo \
	systemd \
        vim \
        wget \
        zip \
  && locale-gen en_US.UTF-8 \
  && update-locale LANG=en_US.UTF-8 

# Install Java 8
RUN \
  apt-get -y install \
        openjdk-8-jre \
        openjdk-8-jdk 

# Install R 3.6
RUN \
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 \
  && sudo add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/' \
  && apt-get -y update \
  && apt-get -y install \
        r-base \
        r-base-dev \
  && R -e 'chooseCRANmirror(graphics=FALSE, ind=1);install.packages(c("RCurl","jsonlite","ggplot2"));' \
  && mkdir -p /usr/local/lib/R/site-library \
  && chmod 777 /usr/local/lib/R/site-library 

# Markdown for RStudio
RUN \
  R -e 'chooseCRANmirror(graphics=FALSE, ind=1);install.packages(c("evaluate","highr","markdown","yaml","htmltools","knitr","based64enc","rprojroot","mime","rmarkdown"))' 

# RStudio Install
RUN \
  wget https://download2.rstudio.org/server/trusty/amd64/${RSTUDIO} \
  && gdebi --non-interactive ${RSTUDIO} \
  && echo "server-app-armor-enabled=0" >> /etc/rstudio/rserver.conf \
  && rm ${RSTUDIO} 

# Log directory used by run.sh
RUN \
  mkdir /log \
  && chmod o+w /log

# IRKernel for R in Jupyter
RUN \
  apt-get -y update \
  && apt-get -y install \
        libzmq3-dev \
        libcurl4-openssl-dev \
        libssl-dev \
        jupyter-core \
        jupyter-client \
  && R -e 'chooseCRANmirror(graphics=FALSE, ind=1);install.packages(c("repr", "IRdisplay", "IRkernel"), type = "source")' \
  && R -e 'IRkernel::installspec(user = FALSE)'

# Configure nginx
COPY templates/nginx/nginx.conf /etc/nginx/nginx.conf
COPY templates/nginx/sites-available/training /etc/nginx/sites-available/training
RUN \
  rm -f /etc/nginx/sites-available/default \
  && ln -s /etc/nginx/sites-available/training /etc/nginx/sites-enabled/training  

# ----- USER H2O -----

# h2o user
RUN \
  useradd -ms /bin/bash h2o && \
  usermod -a -G sudo h2o && \
  echo "h2o:h2o" | chpasswd && \
  echo 'h2o ALL=NOPASSWD: ALL' >> /etc/sudoers

USER h2o
WORKDIR /home/h2o

# Install Miniconda
RUN \
  wget https://repo.anaconda.com/miniconda/${MINICONDA_FILE} \
  && bash ${MINICONDA_FILE} -b -p ${CONDA_HOME} \
  && ${CONDA} update -n base -c defaults conda \
  && rm ${MINICONDA_FILE}

# Install H2O
RUN \
  ${CONDA} create -y --name h2o python=${CONDA_PYTHON_H2O} anaconda \
  && wget ${H2O_S3_PATH}/rel-${H2O_BRANCH_NAME}/${H2O_BUILD_NUMBER}/h2o-${H2O_PROJECT_VERSION}.zip \
  && unzip ${H2O_DIRECTORY}.zip \
  && rm ${H2O_DIRECTORY}.zip \
  && bash -c "source ${CONDA_HOME}/bin/activate h2o && pip install ${H2O_DIRECTORY}/python/h2o*.whl tqdm graphviz shap xgboost" \
  && ${CONDA_HOME}/envs/h2o/bin/jupyter notebook --generate-config \
  && sed -i "s/#c.NotebookApp.token = '<generated>'/c.NotebookApp.token = 'h2o'/" /home/h2o/.jupyter/jupyter_notebook_config.py \
  && R CMD INSTALL ${H2O_DIRECTORY}/R/h2o*.gz \
  && rm -rf ${H2O_DIRECTORY} 

# Install Spark
RUN \
  ${CONDA} create -y --name pysparkling python=${CONDA_PYTHON_PYSPARKLING} anaconda \
  && mkdir -p ${SPARK_HOME} \
  && wget ${SPARK_PATH}/spark-${SPARK_VERSION}/${SPARK_DIRECTORY}.tgz \
  && tar zxvf ${SPARK_DIRECTORY}.tgz -C ${SPARK_HOME} --strip-components 1 \
  && rm ${SPARK_DIRECTORY}.tgz \
  && bash -c "source ${CONDA_HOME}/bin/activate pysparkling && pip install tabulate future colorama" \
  && ${CONDA_HOME}/envs/pysparkling/bin/ipython profile create pyspark

# Install Sparkling Water  
RUN \
  wget ${SPARKLING_WATER_PATH}/${SPARKLING_WATER_BRANCH_NAME}/${SPARKLING_WATER_BUILD_NUMBER}/${SPARKLING_WATER_DIRECTORY}.zip \
  && unzip ${SPARKLING_WATER_DIRECTORY}.zip \
  && mv ${SPARKLING_WATER_DIRECTORY} ${SPARKLING_WATER_HOME} \
  && rm ${SPARKLING_WATER_DIRECTORY}.zip

# Install Apache Zeppelin (primarily for Scala)
RUN \
  wget ${ZEPPELIN_PATH}/${ZEPPELIN} \
  && mkdir -p ${ZEPPELIN_HOME} \
  && tar zxvf ${ZEPPELIN} -C ${ZEPPELIN_HOME} --strip-components 1 \
  && rm ${ZEPPELIN} \
  && cp ${ZEPPELIN_HOME}/conf/zeppelin-site.xml.template ${ZEPPELIN_HOME}/conf/zeppelin-site.xml

## Copy zeppelin files
COPY --chown=h2o templates/zeppelin/conf/shiro.ini ${ZEPPELIN_HOME}/conf/shiro.ini
COPY templates/zeppelin/etc/systemd/system/zeppelin.service /etc/systemd/system/

#RUN \
#  bash -c "${ZEPPELIN_HOME}/bin/zeppelin-daemon.sh start" 

# Install Spylon-kernel for Scala
#RUN \
#  bash -c "source ${CONDA_HOME}/bin/activate h2o && pip install spylon-kernel" \
#  && bash -c "sudo ${CONDA_HOME}/envs/h2o/bin/python -m spylon_kernel install"

## Copy templates and substitute for versions
COPY --chown=h2o templates/pyspark/00-pyspark-setup.py /home/h2o/.ipython/profile_pyspark/startup/
COPY --chown=h2o templates/pyspark/kernel.json ${KERNEL}

# Entry point
COPY templates/run.sh /run.sh

## Replace template variables with their values
RUN \
   sudo chmod a+x /run.sh \
   && sudo sed -i "s|(CONDA_HOME)|$CONDA_HOME|" /run.sh \
   && sed -i "s|(CONDA_HOME)|$CONDA_HOME|g" ${KERNEL} \
   && sed -i "s|(SPARKLING_WATER_HOME)|$SPARKLING_WATER_HOME|g" ${KERNEL} \
   && sed -i "s|(SPARKLING_WATER_BRANCH_NUMBER)|$SPARKLING_WATER_BRANCH_NUMBER|g" ${KERNEL} \
   && sed -i "s|(SPARKLING_WATER_BUILD_NUMBER)|$SPARKLING_WATER_BUILD_NUMBER|g" ${KERNEL} \
   && sed -i "s|(PY4J)|$PY4J|" /home/h2o/.ipython/profile_pyspark/startup/00-pyspark-setup.py

# https://support.rstudio.com/hc/en-us/articles/200552326-Running-RStudio-Server-with-a-Proxy
# https://nathan.vertile.com/blog/2017/12/07/run-jupyter-notebook-behind-a-nginx-reverse-proxy-subpath/
RUN \
  sed -i "s/#c.NotebookApp.base_url = '\/'/c.NotebookApp.base_url = '\/jupyter'/" /home/h2o/.jupyter/jupyter_notebook_config.py \
  && sed -i "s/#c.NotebookApp.allow_origin = ''/c.NotebookApp.allow_origin = '*'/" /home/h2o/.jupyter/jupyter_notebook_config.py \
  && echo "spark.ext.h2o.context.path=h2o" >> ${SPARK_HOME}/conf/spark-defaults.conf \
  && echo "spark.ui.proxyBase=/spark" >> ${SPARK_HOME}/conf/spark-defaults.conf

## Create link for ease of use in jupyter notebooks import command
RUN \
  bash -c "ln ${CONDA_HOME}/envs/h2o/lib/python${CONDA_PYTHON_H2O}/site-packages/h2o/backend/bin/h2o.jar ${BASE}" \
  && echo "java -ea -cp ${BASE}/h2o.jar water.H2OApp -port 54321 -log_level INFO -context_path h2o &" > ${BASE}/aquarium_startup \
  && chmod +x ${BASE}/aquarium_startup
#  \
#  && bash -c "sudo service nginx restart"
#
#######################################################################
## ADD CONTENT FOR INDIVIDUAL HANDS-ON SESSIONS HERE
#######################################################################
#
#COPY --chown=h2o contents/data data
#COPY --chown=h2o contents/h2o-3_hands_on h2o-3_hands_on
#COPY --chown=h2o contents/sparkling_water_hands_on sparkling_water_hands_on
#COPY --chown=h2o contents/patrick_hall_mli patrick_hall_mli
#
#######################################################################
#
## ----- RUN INFORMATION -----
#
#USER h2o
#WORKDIR /home/h2o
#ENV JAVA_HOME=/usr
#
#ENTRYPOINT ["/run.sh"]
#
#EXPOSE 54321
#EXPOSE 54327
#EXPOSE 8888
#EXPOSE 8787
#EXPOSE 4040
#