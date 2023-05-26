#!/bin/bash
set -e 

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

# Checks if packages are installed and installs them if not
check_packages() {
    if ! dpkg -s "$@" > /dev/null 2>&1; then
        if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
            echo "Running apt-get update..."
            apt-get update -y
        fi
        apt-get -y install --no-install-recommends "$@"
    fi
}

export DEBIAN_FRONTEND=noninteractive

check_packages curl ca-certificates gnupg2 dirmngr unzip libxml2-utils

URL_APP_NAME=${URL_APP_NAMES[$APP]}
URL_CATEGORY=${URL_CATEGORIES[$APP]}

if [ -z "$URL_APP_NAME" ]; then
    echo "Unsupported application $APP. Please select from the provided options."
    for key in "${!URL_APP_NAMES[@]}"; do
        echo "- $key"
    done
    exit 1
fi

# Define installation directory and download URL
INSTALL_DIR="/opt/$APP"
DOWNLOAD_URL="https://download.jetbrains.com/$URL_CATEGORY/$URL_APP_NAME-$VERSION.tar.gz"


# Check if the application is installed and install if necessary
if [ ! -d "$INSTALL_DIR" ]; then
    echo "$APP not found. Installing..."
    mkdir -p "$INSTALL_DIR"
    curl -L $DOWNLOAD_URL | tar xvz -C $INSTALL_DIR
else
    echo "$APP is already installed."
    exit 1
fi

# JetBrains IDE plugins directory
echo "Installing Plugins Diretory"
IDEA_PLUGINS_DIR="$INSTALL_DIR/config/plugins"
mkdir -p "$IDEA_PLUGINS_DIR"

echo "Installing Plugins"

# Convert the comma-separated string to an array
IFS=',' read -r -a PLUGINS_ARRAY <<< "$PLUGINS"

# Install plugins only if the PLUGINS array is not empty
if [ ${#PLUGINS_ARRAY[@]} -ne 0 ]; then
    for id in "${PLUGINS_ARRAY[@]}"
    do
        # API call to get plugin details
        echo "Installing Plugin ID: $id"
        response=$(curl -s "https://plugins.jetbrains.com/plugins/list?pluginId=$id")

        # Parsing XML response to get the version and download URL of the latest version
        version=$(echo $response | xmllint --xpath 'string((//idea-plugin)[1]/version)' -)
        download_url=$(echo $response | xmllint --xpath 'string((//idea-plugin)[1]/@url)' -)

        # Forming the download URL
        jarUrl="https://plugins.jetbrains.com/plugin/download?rel=true&updateId=$version"

        # Install the Plugin
        echo "Downloading Plugin ID: $id, Version: $version"

        # Downloading .jar file into the plugins directory
        curl -L -o "$IDEA_PLUGINS_DIR/$id.jar" "$download_url"

    done
    echo "Installation of $APP version $VERSION and plugins completed."
else
    echo "No plugins to install."
fi

cat > /usr/local/bin/jetbrains-ide-path \
<< EOF
#!/bin/sh
echo "${INSTALL_DIR}"
EOF

chmod +x /usr/local/bin/jetbrains-ide-path