---
title: mysql性能优化学习摘要
comments: false
date: 2019-01-29 16:40:46
tags:
categories:
---

以上是摘要部分
<!--more-->

* 查看多核CPU命令
```
mpstat -P ALL  和  sar -P ALL 
```

* top命令经常用来监控Linux的系统状况，比如cpu、内存的使用.

> `top`进入基本视图, 默认进入top时，各进程是按照CPU的占用量来排序的
> 在top基本视图中，按键盘数字“1”，可监控每个逻辑CPU的状况
> 敲击键盘“b”（打开/关闭加亮效果）
