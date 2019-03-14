---
title: OC好文收集
comments: false
date: 2019-02-11 10:23:41
tags:
categories:
---

以上是摘要部分
<!--more-->

# OC基础知识

* assign vs weak
* __block vs __weak
* runtime
* [结合 category 工作原理分析 OC2.0 中的 runtime](http://ios.jobbole.com/87623/)

# UIKit基础知识

* loadView
* viewWillLayoutSubView
* UIView
* CALayer
* drawRect
* +(void)load;
* +(void)initialize
* [iOS触摸事件传递响应之被忽视的手势识别器工作原理](https://www.jianshu.com/p/8dca02b4687e)

## 界面性能优化

* [iOS 保持界面流畅的技巧](https://blog.ibireme.com/2015/11/12/smooth_user_interfaces_for_ios/)
* [Designing for iOS: Graphics &amp; Performance](https://thoughtbot.com/blog/designing-for-ios-graphics-performance)
* [make UITableViews faster and smooth](https://medium.com/ios-os-x-development/perfect-smooth-scrolling-in-uitableviews-fd609d5275a5)

## 内存对齐

* 64位、32位的结构体会内存对齐，8的倍数进行对齐。
* [数据结构的内存分配](http://www.catb.org/esr/structure-packing/)

## 圆角的处理

* 直接使用cornerRadius实现
* 需要额外设置masksToBounds时需要考虑圆角视图的数量，少时可以，多时继续向下看
* UIImageView可以通过异步开线程生成圆角图片赋值，其它UIView可以通过插入UIImageView并使用CoreGraphics画圆角图得到，此时UIView的背景图片不再使用，而是在生成图片过程中配置填充色。

## [__block的实现](https://www.jianshu.com/p/ee9756f3d5f6)

1.普通非对象的变量
ARC环境下，一旦Block赋值就会触发copy，__block就会copy到堆上，Block也是__NSMallocBlock。ARC环境下也是存在__NSStackBlock的时候，这种情况下，__block就在栈上。
MRC环境下，只有copy，__block才会被复制到堆上，否则，__block一直都在栈上，block也只是__NSStackBlock，这个时候__forwarding指针就只指向自己了。

2.对象的变量
在MRC环境下，__block根本不会对指针所指向的对象执行copy操作，而只是把指针进行的复制。
而在ARC环境下，对于声明为__block的外部对象，在block内部会进行retain，以至于在block环境内能安全的引用外部对象，所以才会产生循环引用的问题！
