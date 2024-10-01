
#!/bin/bash

# Detect the system architecture
ARCH=$(uname -m)

# Check if the user is root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (use sudo)."
    exit
fi

# Function to install on Debian-based systems
install_debian() {
    echo "Detected Debian-based system."
    echo "Updating package lists..."
    sudo apt update

    echo "Installing nodejs and npm..."
    sudo apt install -y npm nodejs

    echo "Installing Electron..."
    npm install electron

    echo "Cloning the repository..."
    git clone https://github.com/bluedinosaur139/catgpt.git

    cd catgpt || { echo "Failed to navigate to 'catgpt' directory."; exit 1; }

    echo "Fixing permissions..."
    sudo chown -R $USER:$USER ./

    echo "Installing dependencies..."
    npm install

    echo "Cleaning up previous builds..."
    sudo rm -rf ./CatGPT-linux-* || true

    echo "Building the app..."
    npm run build

    # Fix permissions on the build directory based on architecture
    if [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
        echo "Fixing permissions for ARM build..."
        sudo chmod -R 755 ./CatGPT-linux-arm64
    else
        echo "Fixing permissions for x64 build..."
        sudo chmod -R 755 ./CatGPT-linux-x64
    fi

    echo "CatGPT has been installed successfully."
}

# Function to install on Arch-based systems
install_arch() {
    echo "Detected Arch-based system."
    echo "Installing nodejs and npm..."
    sudo pacman -S --noconfirm nodejs npm

    echo "Installing Electron and Electron Packager..."
    npm install electron --save-dev
    npm install electron-packager --save-dev

    echo "Cloning the repository..."
    git clone https://github.com/bluedinosaur139/catgpt.git

    cd catgpt || { echo "Failed to navigate to 'catgpt' directory."; exit 1; }

    echo "Fixing permissions..."
    sudo chown -R $USER:$USER ./

    echo "Installing dependencies..."
    npm install

    echo "Cleaning up previous builds..."
    sudo rm -rf ./CatGPT-linux-x64 || true

    echo "Building the app..."
    npm run build

    # Fix permissions on the build directory
    sudo chmod -R 755 ./CatGPT-linux-x64

    echo "CatGPT has been installed successfully."
}

# Check for the type of Linux distribution
if [ -f /etc/debian_version ]; then
    install_debian
elif [ -f /etc/arch-release ]; then
    install_arch
else
    echo "Unsupported distribution. Only Debian and Arch-based systems are supported."
    exit 1
fi

# Final message
echo "Installation script completed."
