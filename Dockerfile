# Pull base image needed for JMeter.

FROM openjdk:8-jdk

# Install, updates.

RUN apt-get update \
	&& apt-get install -y sudo \
	&& apt-get install -y --no-install-recommends apt-utils \
	&& apt-get install -y jq

ARG jmeter_ver=5.0
# ARG plugins="jpgc-sense","jpgc-webdriver","jpgc-standard","jpgc-graphs-basic","jpgc-graphs-additional","jpgc-perfmon","jpgc-casutg"

RUN wget http://www.us.apache.org/dist/jmeter/binaries/apache-jmeter-${jmeter_ver}.tgz \
	&& echo Insalling JMeter version ${jmeter_ver} .. \
	&& tar -xzf apache-jmeter-${jmeter_ver}.tgz \
	&& echo Successfully unzipped \
	&& rm apache-jmeter-${jmeter_ver}.tgz \
	&& echo Successfully removed tgz \
	&& mkdir -p /opt/jmeter \
	&& mv apache-jmeter-${jmeter_ver} jmeter \
	&& mv jmeter /opt \
	&& wget --content-disposition  https://jmeter-plugins.org/get/ \
	&& mv jmeter-plugins-manager*.jar /opt/jmeter/lib/ext/ \
	&& echo Successfully moved plugins-manager \
	# https://jmeter-plugins.org/wiki/PluginsManagerAutomated/ -
	&& wget --content-disposition  http://search.maven.org/remotecontent?filepath=kg/apc/cmdrunner/2.2/cmdrunner-2.2.jar \
	&& echo Successfully downloaded cmdrunner \
	&& mv cmdrunner-2.2.jar /opt/jmeter/lib/ \
	&& echo Successfully moved cmdrunner to lib directory \
	&& echo 1- Successfully installed the latest jmeter and plugins-manager \
	&& cd /opt/jmeter/bin \
	&& mgr=$(find /opt/jmeter/lib/ext/jmeter-plugins-manager* -printf "%f\n") \
	&& java -cp /opt/jmeter/lib/ext/${mgr} org.jmeterplugins.repository.PluginManagerCMDInstaller \
	&& echo 2- Getting the list of jmeter plugins from https://jmeter-plugins.org/repo/ \
	&& echo This may take a moment.... \
	&& jmpl=$(curl -s https://jmeter-plugins.org/repo/ | jq '.[] | select(."id" | contains("jpgc-sense","jpgc-webdriver","jpgc-standard","jpgc-graphs-basic","jpgc-graphs-additional","jpgc-perfmon","jpgc-casutg"))' | jq ."id" | tr '\n' ',' | sed 's/"//g' | sed s'/.$//') \
	&& echo ${jmpl} \
	&& sh PluginsManagerCMD.sh install ${jmpl} \
	&& echo 3- Successfully installed the jmeter plugins
	#  change the jenkins server ip and port below
	# && wget --content-disposition https://jenkinsURL.com:8080/jnlpJars/slave.jar \
	# && mv slave.jar /opt/jmeter/ \
	# && echo 4- downloaded the Jenkins slave.jar file to /opt/jmeter directory


ENV PATH /opt/jmeter/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV JMETER_HOME /opt/jmeter/bin

# Replace 1000 with your user / group id
RUN export uid=1000 gid=1000 \
	&& mkdir -p /home/developer \
	&& mkdir -p /etc/sudoers.d \
	&& echo "developer:x:${uid}:${gid}:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd \
	&& echo "developer:x:${uid}:" >> /etc/group \
	&& echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer \
	&& chmod 0440 /etc/sudoers.d/developer \
	&& chown ${uid}:${gid} -R /home/developer \
	&& chown ${uid}:${gid} -R /opt/jmeter \
	&& chown ${uid}:${gid} -R /var


# Set environment variables:

USER developer
ENV HOME /home/developer

# Define working directory:

WORKDIR /home/developer

# Define default command:

CMD /opt/jmeter/bin/jmeter.sh


# README:

# To build the JMeter container:
# Copy this Dockerfile and place it in a directory
# Install Docker for your OS
# Build the image:
# Docker build -t jmeter .


# To run with GUI (doesn't work with macOS see https://sourabhbajaj.com/blog/2017/02/07/gui-applications-docker-mac/)

# docker run -ti --rm -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix jmeter

# Run container with jmeter headless:

# docker run -it --rm  --name jmeter -v /Users/${user}/jmeter/qppar/:/home/developer  jmeter /bin/bash

# Run the jmx Test plans:

# jmeter -n -t 3875b.jmx -l results.jtl
