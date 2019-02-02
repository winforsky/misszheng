---
title: iOS易忽略
comments: false
date: 2019-01-30 09:51:41
tags:
categories:
---

以上是摘要部分
<!--more-->

# weak的使用

* weak 简单解释为 弱引用，在对象被释放后自动置为nil，避免内存引用错误导致crash。
* weak 常用于在delegate、block、NSTimer中用于避免循环引用带来的内存泄露。
* 解决循环引用的另一个方法是将可能会导致循环引用的对象作为参数传入。
```
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
```
* 编程语言是工具，语言特性只是工具的特性，工具怎么用在于使用者。weak 关键字的方便之处绝不局限于避免循环引用，适当脑洞，可以在其他场景下带来一些有趣的应用。

## 单例
什么时候会释放不需要了的单例？

大部分场景下遇到被创建的单例会一直存在，不会被显式的释放，这有时候会造成内存浪费。

可以使用[weak singleton](https://www.ios-blog.co.uk/tutorials/objective-c-ios-weak-singletons/)来解决，代码如下
```
+ (id)sharedInstance
{
    static __weak ASingletonClass *instance;
    ASingletonClass *strongInstance = instance;
    @synchronized(self) {
        if (strongInstance == nil) {
            strongInstance = [[[self class] alloc] init];
            instance = strongInstance;
        }
    }
    return strongInstance;
}
```
* weak singleton 有意思的特性是：在所有使用该单例的对象都释放后，单例对象本身也会自己释放。


## associated object
使用 associated object 的时候，有一些细节需要额外考虑。比如 property 是强引用还是弱引用，这个选择题取决于代码结构的设计。如果是强引用，则对象的生命周期跟随所依附的对象，XXController dealloc 的时候，DumpViewObject 也随之 dealloc。如果是弱引用，则说明 DumpViewObject 对象的创建会销毁由其他对象负责，一般是为了避免存在循环引用，或者由于 DumpViewObject 的职责多于所依附对象的需要，DumpViewObject 有更多的状态需要维护处理。

associated object 本身并不支持添加具备 weak 特性的 property，但我们可以通过一个小技巧来完成：
```
- (void)setContext:(CDDContext*)object {
    id __weak weakObject = object;
    id (^block)() = ^{ return weakObject; };
    objc_setAssociatedObject(self, @selector(context), block, OBJC_ASSOCIATION_COPY);
}

- (CDDContext*)context {
    id (^block)() = objc_getAssociatedObject(self, @selector(context));
    id curContext = (block ? block() : nil);
    return curContext;
}
```
添加了一个中间角色 block，再辅以 weak 关键字就实现了具备 weak 属性的 associated object。这种做法也印证了软件工程里一句名言「We can solve any problem by introducing an extra level of indirection」。

类似的用法还有不少，比如 NSArray，NSDictionary 中的元素引用都是强引用，但我们可以通过添加一个中间对象 WeakContainer，WeakContainer 中再通过 weak property 指向目标元素，这样就能简单的实现一个元素弱引用的集合类。

弱引用容器是指基于NSArray, NSDictionary, NSSet的容器类, 该容器与这些类最大的区别在于, 将对象放入容器中并不会改变对象的引用计数器, 同时容器是以一个弱引用指针指向这个对象, 当对象销毁时自动从容器中删除, 无需额外的操作.

目前常用的弱引用容器的实现方式是block封装解封

利用block封装一个对象, 且block中对象的持有操作是一个弱引用指针. 而后将block当做对象放入容器中. 容器直接持有block, 而不直接持有对象. 取对象时解包block即可得到对应对象.

第一步 封装与解封
```
typedef id (^WeakReference)(void);

WeakReference makeWeakReference(id object) {
    __weak id weakref = object;
    return ^{
        return weakref;
    };
}

id weakReferenceNonretainedObjectValue(WeakReference ref) {
    return ref ? ref() : nil;
}
```
第二步 改造原容器
```
- (void)weak_setObject:(id)anObject forKey:(NSString *)aKey {
    [self setObject:makeWeakReference(anObject) forKey:aKey];
}

- (void)weak_setObjectWithDictionary:(NSDictionary *)dic {
    for (NSString *key in dic.allKeys) {
        [self setObject:makeWeakReference(dic[key]) forKey:key];
    }
}

- (id)weak_getObjectForKey:(NSString *)key {
    return weakReferenceNonretainedObjectValue(self[key]);
}
```

这样就实现了一个弱引用字典, 之后用弱引用字典即可.


## [throttle机制](http://mrpeak.cn/blog/tableview-danger/)
控制刷新事件的产生频率，建立一个Queue以一定的时间间隔来调用reloadData。事实上这是一种很常见的界面优化机制，对于一些刷新频率可能很高的列表界面，比如微信的会话列表界面，如果很长时间没有登录了，打开App时，堆积了很久的离线消息会在短时间内，导致大量的界面刷新请求，频繁的调用reloadData还会造成界面的卡顿，所以此时建立一个FIFO的Queue，以一定的间隔来刷新界面就很有必要了，这种做法代码量会多一些，但体验更好更安全。

## Wireshark抓包iOS入门教程
[Wireshark抓包iOS入门教程](http://mrpeak.cn/blog/wireshark/)

## 网络请求在Controller退出后是否应该被取消？
一个编写iOS代码的经典场景：
> 用户进入某个Controller，发起Http网络请求从Server获取数据，在数据返回之前用户退出了Controller。此时是否需要Cancel之前发出的网络请求呢？

如果请求的数据只在当前Controller产生内容，结论当然是需要Cancel。

如果不Cancel，请求完成之后通过回调找到delegate，如果是weak引用，Controller被释放，delegate变为nil，业务流程被中断，代码还算安全。但是会的的确确浪费一些用户流量。养成好习惯，自己产生的垃圾自己清理哦。

## + (UIImage *)imageNamed:(NSString *)name导致内存问题
方法在application bundle的顶层文件夹寻找名字的图象 , 如果找到图片， 系统缓存图象。图片内容被加载到系统内存中，使用时直接引用到系统内存。 

所以当图片比较大时，程序使用的内存会迅速上升导致内存警告并退出。 

特别在使用Interface Builder建立界面时，如果直接拖动UIImageView 并设置image的图片名称。InterfaceBuilder 正是通过UIImage 类的imageName方法加载图片。图片被缓存，导致内存使用较大，且无法释放，即使release掉 UIImageView也无济于事。 

* 生命周期与APP的生命周期同步？
* 如果没有使用局部释放池，并且在主线程，则是当前主线程Runloop一次循环结束前释放？
* the class holds onto cached objects only while the object exists. If all strong references to the image are subsequently removed, the object may be quietly removed from the cache. Thus, if you plan to hold onto a returned image object, you must maintain a strong reference to it like you would any Cocoa object.

* 像[[UIImageView alloc] init]还有一些其他的 init 方法，返回的都是 autorelease 对象。而 autorelease 不能保证什么时候释放，所以不一定在引用计数为 0 就立即释放，只能保证在 autoreleasepool 结尾的时候释放。像 UIImage 还有 NSData 这种，大部分情况应该是延迟释放的，可以理解为到 autoreleasepool 结束的时候才释放。