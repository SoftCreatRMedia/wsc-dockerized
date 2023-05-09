#!/bin/bash

if [ ! "$(ls -A $1)" ]; then
    INSTALL_DIR="$1"
    WSC_VERSION="$2"
    TMP_DIR="$(mktemp -d)"
    
    cd "$TMP_DIR"
    curl -sL -o "WCF-$WSC_VERSION.tgz" "https://codeload.github.com/WoltLab/WCF/tar.gz/refs/heads/master"
    tar xfz "WCF-$WSC_VERSION.tgz"

    TMP_DIR="$TMP_DIR/WCF-$WSC_VERSION"

    mv "$TMP_DIR/wcfsetup/install.php" "$1"
    mv "$TMP_DIR/wcfsetup/test.php" "$1"

    pushd "$TMP_DIR/com.woltlab.wcf/templates"
    tar cf "$TMP_DIR/com.woltlab.wcf/templates.tar" *
    popd
    rm -rf "$TMP_DIR/com.woltlab.wcf/templates"

    pushd "$TMP_DIR/com.woltlab.wcf"
    tar cf "$TMP_DIR/wcfsetup/install/packages/com.woltlab.wcf.tar" *
    popd

    pushd "$TMP_DIR/wcfsetup"
    tar czf "$1/WCFSetup.tar.gz" *
    popd

    rm -rf "$TMP_DIR"

    chown -R "$(stat -c "%u:%g" .)" "$1"
    chmod -R 0777 "$1"
fi


php-fpm

exec "$@"
