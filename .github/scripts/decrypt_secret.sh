#!/bin/sh

# 解密文件
# --批处理以防止交互式命令
# --是以假定问题的回答是“是”
gpg --quiet --batch --yes --decrypt --passphrase="$LARGE_SECRET_PASSPHRASE" \
--output $GITHUB_WORKSPACE/android/key.jks $GITHUB_WORKSPACE/android/key.jks.gpg

gpg --quiet --batch --yes --decrypt --passphrase="$LARGE_SECRET_PASSPHRASE" \
--output $GITHUB_WORKSPACE/android/key.properties $GITHUB_WORKSPACE/android/key.properties.gpg
