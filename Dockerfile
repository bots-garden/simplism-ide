FROM codercom/code-server:latest

USER root 

ARG GO_ARCH=${GO_ARCH}
ARG GO_VERSION=${GO_VERSION}
ARG TINYGO_ARCH=${TINYGO_ARCH}
ARG TINYGO_VERSION=${TINYGO_VERSION}
ARG EXTISM_ARCH=${EXTISM_ARCH}
ARG EXTISM_VERSION=${EXTISM_VERSION}
ARG SIMPLISM_DISTRO=${SIMPLISM_DISTRO}
ARG SIMPLISM_VERSION=${SIMPLISM_VERSION}

ARG NODE_MAJOR=${NODE_MAJOR}

ARG USER_NAME=${USER_NAME}

ARG DEBIAN_FRONTEND=noninteractive

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV LC_COLLATE=C
ENV LC_CTYPE=en_US.UTF-8

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

# ------------------------------------
# Set Environment Variables for Go
# ------------------------------------
#ENV GOROOT=/usr/local/go
#ENV GOPATH=$HOME/go
#ENV PATH=$GOPATH/bin:$GOROOT/bin:$PATH

# Set Go environment variables
ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH="/home/${USER_NAME}/go"
ENV GOROOT="/usr/local/go"

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
# Install NodeJS
# ------------------------------------
#RUN <<EOF
#NODE_MAJOR=${NODE_MAJOR}
#apt-get update && apt-get install -y ca-certificates curl gnupg
#curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
#echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
#apt-get update && apt-get install nodejs -y
#EOF

# -----------------------
# Install Extism JS PDK
# -----------------------
#RUN <<EOF
#export EXTISM_JS_VERSION="${EXTISM_JS_VERSION}"
#export EXTISM_JS_ARCH="${EXTISM_JS_ARCH}"
#export EXTISM_JS_OS="${EXTISM_JS_OS}"
#curl -L -O "https://github.com/extism/js-pdk/releases/download/v${EXTISM_JS_VERSION}/extism-js-${EXTISM_JS_ARCH}-${EXTISM_JS_OS}-v${EXTISM_JS_VERSION}.gz"
#gunzip extism-js*.gz
#chmod +x extism-js-*
#mv extism-js-* /usr/local/bin/extism-js
#EOF

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

# Create a regular user
RUN useradd -ms /bin/bash ${USER_NAME}

# Set the working directory
WORKDIR /home/${USER_NAME}

# Set the user as the owner of the working directory
RUN chown -R ${USER_NAME}:${USER_NAME} /home/${USER_NAME}

# Switch to the regular user
USER ${USER_NAME}


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


RUN <<EOF
go version
go install -v golang.org/x/tools/gopls@latest
go install -v github.com/ramya-rao-a/go-outline@latest
go install -v github.com/stamblerre/gocode@v1.0.0
EOF

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

# Command to run when starting the container
#CMD ["/bin/bash"]


