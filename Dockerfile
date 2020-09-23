FROM adoptopenjdk/openjdk8:alpine

# Configuration variables.
ENV SOFT		crucible
#ENV SOFTSUB		core
ENV OPENJDKV		8
ENV CRUCIBLE_VERSION	4.8.2
ENV CRUCIBLE_HOME	/var/atlassian/${SOFT}
ENV CRUCIBLE_INSTALL	/opt/atlassian/${SOFT}
ENV SOFT_HOME		${CRUCIBLE_HOME}
ENV SOFT_INSTALL	${CRUCIBLE_INSTALL}
ENV SOFT_VERSION	${CRUCIBLE_VERSION}
RUN apk update && apk upgrade && \
    apk add --no-cache bash git openssh
# download option
RUN apk add --no-cache curl bash && \
	curl -s https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20SCRIPT%20AUTO/option.sh -o /option.sh && \
	chmod 755 /option.sh

# copyright and timezone
RUN curl -s https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20SCRIPT%20AUTO/copyright.sh | bash

# install
RUN curl -s https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20Atlassian/${SOFT}_install.sh | bash

# Use the default unprivileged account. This could be considered bad practice
# on systems where multiple processes end up being executed by 'daemon' but
# here we only ever run one process anyway.
USER daemon:daemon

# Expose default HTTP connector port.
EXPOSE 8060

# Set volume mount points for installation and home directory. Changes to the
# home directory needs to be persisted as well as parts of the installation
# directory due to eg. logs.
VOLUME ["${SOFT_HOME}", "${SOFT_INSTALL}/logs"]

# Set the default working directory as the installation directory.
WORKDIR ${SOFT_HOME}

ENTRYPOINT ["/docker-entrypoint.sh"]

# Run Atlassian as a foreground process by default.
CMD ["/opt/atlassian/crucible/bin/run.sh", "-fg"]
