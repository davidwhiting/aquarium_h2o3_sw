FROM whiting/h2o-sw-base:latest
LABEL maintainer="David Whiting <david.whiting@h2o.ai>"

## some ARG in base need to be made ENV

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
COPY --chown=h2o templates/aquarium_startup bin/aquarium_startup
RUN \
  bash -c "ln ${CONDA_HOME}/envs/h2o/lib/python${CONDA_PYTHON_H2O}/site-packages/h2o/backend/bin/h2o.jar ${BASE}" \
  && chmod +x ${BASE}/aquarium_startup
#  \

#RUN \
#  mkdir /home/h2o/zeppelin 
#\
#  && bash -c "sudo /usr/sbin/service nginx reload" \
#  && bash -c "sudo /usr/sbin/service nginx restart" 

######################################################################
# ADD CONTENT FOR INDIVIDUAL HANDS-ON SESSIONS HERE
######################################################################

COPY --chown=h2o contents/data data
COPY --chown=h2o contents/coursework coursework
COPY --chown=h2o contents/h2o-3_hands_on h2o-3_hands_on
COPY --chown=h2o contents/sparkling_water_hands_on sparkling_water_hands_on
COPY --chown=h2o contents/patrick_hall_mli patrick_hall_mli
COPY --chown=h2o contents/xai_guidelines xai_guidelines

#####################################################################

# ----- RUN INFORMATION -----

USER h2o
WORKDIR /home/h2o
ENV JAVA_HOME=/usr

ENTRYPOINT ["/run.sh"]

EXPOSE 54321
EXPOSE 54327
EXPOSE 8888
EXPOSE 8787
EXPOSE 8080
EXPOSE 4040
