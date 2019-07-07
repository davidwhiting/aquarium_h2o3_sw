FROM whiting/h2o-sw-prefix
LABEL maintainer="David Whiting <david.whiting@h2o.ai>"

## Copy templates and substitute for versions in Dockerfile-prefix

ARG KERNEL.JSON=${CONDA_HOME}/envs/h2o/share/jupyter/kernels/pyspark/kernel.json

COPY --chown=h2o templates/pyspark/00-pyspark-setup.py /home/h2o/.ipython/profile_pyspark/startup/
COPY --chown=h2o templates/pyspark/kernel.json ${KERNEL.JSON}

# Entry point
COPY templates/run.sh /run.sh
## Replace variables with their values
RUN \
  sudo chmod a+x /run.sh \
  && sed "s|(CONDA_HOME)|$CONDA_HOME|" /run.sh \
  && sed "s|(CONDA_HOME)|$CONDA_HOME|g" ${KERNEL.JSON} \
  && sed "s|(SPARKLING_WATER_HOME)|$SPARKLING_WATER_HOME|g" ${KERNEL.JSON} \
  && sed "s|(SPARKLING_WATER_BRANCH_NUMBER)|$SPARKLING_WATER_BRANCH_NUMBER|g" ${KERNEL.JSON} \
  && sed "s|(SPARKLING_WATER_BUILD_NUMBER)|$SPARKLING_WATER_BUILD_NUMBER|g" ${KERNEL.JSON}

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

#ENTRYPOINT ["/run.sh"]

EXPOSE 54321
EXPOSE 54327
EXPOSE 8888
EXPOSE 8787
EXPOSE 4040