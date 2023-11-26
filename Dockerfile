FROM codercom/code-server:latest

ARG GO_ARCH=${GO_ARCH}
ARG GO_VERSION=${GO_VERSION}
ARG TINYGO_ARCH=${TINYGO_ARCH}
ARG TINYGO_VERSION=${TINYGO_VERSION}
ARG EXTISM_ARCH=${EXTISM_ARCH}
ARG EXTISM_VERSION=${EXTISM_VERSION}
ARG SIMPLISM_DISTRO=${SIMPLISM_DISTRO}
ARG SIMPLISM_VERSION=${SIMPLISM_VERSION}

ARG NODE_VERSION=${NODE_VERSION}
ARG NODE_DISTRO=${NODE_DISTRO}

USER root 

ARG DEBIAN_FRONTEND=noninteractive

# Update the system and install necessary tools
RUN <<EOF
apt-get update 
apt-get install -y curl wget git build-essential xz-utils bat exa software-properties-common htop openssh-server
ln -s /usr/bin/batcat /usr/bin/bat
apt-get -y install hey
EOF

# ------------------------------------
# Install Go
# ------------------------------------
RUN <<EOF
GO_ARCH="${GO_ARCH}"
GO_VERSION="${GO_VERSION}"

wget https://golang.org/dl/go${GO_VERSION}.linux-${GO_ARCH}.tar.gz
tar -xvf go${GO_VERSION}.linux-${GO_ARCH}.tar.gz
rm go${GO_VERSION}.linux-${GO_ARCH}.tar.gz
mv go /usr/local
EOF

#ENV PATH="/usr/bin/go/bin:$PATH"
# ------------------------------------
# Set Environment Variables for Go
# ------------------------------------
ENV GOROOT=/usr/local/go
ENV GOPATH=$HOME/go
ENV PATH=$GOPATH/bin:$GOROOT/bin:$PATH

RUN <<EOF
go version
go install -v golang.org/x/tools/gopls@latest
go install -v github.com/ramya-rao-a/go-outline@latest
go install -v github.com/stamblerre/gocode@v1.0.0
go install -v github.com/mgechev/revive@v1.3.2
EOF

# ------------------------------------
# Install TinyGo
# ------------------------------------
RUN <<EOF
TINYGO_ARCH="${TINYGO_ARCH}"
TINYGO_VERSION="${TINYGO_VERSION}"

wget https://github.com/tinygo-org/tinygo/releases/download/v${TINYGO_VERSION}/tinygo_${TINYGO_VERSION}_${TINYGO_ARCH}.deb
dpkg -i tinygo_${TINYGO_VERSION}_${TINYGO_ARCH}.deb
rm tinygo_${TINYGO_VERSION}_${TINYGO_ARCH}.deb
EOF

# ------------------------------------
# Install Wasmtime, Wazero, Wasmer CLI
# ------------------------------------
RUN <<EOF
curl https://wasmtime.dev/install.sh -sSf | bash

curl https://wazero.io/install.sh | sh
mv ./bin/wazero /usr/bin/wazero

curl https://get.wasmer.io -sSfL | sh

curl -sSf https://raw.githubusercontent.com/WasmEdge/WasmEdge/master/utils/install.sh | bash
EOF

# ------------------------------------
# Install Extism CLI
# ------------------------------------
RUN <<EOF
EXTISM_ARCH="${EXTISM_ARCH}"
EXTISM_VERSION="${EXTISM_VERSION}"

wget https://github.com/extism/cli/releases/download/v${EXTISM_VERSION}/extism-v${EXTISM_VERSION}-linux-${EXTISM_ARCH}.tar.gz

tar -xf extism-v${EXTISM_VERSION}-linux-${EXTISM_ARCH}.tar.gz -C /usr/bin
rm extism-v${EXTISM_VERSION}-linux-${EXTISM_ARCH}.tar.gz

extism --version
EOF

# ------------------------------------
# Install Rust + Wasm Toolchain
# ------------------------------------
RUN <<EOF
apt install -y pkg-config libssl-dev
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
export RUSTUP_HOME=~/.rustup
export CARGO_HOME=~/.cargo
export PATH=$PATH:$CARGO_HOME/bin
curl https://rustwasm.github.io/wasm-pack/installer/init.sh -sSf | sh 
rustup target add wasm32-wasi
EOF

# ------------------------------------
# Install Simplism
# ------------------------------------
RUN <<EOF
# 👀 https://github.com/bots-garden/simplism/releases
SIMPLISM_DISTRO="${SIMPLISM_DISTRO}" 
SIMPLISM_VERSION="${SIMPLISM_VERSION}"
wget https://github.com/bots-garden/simplism/releases/download/v${SIMPLISM_VERSION}/simplism_${SIMPLISM_DISTRO}.tar.gz -O simplism.tar.gz 
tar -xf simplism.tar.gz -C /usr/bin
rm simplism.tar.gz
simplism version
EOF

# ------------------------------------
# Install NodeJS
# ------------------------------------
RUN <<EOF
NODE_VERSION="${NODE_VERSION}"
NODE_DISTRO="${NODE_DISTRO}"
wget https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}-${NODE_DISTRO}.tar.xz
mkdir -p /usr/local/lib/nodejs
tar -xJvf node-$NODE_VERSION-$NODE_DISTRO.tar.xz -C /usr/local/lib/nodejs
rm node-$NODE_VERSION-$NODE_DISTRO.tar.xz
EOF

ENV VERSION="${NODE_VERSION}"
ENV DISTRO="${NODE_DISTRO}"
ENV NODE_PATH="/usr/local/lib/nodejs/node-$VERSION-$DISTRO"
ENV PATH="$NODE_PATH/bin:$PATH"

RUN echo "$NODE_PATH"
RUN echo "export PATH=${NODE_PATH}/bin:${PATH}" >> /root/.bashrc


# ------------------------------------
# Install Extensions
# ------------------------------------
RUN <<EOF
code-server --install-extension wesbos.theme-cobalt2
code-server --install-extension PKief.material-icon-theme
code-server --install-extension PKief.material-product-icons
code-server --install-extension golang.go
code-server --install-extension rust-lang.rust-analyzer
code-server --install-extension aaron-bond.better-comments
code-server --install-extension GitHub.github-vscode-theme
code-server --install-extension huytd.github-light-monochrome
EOF


