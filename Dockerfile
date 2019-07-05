FROM whiting/h2o-sw-prefix
MAINTAINER David Whiting <david.whiting@h2o.ai>

## To add later
#COPY --chown=h2o conf/pyspark/kernel-template.json ${CONDA_HOME}/envs/h2o/share/jupyter/kernels/pyspark/kernel.json
#RUN \
#  sed -i 's/(CONDA_HOME)/'"${CONDA_HOME}"'/' ${CONDA_HOME}/envs/h2o/share/jupyter/kernels/pyspark/kernel.json && \
#  sed -i 's/(SPARKLING_WATER_HOME)/'"${SPARKLING_WATER_HOME}"'/' ${CONDA_HOME}/envs/h2o/share/jupyter/kernels/pyspark/kernel.json && \
#  sed -i 's/(SPARKLING_WATER_BRANCH_NUMBER)/'"${SPARKLING_WATER_BRANCH_NUMBER}"'/g' ${CONDA_HOME}/envs/h2o/share/jupyter/kernels/pyspark/kernel.json && \
#  sed -i 's/(SPARKLING_WATER_BUILD_NUMBER)/'"${SPARKLING_WATER_BUILD_NUMBER}"'/g' ${CONDA_HOME}/envs/h2o/share/jupyter/kernels/pyspark/kernel.json

# sed 's/xxx/'"$VARIABLE"'/'

######################################################################
# ADD CONTENT FOR INDIVIDUAL HANDS-ON SESSIONS HERE
######################################################################

COPY --chown=h2o contents/data data
COPY --chown=h2o contents/h2o-3_hands_on h2o-3_hands_on
COPY --chown=h2o contents/sparkling_water_hands_on sparkling_water_hands_on

######################################################################

# ----- RUN INFORMATION -----

USER h2o
WORKDIR /home/h2o
ENV JAVA_HOME=/usr

# Entry point
COPY run.sh /run.sh
RUN \
  sudo chmod a+x /run.sh

ENTRYPOINT ["/run.sh"]

EXPOSE 54321
EXPOSE 54327
EXPOSE 8888
EXPOSE 8787
EXPOSE 4040