FROM docker.packages.nuxeo.com/nuxeo/nuxeo

ARG CLID
ARG CONNECT_URL
ARG BUILDPLATFORM
ARG NAME=nuxeo
ARG VERSION
ARG BIN_NAME

# Create a folder named function
#RUN mkdir -p /home/app

# Wrapper/boot-strapper
WORKDIR /home/app

##RUN addgroup -S app && adduser -S -g app app

#COPY --chown=900:0 path/to/local-package-nodeps-*.zip $NUXEO_HOME/local-packages/local-package-nodeps.zip
#COPY --chown=900:0 path/to/local-package-*.zip $NUXEO_HOME/local-packages/local-package.zip

#COPY /path/to/my-configuration.properties /etc/nuxeo/conf.d/my-configuration.properties

# Copy packages
##COPY packages ./packages

# Copy package.json and install dependencies
#COPY ./package*.json ./
#COPY ./tsconfig.json ./
#COPY ./global.d.ts ./

#COPY nginx.conf /etc/nginx/nginx.conf

# Copy application source code
COPY . .

# Install a local package without its dependencies (`mp-install --nodeps`)
#RUN /install-packages.sh --offline $NUXEO_HOME/local-packages/local-package-nodeps.zip
# Install remote packages and a local package with its dependencies
#RUN /install-packages.sh --clid ${CLID} --connect-url ${CONNECT_URL} nuxeo-web-ui nuxeo-drive $NUXEO_HOME/local-packages/local-package.zip
RUN rm -rf $NUXEO_HOME/local-packages

# we need to be root to run yum commands
USER 0
# install RPM Fusion free repository
RUN yum -y localinstall --nogpgcheck https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-7.noarch.rpm
# install ffmpeg package
RUN yum -y install ffmpeg
# set back original user
USER root

VOLUME /var/lib/nuxeo
VOLUME /var/log/nuxeo
VOLUME /tmp

ENV PATH $NUXEO_HOME/bin:$PATH

# Set an UTF-8 LANG
ENV LANG en_US.utf8

# Service-Based Enviroment Variables
ENV FUNCTION_NAME="nuxeo"
ENV NODE_ENV="production"
ENV REST_PORT=3000

EXPOSE 8088
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nuxeoctl", "console", "npm", "start"]
