FROM openjdk:8-jdk

RUN apt-get update \
	&& apt-get install sudo \
	&& apt-get install -y --no-install-recommends apt-utils 

ARG jmeter_ver=5.0

RUN wget http://www.us.apache.org/dist/jmeter/binaries/apache-jmeter-${jmeter_ver}.tgz \
	&& echo Insalling JMeter version ${jmeter_ver} .. \
	&& tar -xzf apache-jmeter-${jmeter_ver}.tgz \
	&& rm apache-jmeter-${jmeter_ver}.tgz \
	&& mkdir /opt/jmeter \
	&& mv apache-jmeter-${jmeter_ver} /opt/jmeter 

	
	
ENV PATH /opt/jmeter/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV JMETER_HOME /opt/jmeter/apache-jmeter-5.0/bin

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
	

USER developer
ENV HOME /home/developer

CMD /opt/jmeter/apache-jmeter-5.0/bin/jmeter.sh

# docker run -ti --rm -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix mimi50/jmeter
# docker run -it --rm --name jmeter mimi50/jmeter /bin/bash
