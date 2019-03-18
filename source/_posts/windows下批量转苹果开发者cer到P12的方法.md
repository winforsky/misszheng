---
title: windows下批量转苹果开发者cer到P12的方法
comments: false
date: 2019-03-18 18:50:20
tags:
categories:
---

某公司需要批量生成推送证书，并提交对应推送证书的P12文件到第三方平台，如极光等。
手动从Mac上导出，1个、2个还好，多了就费时又费力了。
现在提供自动转的方法，在Windows下即可转。
<!--more-->

# 背景

某公司需要批量生成推送证书，并提交对应推送证书的P12文件到第三方平台，如极光等。
手动从Mac上导出，1个、2个还好，多了就费时又费力了。
现在提供自动转的方法，在Windows下即可转。

## 需要的工具

windows下对应的OpenSSL。

## bat脚本

windows下保存为bat脚本，双击执行即可。

```shell
@echo off
cd C:\OpenSSL-Win64\bin\
set RANDFILE=.rnd
set OPENSSL_CONF=C:\OpenSSL-Win64\bin\openssl.cfg

rem 指定存放文件的目录
set FolderName=%cd%\ConverToP12\MyCertificates
for /f "delims=\" %%a in ('dir /b /a-d /o-d "%FolderName%\*.cer"') do (
  openssl x509 -in ConverToP12/MyCertificates/%%~na.cer -inform DER -out ConverToP12/MyPEMS/%%~na.pem -outform PEM
  openssl pkcs12 -export -inkey ConverToP12/private.key -in ConverToP12/MyPEMS/%%~na.pem -out ConverToP12/MyP12Files/%%~na.p12 -password pass:ios123456
)
```

注意这里的`pass:ios123456`，这将是你导入Mac或提交第三方平台时需要输入的密码

## 完整使用流程 包含生成依赖的私钥private.key

3.1、首先在钥匙串中导出一个正在使用的证书的P12文件，这里是xxx-dist-ios123456.p12。

3.2、通过下面的命令输出对应的PEM文件，这里是xxx-dist-ios123456.pem。

```shell
openssl pkcs12 -in xxx-dist-ios123456.p12 -out xxx-dist-ios123456.pem -nodes
```

3.3、打开刚刚生成的PEM文件，上面是公钥，下面是私钥
//上面是公钥

```js
Bag Attributes
    friendlyName: iPhone Distribution: Xxx Software Technology Co., Ltd.
    localKeyID: 38 9A 06 F5 88 89 A7 45 4D 62 D3 FB 13 F1 69 68 39 D4 DB EF 
```

//下面是私钥

```js
Bag Attributes
    friendlyName: [申请苹果开发者的证书的机器上的developer]
    localKeyID: 38 9A 06 F5 88 89 A7 45 4D 62 D3 FB 13 F1 69 68 39 D4 DB EF 
Key Attributes: <No Attributes>
```

3.4、拷贝私钥到private.key中即可。

3.5、将从apple develop上面下载下来的cer证书放置到MyCertificates目录中。

3.6、到外面双击执行MyP12.bat即可在MyP12Files目录中得到对应的P12文件。

3.7、将生成的P12文件导入到MAC上进行校验，看看是否可用。