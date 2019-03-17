---
title: runloop的疑问
comments: false
date: 2019-03-09 11:39:23
tags:
categories:
---

以上是摘要部分
<!--more-->

run loop的场景是运用在需要和线程有更多交互的场合上，意义是让线程在忙碌的时候忙碌，不忙碌的时候休眠。

模式和事件的输入源不同，不可混谈。
模式不是事件的类型，不能用模式区单独匹配鼠标的按下事件或者单独匹配键盘事件，但可以用来舰艇一组不同的端口、暂时挂起定时器，也可以改变正则被监控的源和RunLoop的观察者。

# 模式

|模式|模式名称|模式描述|
|Default|NSDefaultRunLoopMode(Cocoa)|默认模式|
|Connection|NSConnectionReplyMode(Cocoa)|用于与NSConnection对象监视数据的来往|
|Modal|NSModalPanelRunLoopMode(Cocoa)|用来为模态面板表示事件意图|
|Event tracking|NSEventTrackingRunLoopMode(Cocoa)|用来严格区分事件的来源时是鼠标的拖拉还是其他用户交互事件|
|Common modes|NSRunLoopCommonModes(Cocoa)|这是一个可配置的组合，这个集合包含default、modal和EventTracking等|

# 事件的输入源
输入源异步向线程分发事件，事件的来源取决于输入源的类型，通常是2种类型的一种：基于端口的输入源监控应用程序的Mach端口、基于自定义的输入源监控自定义事件源。

# 定时器源
```
- (void)addTimer:(NSTimer *)timer forMode:(NSRunLoopMode)mode;
```
## 线程上使用定时器

> 一般情况都是在主线程上使用定时器，此时主线程的runloop默认是开启的。
> 定时器提供了一个可以直接将定时器添加到当前线程的run loop的NSDefaultRunLoopMode构造方法，所以很多时候什么都不需要做,就能正常使用。
> 但是如果需要在非主线程上添加定时器时就要手动开启run loop了。
因为如果不开启的话，线程执行完方法之后就直接退出了，从而导致定时器任务根本没有执行。
```
- (void)addThread {
    [[[NSThread alloc] initWithTarget:self selector:@selector(startNewThread) object:nil] start];
}

- (void)startNewThread {
    //获取当前线程的RunLoop对象
    NSRunLoop *tmpRunLoop = [NSRunLoop currentRunLoop];
    
    //创建RunLoop观察者
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        NSLog(@"CFRunLoopActivity = %lu", activity);
    });
    
    if (observer) {
        //获取RunLoop对象的引用，便于后续添加观察者
        CFRunLoopRef runLoopRef = [tmpRunLoop getCFRunLoop];
        //为获取到的RunLoop对象引用添加观察者
        CFRunLoopAddObserver(runLoopRef, observer, kCFRunLoopDefaultMode);
    }
    
    //定时器每一秒执行一次
    //如果这里注释掉，则当前RunLoop无事可做将直接进入休息，可以注释掉体验对比一下输出
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(doFireTimer:) userInfo:nil repeats:YES];
    
    //当前RunLoop运行3秒后退出
    [tmpRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:3]];
}

- (void)doFireTimer:(NSTimer*)timer {
    NSLog(@"执行任务一次");
}
```

# 输入源


## performSelector……方法
> 在主线程中执行时，因为主线程中runloop已经开启，所以可以执行成功。
> 但是如果在非主线程执行某个方法时，就需要手动开启线程的runloop，否则执行不成功。

```
[self.imageView performSelector:@selector(setImage:) withObject:[UIImage imageNamed:@"placeholder"] afterDelay:3.0 inModes:@[NSDefaultRunLoopMode]];
```
*** 上面的这段代码实现：图片在默认的模式下加载，如果用户在进行滑动操作，则不会进入这个模式，可以解决部分滑动卡顿问题 ***


## Port输入源
```
- (void)addPort:(NSPort *)aPort forMode:(NSRunLoopMode)mode;
NSPortDelegate
- (void)handlePortMessage:(NSPortMessage *)message;
```

## Custom自定义输入源



## 停止RunLoop
3种方式：
> 一是用runUntilDate给RunLoop设置超时时间
> 二是用CFRunLoopStop函数告诉RunLoop停止
> 三是移除RunLoop的输入源或定时器源也可以停止，但不是靠谱的方法



