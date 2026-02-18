export NPM_CONFIG_PREFIX=~/.npm-global

# set PATH $HOME/.cargo/bin/ $PATH
#PATH

# Containerd
set -Ux PATH /usr/local/bin $PATH
export CONTAINERD_NAMESPACE=default

export ANDROID_HOME=$HOME/Android/Sdk
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk

export ROCM_PATH=/opt/rocm
export HSA_OVERRIDE_GFX_VERSION=11.0.0

export CHROME_EXECUTABLE=/usr/bin/brave

# # Golang environment variables
# export GOROOT=/usr/local/go
# export GOPATH=$HOME/go
#
# # Update PATH to include GOPATH and GOROOT binaries
# export PATH=$GOPATH/bin:$GOROOT/bin:$HOME/.local/bin:$PATH

