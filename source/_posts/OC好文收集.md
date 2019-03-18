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


render loop是一个可以最多每秒运行120次的过程，用来保证每帧刷新前需要渲染的内容都已经准备好。

这个过程有三个阶段，
先Update Constraints，再Layout，最后Display。

Update Constraints从叶节点view开始执行，直到window；
layoutSubviews则是反过来，从window开始，传递到最终的叶节点view；
最后是drawRect绘制，也是从window开始；
苹果在设计上为了减少布局的重复调用，分了这3个阶段，并提供了平行的类似功能的方法，比如updateConstraints和layoutSubviews，setNeedsUpdateConstraints和setNeedsLayout等

updateConstraints()在最后一行调用[super updateConstraints]，保证向父view传递
作者：fruitymoon
链接：https://www.jianshu.com/p/31960fdacbd6
来源：简书
简书著作权归作者所有，任何形式的转载都请联系作者获得授权并注明出处。

## instruments

https://developer.apple.com/videos/play/wwdc2018/410/

Advanced Debugging with Xcode and LLDB
https://developer.apple.com/videos/play/wwdc2018/412/

https://developer.apple.com/videos/wwdc2018


https://zsisme.gitbooks.io/ios-/content/chapter12/cpu-versus-gpu.html

https://blog.ibireme.com/2015/11/12/smooth_user_interfaces_for_ios/

http://www.cocoachina.com/ios/20151105/13927.html

https://www.bignerdranch.com/blog/inpecting-auto-layout-with-the-cocoa-layout-instrument/


https://blog.csdn.net/praylucky/article/details/8082260

https://www.cnblogs.com/czh-liyu/archive/2012/02/27/2370583.html

https://blog.csdn.net/zhoudaxia/article/details/8813247

http://www.doc88.com/p-112695786354.html