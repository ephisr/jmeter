# JMeter container

#### Jenkins to run JMeter headless (k8s):

> https://github.com/qazynx/jmeter/tree/master/yaml

#### JMeter GUI via docker run :

> docker run -ti --rm -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix mimi50/jmeter

#### Shell into JMeter container:

> docker run -it --rm --name jmeter mimi50/jmeter /bin/bash


