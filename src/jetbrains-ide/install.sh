#!/bin/bash
set -e 

# Define the corresponding app name and category in the download URL
declare -A URL_APP_NAMES=(
    ["GoLand"]="goland"
    ["IntelliJProfessional"]="ideaIU"
    ["PhpStorm"]="PhpStorm"
    ["PyCharmProfessional"]="pycharm-professional"
    ["Rider"]="JetBrains.Rider"
    ["RubyMine"]="RubyMine"
    ["WebStorm"]="WebStorm"
)

declare -A URL_CATEGORIES=(
    ["GoLand"]="go"
    ["IntelliJProfessional"]="idea"
    ["PhpStorm"]="webide"
    ["PyCharmProfessional"]="python"
    ["Rider"]="rider"
    ["RubyMine"]="ruby"
    ["WebStorm"]="webstorm"
)

# Checks if packages are installed and installs them if not
check_packages() {
    if ! dpkg -s "$@" >/dev/null 2>&1; then
        if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
            echo "Running apt-get update..."
            apt-get update -y
        fi
        apt-get -y install --no-install-recommends "$@"
    fi
}

install_ide() {
    local app=$1
    local version=$2
    local plugins=$3

    local url_app_name=${URL_APP_NAMES[$app]}
    local url_category=${URL_CATEGORIES[$app]}
    
    if [ -z "$url_app_name" ]; then
        echo "Unsupported application $app. Please select from the provided options."
        for key in "${!URL_APP_NAMES[@]}"; do
            echo "- $key"
        done
        exit 1
    fi
    
    local install_dir="/opt/$app"
    local download_url="https://download.jetbrains.com/$url_category/$url_app_name-$version.tar.gz"
    
    if [ ! -d "$install_dir" ]; then
        echo "$app not found. Installing..."
        mkdir -p "$install_dir"
        echo "Downloading from $download_url" 
        curl -L $download_url | tar --strip-components=1 -xvz -C $install_dir
    else
        echo "$app is already installed."
        return
    fi
    
    install_plugins "$install_dir" "$plugins"
    
    cat > /usr/local/bin/jetbrains-ide-path \
    << EOF
#!/bin/sh
echo "${install_dir}"
EOF

    chmod +x /usr/local/bin/jetbrains-ide-path
}

install_plugins() {
    local install_dir=$1
    local plugins=$2

    local idea_plugins_dir="$install_dir/config/plugins"
    mkdir -p "$idea_plugins_dir"
    
    local IFS=',' 
    read -r -a plugins_array <<< "$plugins"
    
    if [ ${#plugins_array[@]} -ne 0 ]; then
        for id in "${plugins_array[@]}"; do
            install_plugin "$idea_plugins_dir" "$id"
        done
    else
        echo "No plugins to install."
    fi

    register_for_remote_development "$install_dir"
}

install_plugin() {
    local idea_plugins_dir=$1
    local id=$2

    echo "Installing Plugin ID: $id"
    local response=$(curl -s "https://plugins.jetbrains.com/plugins/list?pluginId=$id")
    
    local version=$(echo $response | xmllint --xpath 'string((//idea-plugin)[1]/version)' -)
    local download_url=$(echo $response | xmllint --xpath 'string((//idea-plugin)[1]/@url)' -)
    
    local jar_url="https://plugins.jetbrains.com/plugin/download?rel=true&updateId=$version"

    echo "Downloading Plugin ID: $id, Version: $version"
    curl -L -o "$idea_plugins_dir/$id.jar" "$jar_url"
}

register_for_remote_development() {
    local install_dir=$1

    echo "Registering IDE for remote devleopment: $id"
    sh $install_dir/bin/remote-dev-server.sh registerBackendLocationForGateway 
}

export DEBIAN_FRONTEND=noninteractive

check_packages curl ca-certificates gnupg2 dirmngr unzip libxml2-utils

install_ide $APP $VERSION $PLUGINS
