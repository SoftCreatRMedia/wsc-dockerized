#!/bin/bash

if [ ! "$(ls -A "$1")" ]; then
    # Define the installation directory and reference/version
    INSTALL_DIR="$1"
    TMP_DIR="$(mktemp -d)"
    REF="$2"
    
    # If the reference is 6.2, set it to master
    [ "$REF" == "6.2" ] && REF="master"

    cd "$TMP_DIR"

    # Determine the download URL based on the REF value
    if [[ "$REF" == "master" ]] || [[ "$REF" == "main" ]]; then
        DOWNLOAD_URL="https://codeload.github.com/WoltLab/WCF/tar.gz/refs/heads/$REF"
    elif [[ "$REF" =~ ^[0-9]+\.[0-9]+\.[0-9]+(_(Alpha|Beta|RC|dev)_[0-9]+)?$ ]]; then
        DOWNLOAD_URL="https://codeload.github.com/WoltLab/WCF/tar.gz/refs/tags/$REF"
    elif [[ "$REF" =~ ^[0-9]+\.[0-9]+$ ]]; then
        DOWNLOAD_URL="https://codeload.github.com/WoltLab/WCF/tar.gz/refs/heads/$REF"
    else
        echo "Unknown version '$REF'" >> "$INSTALL_DIR/setup.log"
        exit 1
    fi

	echo "Downloading WSC '$REF' from $DOWNLOAD_URL, please wait..."

    # Download and extract WSC
    curl -sL -o "WCF-$REF.tgz" "$DOWNLOAD_URL" || { echo "Download failed"; exit 1; }
    tar xfz "WCF-$REF.tgz" || { echo "Extraction failed"; exit 1; }

    # Create tarballs required for the installation process
    tar xfz "WCF-$REF.tgz"
    rm -f "WCF-$REF.tgz"
    TMP_DIR="$TMP_DIR/WCF-$REF"

    # Modify test.php to link to dev install
    sed -i 's|href="install.php"|href="install.php?dev=1"|g' "$TMP_DIR/wcfsetup/test.php"

    mv -t "$INSTALL_DIR" "$TMP_DIR/wcfsetup/install.php" "$TMP_DIR/wcfsetup/test.php"

    pushd "$TMP_DIR/com.woltlab.wcf/templates"
    tar cf "$TMP_DIR/com.woltlab.wcf/templates.tar" *
    popd
    rm -rf "$TMP_DIR/com.woltlab.wcf/templates"

    pushd "$TMP_DIR/com.woltlab.wcf"
    tar cf "$TMP_DIR/wcfsetup/install/packages/com.woltlab.wcf.tar" *
    popd

    pushd "$TMP_DIR/wcfsetup"
    tar czf "$INSTALL_DIR/WCFSetup.tar.gz" *
    popd

    # Cleanup
    rm -rf "$TMP_DIR"

    # Set permissions
    chown -R "$(stat -c "%u:%g" .)" "$INSTALL_DIR"
    chmod -R 0777 "$INSTALL_DIR"
fi

# Start PHP-FPM
php-fpm

# Execute any additional commands passed to the script
exec "$@"
