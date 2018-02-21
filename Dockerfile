FROM golang:1.9

# Force Go to use the cgo based DNS resolver. This is required to ensure DNS
# queries required to connect to linked containers succeed.
ENV GODEBUG netdns=cgo

# Install glide to manage vendor.
RUN go get -u github.com/Masterminds/glide

# Grab and install the latest version of lnd and all related dependencies.
RUN git clone https://github.com/lightningnetwork/lnd $GOPATH/src/github.com/lightningnetwork/lnd

# Make lnd folder default.
WORKDIR $GOPATH/src/github.com/lightningnetwork/lnd

# Patch to enable mainnet
COPY 0001-Enable-mainnet.patch .
RUN git apply 0001-Enable-mainnet.patch

# Install dependency and install/build lnd.
RUN glide install
RUN go install . ./cmd/...

EXPOSE 9735 8080

WORKDIR /lnd
COPY lnd.conf /lnd/lnd.conf
COPY bashrc /root/.bashrc
ENTRYPOINT ["/go/bin/lnd"]
