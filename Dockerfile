FROM node:10-alpine

LABEL version="1.0.0"
LABEL repository="http://github.com/guahanweb/actions-test"
LABEL homepage="http://github.com/actions"
LABEL maintainer="Garth Henson <garth@guahanweb.com>"

LABEL com.github.actions.name="Node App Helper Actions"
LABEL com.github.actions.description="Provides some helper scripts to aid in basic Node.js app delivery"
LABEL com.github.actions.icon="settings"
LABEL com.github.actions.color="green"

# install additional dependencies
RUN apk --update add git openssh bash && \
    rm -rf /var/lib/apt/lists/* && \
    rm /var/cache/apk/*

# COPY LICENSE README.md /

COPY "helpers.sh" "/helpers.sh"
COPY "entrypoint.sh" "/entrypoint.sh"

ENTRYPOINT ["/entrypoint.sh"]
CMD ["help"]
