#!/bin/bash

if [ ! "$(ls -A "$1")" ]; then
    INSTALL_DIR="$1"
    TMP_DIR="$(mktemp -d)"

    REF="$2"
    if [[ "$REF" == "6.0" ]]; then
        REF="master"
    fi

    cd "$TMP_DIR"

    if [[ "$REF" =~ ^[0-9]+\.[0-9]+$ ]] || [[ "$REF" == "master" ]] || [[ "$REF" == "main" ]]; then
        curl -sL -o "WCF-$REF.tgz" "https://codeload.github.com/WoltLab/WCF/tar.gz/refs/heads/$REF"
    elif [[ "$REF" =~ ^[0-9]+\.[0-9]+\.[0-9]+(_(Alpha|Beta|RC|dev)_[0-9]+)?$ ]]; then
        curl -sL -o "WCF-$REF.tgz" "https://codeload.github.com/WoltLab/WCF/tar.gz/refs/tags/$REF"
    else
        echo "Don't know what to do with version '$REF'" >> "$INSTALL_DIR/setup.log"
        exit
    fi

    tar xfz "WCF-$REF.tgz"
    rm -f "WCF-$REF.tgz"
    TMP_DIR="$TMP_DIR/WCF-$REF"

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

    rm -rf "$TMP_DIR"

    chown -R "$(stat -c "%u:%g" .)" "$INSTALL_DIR"
    chmod -R 0777 "$INSTALL_DIR"
fi


php-fpm

exec "$@"
