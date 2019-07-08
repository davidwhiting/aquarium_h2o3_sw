import os
import sys
spark_home = os.environ.get('SPARK_HOME', None)
if not spark_home:
    raise ValueError('SPARK_HOME environment variable is not set')
sys.path.insert(0, os.path.join(spark_home, 'python'))
# PY4J defined in Dockerfile (just in case version numbers changed)
sys.path.insert(0, os.path.join(spark_home, 'python/lib/(PY4J)'))
exec(open(os.path.join(spark_home, 'python/pyspark/shell.py')).read())
