FROM step2:18.04
MAINTAINER David Whiting <david.whiting@h2o.ai>

# Create jupyter notebook with h2o login token
RUN \
  ${CONDA_HOME}/envs/h2o/bin/jupyter notebook --generate-config && \
  sed -i "s/#c.NotebookApp.token = '<generated>'/c.NotebookApp.token = 'h2o'/" /home/h2o/.jupyter/jupyter_notebook_config.py

# Create pyspark  
RUN \
  ${CONDA_HOME}/envs/pysparkling/bin/ipython profile create pyspark 

COPY --chown=h2o conf/pyspark/00-pyspark-setup.py /home/h2o/.ipython/profile_pyspark/startup/
COPY --chown=h2o conf/pyspark/kernel.json ${CONDA_HOME}/envs/h2o/share/jupyter/kernels/pyspark/

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