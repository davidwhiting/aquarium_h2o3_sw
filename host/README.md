
# What is this directory?

Labs run in a docker environment that is contained on an Ubuntu linux host.
The files in this directory are some of the configuration files that live on the host for the docker image to run properly.


## Services configured inside the docker image

* Rstudio
* Jupyter
* H2O-3
* Spark (and Sparkling Water)


## Host type

The current tested host environment for the training docker image is the Ubuntu 16.04 AWS AMI.


## Services configured on the host

### nginx

In some corporate environments unusual port numbers are blocked by firewalls.
As a result, it is convenient to have all the services inside the docker image be reachable off of port 80 (http).
(We have found port 80 to typically not be blocked by firewalls.)

We run an nginx reverse proxy on the Ubuntu host on port 80 to accomplish this.

Instructions:

```
[copy etc/nginx/sites-enabled/training to ubuntu@x.y.z.w:training]

ssh ubuntu@x.y.z.w
sudo apt-get update
sudo apt-get install nginx
sudo rm -f /etc/nginx/sites-available/default
sudo mv training /etc/nginx/sites-available
sudo ln -s /etc/nginx/sites-available/training /etc/nginx/sites-enabled/training
sudo systemctl restart nginx
```

