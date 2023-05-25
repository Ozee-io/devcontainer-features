#!/bin/bash

# Get application, version, and plugins from input
APP=$1
VERSION=$2
PLUGINS=($3)

# Define the corresponding app name and category in the download URL
declare -A URL_APP_NAMES=(
    ["IntelliJCommunity"]="ideaIC"
    ["IntelliJProfessional"]="ideaIU"
    ["PyCharmCommunity"]="pycharm-community"
    ["PyCharmProfessional"]="pycharm-professional"
    ["WebStorm"]="WebStorm"
    ["GoLand"]="GoLand"
    ["DataGrip"]="DataGrip"
    ["AndroidStudio"]="android-studio-ide"
)

declare -A URL_CATEGORIES=(
    ["IntelliJCommunity"]="idea"
    ["IntelliJProfessional"]="idea"
    ["PyCharmCommunity"]="pycharm"
    ["PyCharmProfessional"]="pycharm"
    ["WebStorm"]="WebStorm"
    ["GoLand"]="GoLand"
    ["DataGrip"]="DataGrip"
    ["AndroidStudio"]="android-studio-ide"
)

URL_APP_NAME=${URL_APP_NAMES[$APP]}
URL_CATEGORY=${URL_CATEGORIES[$APP]}

if [ -z "$URL_APP_NAME" ]; then
    echo "Unsupported application. Please select from the provided options."
    exit 1
fi

# Define installation directory and download URL
INSTALL_DIR="/opt/$APP"
DOWNLOAD_URL="https://download.jetbrains.com/$URL_CATEGORY/$URL_APP_NAME-$VERSION.tar.gz"


# Check if the application is installed and install if necessary
if [ ! -d "$INSTALL_DIR" ]; then
    echo "$APP not found. Installing..."
    wget -qO- $DOWNLOAD_URL | tar xvz -C $INSTALL_DIR
else
    echo "$APP is already installed."
fi

# JetBrains IDE plugins directory
IDEA_PLUGINS_DIR="$INSTALL_DIR/config/plugins"

# Install plugins only if the PLUGINS array is not empty
if [ ${#PLUGINS[@]} -ne 0 ]; then
    for id in "${PLUGINS[@]}"
    do
        # Use JetBrains API to get plugin info
        plugin_info=$(curl -s "https://plugins.jetbrains.com/plugins/list?pluginId=$id")

        # Extract the download URL and version of the latest version of the plugin
        latest_plugin=$(echo "$plugin_info" | grep -oPm1 "(?<=<idea-plugin downloads=\")[^<]*")
        download_url=$(echo "$latest_plugin" | grep -oP '(?<=url=").*?(?=")')
        version=$(echo "$latest_plugin" | grep -oP '(?<=version>).*?(?=</version)')

        # Download and install the plugin
        wget -q -P "$IDEA_PLUGINS_DIR" "$download_url"
    done
    echo "Installation of $APP version $VERSION and plugins completed."
else
    echo "Installation of $APP version $VERSION completed. No plugins to install."
fi
