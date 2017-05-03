FROM openjdk:8-jdk

RUN apt-get update \
	&& apt-get install sudo \
	&& apt-get install -y --no-install-recommends apt-utils \
	&& apt-get install jq

ARG jmeter_ver=3.2

RUN wget http://www.us.apache.org/dist/jmeter/binaries/apache-jmeter-${jmeter_ver}.tgz \
	&& echo Insalling JMeter version ${jmeter_ver} .. \
	&& tar -xzf apache-jmeter-${jmeter_ver}.tgz \
	&& rm apache-jmeter-${jmeter_ver}.tgz \
	&& mv apache-jmeter-${jmeter_ver} /opt/jmeter \
	&& wget --content-disposition  https://jmeter-plugins.org/get/ \
	&& mv jmeter-plugins-manager*.jar /opt/jmeter/lib/ext/ \
	# https://jmeter-plugins.org/wiki/PluginsManagerAutomated/
	&& wget --content-disposition  http://search.maven.org/remotecontent?filepath=kg/apc/cmdrunner/2.0/cmdrunner-2.0.jar \
	&& mv cmdrunner-2.0.jar /opt/jmeter/lib/ \
	&& echo 1- Successfully installed the latest jmeter and plugins-manager  \
	&& cd /opt/jmeter/bin \
	&& mgr=$(find /opt/jmeter/lib/ext/jmeter-plugins-manager* -printf "%f\n") \
	&& java -cp /opt/jmeter/lib/ext/${mgr} org.jmeterplugins.repository.PluginManagerCMDInstaller \
	&& echo 2- Getting the list of jmeter plugins from https://jmeter-plugins.org/repo/ \
	&& echo This may take a moment.... \
	&& jmpl=$(curl -s https://jmeter-plugins.org/repo/ | jq '.[] | select(."id"=="jpgc-dbmon" | not )' | jq ."id" | tr '\n' ',' | sed 's/"//g') \
	&& sh PluginsManagerCMD.sh install ${jmpl} \
	&& echo 3- Successfully installed the jmeter plugins \
	#  change the jenkins server ip and port below
	&& wget --content-disposition https://build.cb.zynx.com:8080/jnlpJars/slave.jar \
	&& mv slave.jar /opt/jmeter/ \
	&& echo 4- downloaded the Jenkins slave.jar file to /opt/jmeter directory 
	
	
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
	&& chown ${uid}:${gid} -R /opt/jmeter

USER developer
ENV HOME /home/developer

CMD /opt/jmeter/bin/jmeter.sh

# docker run -ti --rm -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix mimi50/jmeter
# docker run -it --rm --name jmeter mimi50/jmeter /bin/bash
