ARG GO_VERSION

FROM golang:${GO_VERSION}-alpine AS base

WORKDIR /app

ARG USERNAME

COPY docker/certs/* /usr/local/share/ca-certificates/
RUN update-ca-certificates \
    && apk update \
    && addgroup -S ${USERNAME} \
    && adduser \
        -S ${USERNAME} \
        -G ${USERNAME} \
    && chown -R ${USERNAME}:${USERNAME} /var/log \
    && chown -R  ${USERNAME}:${USERNAME} /app

FROM base AS requirements

RUN apk add --update nodejs npm \
    && npm install -g npm \
    && chown -R ${USERNAME} /usr/local/lib/node_modules \
    && chown -R ${USERNAME} /usr/bin/ 

USER ${USERNAME}

ARG BUFFALO_VERSION
ARG REPOSITORY="github.com/gobuffalo/cli/cmd/buffalo@${BUFFALO_VERSION}"
ARG NODE_PATH="/home/${USERNAME}/.npm"
ENV PATH="${NODE_PATH}/bin:$PATH"

RUN go install ${REPOSITORY} \
    && npm config set prefix ${NODE_PATH}

FROM requirements AS builder

COPY src ./src

WORKDIR /app/src

RUN buffalo build -o /app/exec

FROM base AS production

COPY --from=builder /app/exec /app/exec

ENTRYPOINT [ "/app/exec" ]

FROM requirements AS development

USER root

RUN apk add git

USER ${USERNAME}

ENV TOOLS_PATH="/home/${USERNAME}/tools"
ENV PATH="${TOOLS_PATH}:${PATH}"

COPY --chown=${USERNAME}:${USERNAME} docker/tools /home/${USERNAME}/tools/