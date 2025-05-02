#!/bin/bash

KEYSTORE_NAME="yunquetai.jks"
ALIAS_NAME="yunquetai"
PASSWORD="123456"
VALIDITY=10000

if [ -f "$KEYSTORE_NAME" ]; then
  echo "❗ 文件 $KEYSTORE_NAME 已存在，已取消生成。"
  exit 1
fi

keytool -genkey -v \
  -keystore $KEYSTORE_NAME \
  -keyalg RSA \
  -keysize 2048 \
  -validity $VALIDITY \
  -alias $ALIAS_NAME \
  -storepass $PASSWORD \
  -keypass $PASSWORD \
  -dname "CN=Liu ShiYing, OU=mobile, O=yunquetai, L=GuangZhou, S=GuangDong, C=CN"

echo "✅ 签名文件 $KEYSTORE_NAME 已生成。记得在 build.gradle 配置中使用它！"
