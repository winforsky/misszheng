---
title: UICollectionView的Layout
comments: false
date: 2019-05-14 15:04:32
tags:
categories:
---

以上是摘要部分
<!--more-->

## UICollectionView

视图容器UICollectionView进一步抽象，它将其子视图的位置，大小和外观的控制权委托给一个单独的布局对象。
通过提供一个自定义布局对象，你几乎可以实现任何你能想象到的布局。
布局继承自UICollectionViewLayout这个抽象基类。
iOS6中以UICollectionViewFlowLayout类的形式提出了一个具体的布局实现。

* 在准备自己写一个UICollectionViewLayout的子类之前，你需要问你自己，你是否能够使用UICollectionViewFlowLayout实现你心里的布局。
* UICollectionViewFlowLayout这个类是很容易定制的，并且可以继承本身进行近一步的定制。[感兴趣的看这篇苹果开发者文章](https://developer.apple.com/library/archive/documentation/WindowsViews/Conceptual/CollectionViewPGforIOS/UsingtheFlowLayout/UsingtheFlowLayout.html#//apple_ref/doc/uid/TP40012334-CH3-SW4)

* Collection view的cells必须是UICollectionViewCell的子类。除了cells，collection view额外管理着两种视图：supplementary views和decoration views。
和table view中用法不一样，supplementary view并不一定会作为header或footer view；他们的数量和放置的位置完全由布局控制。

* Decoration views纯粹为一个装饰品。他们完全属于布局对象，并被布局对象管理，他们并不从数据源获取他们的contents。当布局对象指定它需要一个decoration view的时候，collection view会自动创建，并为其应用布局对象提供的布局参数。并不需要准备任何自定义视图的内容。

* Supplementary views和decoration views必须是UICollectionResuableView的子类。每个你布局所使用的视图类都需要在collection view中注册，这样当data source让他从reuse pool中出列时，它才能够创建新的实例。

## 自定义布局

### 滚动区域的大小

// Subclasses must override this method and use it to return the width and height of the collection view’s content. These values represent the width and height of all the content, not just the content that is currently visible. The collection view uses this information to configure its own content size to facilitate scrolling.
> `- (CGSize)collectionViewContentSize;` 

### 重用准备

// The collection view calls -prepareLayout once at its first layout as the first message to the layout instance.
// The collection view calls -prepareLayout again after layout is invalidated and before requerying the layout information.
// Subclasses should always call super if they override.
> `- (void)prepareLayout;`

* 可以在这里注册装饰视图

### 布局控制

// UICollectionView calls these four methods to determine the layout information.
// Implement -layoutAttributesForElementsInRect: to return layout attributes for for supplementary or decoration views, or to perform layout in an as-needed-on-screen fashion.
// Additionally, all layout subclasses should implement -layoutAttributesForItemAtIndexPath: to return layout attributes instances on demand for specific index paths.
// If the layout supports any supplementary or decoration view types, it should also implement the respective atIndexPath: methods for those types.

// return an array layout attributes instances for all the views in the given rect

> `- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect; `
这个是布局类中最重要的方法，可能也是最容易让人迷惑的方法。collection view调用这个方法并传递一个自身坐标系统中的矩形过去。
这个矩形rect代表了这个视图的可见矩形区域（也就是它的bounds），你需要准备好处理传给你的任何矩形。

**这个方法涉及到所有类型的视图，也就是cell，supplementary views和decoration views。**

```
实现需要做这几步：
1.创建一个空的mutable数组来存放所有的布局属性。
2.确定index paths中哪些cells的frame完全或部分位于矩形中。这个计算需要你从collection view的数据源中取出你需要显示的数据。然后在循环中调用你实现的layoutAttributesForItemAtIndexPath:方法为每个index path创建并配置一个合适的布局属性对象，并将每个对象添加到数组中。
3.如果你的布局包含supplementary views，计算矩形内可见supplementary view的index paths。在循环中调用你实现的layoutAttributesForSupplementaryViewOfKind:atIndexPath:，并且将这些对象加到数组中。通过为kind参数传递你选择的不同字符，你可以区分出不同种类的supplementary views（比如headers和footers）。当需要创建视图时，collection view会将kind字符传回到你的数据源。记住supplementary和decoration views的数量和种类完全由布局控制。你不会受到headers和footers的限制。
4.如果布局包含decoration views，计算矩形内可见decoration views的index paths。在循环中调用你实现的layoutAttributesForDecorationViewOfKind:atIndexPath:，并且将这些对象加到数组中。 
5.返回数组。
```

> `- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath;`

> `- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath;`

> `- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString*)elementKind atIndexPath:(NSIndexPath *)indexPath;`


继承UICollectionViewFlowLayout https://blog.csdn.net/u014084081/article/details/82113149

https://blog.csdn.net/chenyong05314/article/details/45646397 IOS中集合视图UICollectionView中DecorationView的简易使用方法

https://www.raywenderlich.com/9229-nuke-tutorial-for-ios-getting-started Nuke Tutorial for iOS: Getting Started
https://www.raywenderlich.com/397-instruments-tutorial-with-swift-getting-started  Instruments Tutorial with Swift: Getting Started
https://www.raywenderlich.com/3089-instruments-tutorial-for-ios-how-to-debug-memory-leaks  Instruments Tutorial for iOS: How To Debug Memory Leaks


CFRunLoopRef 的代码是开源的，你可以在这里 http://opensource.apple.com/tarballs/CF/ 下载到整个 CoreFoundation 的源码来查看。

(Update: Swift 开源后，苹果又维护了一个跨平台的 CoreFoundation 版本：https://github.com/apple/swift-corelibs-foundation/，这个版本的源码可能和现有 iOS 系统中的实现略不一样，但更容易编译，而且已经适配了 Linux/Windows。)

```oc
/// 全局的Dictionary，key 是 pthread_t， value 是 CFRunLoopRef
static CFMutableDictionaryRef loopsDic;
/// 访问 loopsDic 时的锁
static CFSpinLock_t loopsLock;

/// 获取一个 pthread 对应的 RunLoop。
CFRunLoopRef _CFRunLoopGet(pthread_t thread) {
    OSSpinLockLock(&loopsLock);

    if (!loopsDic) {
        // 第一次进入时，初始化全局Dic，并先为主线程创建一个 RunLoop。
        loopsDic = CFDictionaryCreateMutable();
        CFRunLoopRef mainLoop = _CFRunLoopCreate();
        CFDictionarySetValue(loopsDic, pthread_main_thread_np(), mainLoop);
    }

    /// 直接从 Dictionary 里获取。
    CFRunLoopRef loop = CFDictionaryGetValue(loopsDic, thread));

    if (!loop) {
        /// 取不到时，创建一个
        loop = _CFRunLoopCreate();
        CFDictionarySetValue(loopsDic, thread, loop);
        /// 注册一个回调，当线程销毁时，顺便也销毁其对应的 RunLoop。
        _CFSetTSD(..., thread, loop, __CFFinalizeRunLoop);
    }

    OSSpinLockUnLock(&loopsLock);
    return loop;
}

CFRunLoopRef CFRunLoopGetMain() {
    return _CFRunLoopGet(pthread_main_thread_np());
}

CFRunLoopRef CFRunLoopGetCurrent() {
    return _CFRunLoopGet(pthread_self());
}
```

* 线程和 RunLoop 之间是一一对应的，其关系是保存在一个全局的 Dictionary 里。
* 线程刚创建时并没有 RunLoop，如果你不主动获取，那它一直都不会有。
* RunLoop 的创建是发生在第一次获取时，RunLoop 的销毁是发生在线程结束时。
* 你只能在一个线程的内部获取其 RunLoop（主线程除外）。

* 一个 RunLoop 包含若干个 Mode，每个 Mode 又包含若干个 Source/Timer/Observer。
每次调用 RunLoop 的主函数时，只能指定其中一个 Mode，这个Mode被称作 CurrentMode。
如果需要切换 Mode，只能退出 Loop，再重新指定一个 Mode 进入。
这样做主要是为了分隔开不同组的 Source/Timer/Observer，让其互不影响。

* CFRunLoopSourceRef 是事件产生的地方。Source有两个版本：Source0 和 Source1。
• Source0 只包含了一个回调（函数指针），它并不能主动触发事件。使用时，你需要先调用 CFRunLoopSourceSignal(source)，将这个 Source 标记为待处理，然后手动调用 CFRunLoopWakeUp(runloop) 来唤醒 RunLoop，让其处理这个事件。
• Source1 包含了一个 mach_port 和一个回调（函数指针），被用于通过内核和其他线程相互发送消息。这种 Source 能主动唤醒 RunLoop 的线程，其原理在下面会讲到。

* CFRunLoopTimerRef 是基于时间的触发器，它和 NSTimer 是toll-free bridged 的，可以混用。其包含一个时间长度和一个回调（函数指针）。当其加入到 RunLoop 时，RunLoop会注册对应的时间点，当时间点到时，RunLoop会被唤醒以执行那个回调。

* CFRunLoopObserverRef 是观察者，每个 Observer 都包含了一个回调（函数指针），当 RunLoop 的状态发生变化时，观察者就能通过回调接受到这个变化。可以观测的时间点有以下几个：

typedef CF_OPTIONS(CFOptionFlags, CFRunLoopActivity) {
    kCFRunLoopEntry         = (1UL << 0), // 即将进入Loop
    kCFRunLoopBeforeTimers  = (1UL << 1), // 即将处理 Timer
    kCFRunLoopBeforeSources = (1UL << 2), // 即将处理 Source
    kCFRunLoopBeforeWaiting = (1UL << 5), // 即将进入休眠
    kCFRunLoopAfterWaiting  = (1UL << 6), // 刚从休眠中唤醒
    kCFRunLoopExit          = (1UL << 7), // 即将退出Loop
};

typedef CF_OPTIONS(CFOptionFlags, CFRunLoopActivity) {
    kCFRunLoopEntry         = (1UL << 0), // 即将进入Loop
    kCFRunLoopBeforeTimers  = (1UL << 1), // 即将处理 Timer
    kCFRunLoopBeforeSources = (1UL << 2), // 即将处理 Source
    kCFRunLoopBeforeWaiting = (1UL << 5), // 即将进入休眠
    kCFRunLoopAfterWaiting  = (1UL << 6), // 刚从休眠中唤醒
    kCFRunLoopExit          = (1UL << 7), // 即将退出Loop
};

上面的 Source/Timer/Observer 被统称为 mode item，一个 item 可以被同时加入多个 mode。
但一个 item 被重复加入同一个 mode 时是不会有效果的。
如果一个 mode 中一个 item 都没有，则 RunLoop 会直接退出，不进入循环。

