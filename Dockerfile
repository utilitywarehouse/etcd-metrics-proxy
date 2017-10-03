FROM alpine:3.6

ADD . /go/src/app/

RUN set -x \
  && apk --no-cache add ca-certificates \
  && apk --no-cache add --virtual .build_deps \
    git \
    go \
    musl-dev \
  && export GOPATH=/go \
  && cd /go/src/app \
  && go get ./... \
  && go vet . \
  && go test -v -cover -p=1 . \
  && CGO_ENABLED=0 go build -a -ldflags '-s -extldflags "-static"' -tags netgo -installsuffix netgo -o /etcd-metrics-proxy . \
  && apk del .build_deps \
  && rm -rf $GOPATH

ENTRYPOINT [ "/etcd-metrics-proxy" ]
