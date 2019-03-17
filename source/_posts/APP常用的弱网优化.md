---
title: APP常用的弱网优化
comments: false
date: 2019-03-05 17:34:48
tags:
categories:
---
网络反馈快慢是影响用户体验的重要因素之一，能够快速响应用户的请求并返回需要的信息能够让用户更好的留存，毕竟现在要获得一个用户的成本已经很高了。
本文虽然标题是弱网优化，其实也是一个APP优化的常规手段之一。

<!--more-->

APP的弱网优化

## 定位查找慢的原因
在弱网络的情况下看看是哪里慢。
* 服务器地址的DNS解析速度
* UIWebView加载网页资源，html、js、css、图片资源都有可能。
* API网络请求，大部分APP的重点是通过API获取数据，如果API反应慢，则整个慢。

## 解决方法
* 
* UIWebView使用到的资源进行压缩，考虑通过CDN进行分发
* API网络请求响应慢时需进一步分析服务器端什么原因，考虑数据库语句优化\数据的压缩等
* 降低APP端数据处理能力，服务器端能做的尽量服务器端做掉
* 图片可以考虑webp格式，并根据不同场景需要在不同网络的情况下使用不同大小，目前很多云存储平台提供这个能力，比如七牛云
* 优化APP端的交互，比如先显示文本，再显示图片，虚造快速响应的架势
* 优化APP端的交互，比如UIWebView显示加载进度，从50%开始，一致卡在80%，直到网络请求完全完成，比如UC浏览器
* 优化APP端的交互，比如APP端根据不同场景需要使用不同的缓存技术，加载数据时先用缓存，数据增量更新
* 优化APP端的设计，比如APP在不同网络（2G、3G、4G、5G）下设置不同的超时时间。


runloop 学习资料
* [iOS RunLoop 编程手册](https://www.jianshu.com/p/4c38d16a29f1/)
* [解密 Runloop](http://mrpeak.cn/blog/ios-runloop/)

* [Runloop 源码 Objective-C 版本](https://opensource.apple.com/source/CF/CF-635.19/CFRunLoop.c.auto.html)

* [Runloop 源码最新的 Swift 版本](https://github.com/apple/swift-corelibs-foundation/blob/master/CoreFoundation/RunLoop.subproj/CFRunLoop.c)

* [mach_msg是系统内核在某个 port 收发消息所使用的函数](http://web.mit.edu/darwin/src/modules/xnu/osfmk/man/mach_msg.html)

可以简单的将 mach_msg 理解为多进程之间的一种通信机制，不同的进程可以使用同一个消息队列来交流数据，当使用 mach_msg 从消息队列里读取 msg 时，可以在参数中 timeout 值，在 timeout 之前如果没有读到 msg，当前线程会一直处于休眠状态。这也是 runloop 在没有任务可执行的时候，能够进入 sleep 状态的原因。
