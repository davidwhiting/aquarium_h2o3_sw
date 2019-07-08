FROM whiting/h2o-sw-prefix
LABEL maintainer="David Whiting <david.whiting@h2o.ai>"

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

ENTRYPOINT ["/run.sh"]

EXPOSE 54321
EXPOSE 54327
EXPOSE 8888
EXPOSE 8787
EXPOSE 4040