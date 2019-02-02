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
throttle也算是个生僻的单词，至少在口语中毕竟少用到，先来看看词义：
```
a device controlling the flow of fuel or power to an engine.
```
中文翻译是节流器，一种控制流量的设备。对应到我们计算机世界，可以理解成，一种控制数据或者事件流量大小的机制。这么说可能还是有些抽象，再来看看一些具体的技术场景加深理解。

控制刷新事件的产生频率，建立一个Queue以一定的时间间隔来调用reloadData。事实上这是一种很常见的界面优化机制，对于一些刷新频率可能很高的列表界面，比如微信的会话列表界面，如果很长时间没有登录了，打开App时，堆积了很久的离线消息会在短时间内，导致大量的界面刷新请求，频繁的调用reloadData还会造成界面的卡顿，所以此时建立一个FIFO的Queue，以一定的间隔来刷新界面就很有必要了，这种做法代码量会多一些，但体验更好更安全。

场景：Event Frequency Control
不知道大家在写UI的时候，有没有遇到过用户快速连续点击UIButton，产生多次Touch事件回调的场景。

以前机器还没那么快的时候，我在用一些App的时候，时不时会遇到偶尔卡顿，多次点击一个Button，重复Push同一个Controller。

有些工程师会在Button的点击事件里记录一个timestamp，然后判断每次点击的时间间隔，间隔过短就忽略，这也不失为一种解决办法。

再后来学习RxSwift的时候，看到：
```
button.rx_tap
   .throttle(0.5, MainScheduler.instance)
   .subscribeNext { _ in 
      print("Hello World")
   }
   .addDisposableTo(disposeBag)
```
终于有了优雅的书写方式。发现没有，throttle又出现了，这里throttle控制的是什么呢？

不是disk读写，也不是network buffer，而是事件，把事件本身抽象成了一种Data，控制这种数据的流量或者产生频率，就解决了上面我们所说重复点击按钮的问题。

## DISPATCH_QUEUE_PRIORITY_BACKGROUND
```
 @constant DISPATCH_QUEUE_PRIORITY_BACKGROUND
 Items dispatched to the queue will run at background priority, i.e. the queue
 will be scheduled for execution after all higher priority queues have been
 scheduled and the system will run items on this queue on a thread with
 background status as per setpriority(2) (i.e. disk I/O is throttled and the
 thread's scheduling priority is set to lowest value).
```
那Disk I/O Throttle做什么用呢？按照上面这段描述，Disk I/O会impact system performance。
* 简而言之，对于重度磁盘I/O依赖的后台任务，如果对实时性要求不高，放到DISPATCH_QUEUE_PRIORITY_BACKGROUND Queue中是个好习惯，对系统更友好。
实际上I/O Throttle还分为好几种，有Disk I/O Throttle，Memory I/O Throttle，和Network I/O Throttle。语义类似只不过场景不同。

>  Network Throttle
知名的第三方网络框架都有对Newtork Throttle的支持，你可能会好奇，我们为什么要对自己发出的网络请求做流量控制，难道不应该尽可能最大限度的利用带宽吗？
```
/**
 Throttles request bandwidth by limiting the packet size and adding a delay for each chunk read from the upload stream.

 When uploading over a 3G or EDGE connection, requests may fail with "request body stream exhausted". Setting a maximum packet size and delay according to the recommended values (`kAFUploadStream3GSuggestedPacketSize` and `kAFUploadStream3GSuggestedDelay`) lowers the risk of the input stream exceeding its allocated bandwidth. Unfortunately, there is no definite way to distinguish between a 3G, EDGE, or LTE connection over `NSURLConnection`. As such, it is not recommended that you throttle bandwidth based solely on network reachability. Instead, you should consider checking for the "request body stream exhausted" in a failure block, and then retrying the request with throttled bandwidth.

 @param numberOfBytes Maximum packet size, in number of bytes. The default packet size for an input stream is 16kb.
 @param delay Duration of delay each time a packet is read. By default, no delay is set.
 */ 
 - (void)throttleBandwidthWithPacketSize:(NSUInteger)numberOfBytes 
```
科普一点TCP协议相关的知识：
 
 > 我们通过HTTP请求发送数据的时候，实际上数据是以Packet的形式存在于一个Send Buffer中的，应用层平时感知不到这个Buffer的存在。
 > TCP提供可靠的传输，在弱网环境下，一个Packet一次传输失败的概率会升高，即使一次失败，TCP并不会马上认为请求失败了，而是会继续重试一段时间，同时TCP还保证Packet的有序传输，意味着前面的Packet如果不被ack，后面的Packet就会继续等待，
 > 如果我们一次往Send Buffer中写入大量的数据，那么在弱网环境下，排在后面的Packet失败的概率会变高，也就意味着我们HTTP请求失败的几率会变大。
 > 大部分时候在应用层写代码的时候，估计不少同学都意识不到Newtork Throttle这种机制的存在。
 > 在弱网环境下（丢包率高，带宽低，延迟高）一些HTTP请求(比如上传图片或者日志文件)失败率会激增，有些朋友会觉得这个我们也没办法，毕竟网络辣么差。
 
其实，作为有追求的工程师，我们可以多做一点点，而且弱网下请求的成功率其实是个很值得深入研究的方向。
 
针对弱网场景，我们可以启用Newtork Throttle机制，减小我们一次往Send Buffer中写入的数据量，或者延迟某些请求的发送时间，这样所有的请求在弱网环境下，都能「耐心一点，多等一会」，请求成功率自然也就适当提高啦。

Network Throttle体现了一句至理名言「慢即是快」。


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

## Dispatch Semaphore 信号量
* Dispatch Semaphore 是持有计数的信号量。
* dispatch_semaphore_create 创建一个信号量，并通过参数指定信号量持有的计数。
* dispatch_semaphore_signal 将信号量持有计数增加 1。
* dispatch_semaphore_wait 函数会判断信号量持有计数的值，如果计数为 1 或大于 1，函数会直接返回。如果计数为 0，函数会阻塞当前线程并一直处于等待状态不返回，直到信号量计数变为大于等于 1，dispatch_semaphore_wait 才会停止等待并返回。
* dispatch_semaphore_wait 支持设置一个等待时间，如果到了这个时间，即使信号量计数不是大于等于 1，函数也会停止等待并返回。
```
//让函数阻塞地执行异步任务
- (void)dispatchSemaphoreDemo {
    dispatch_queue_t queue = dispatch_queue_create("com.example.GCD.dispatchSemaphore", NULL);    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);    //生成数量为0的信号量，让后面的wait进入等待状态
    dispatch_async(queue, ^{
            NSLog(@"here 1");        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), queue, ^{
            dispatch_semaphore_signal(semaphore);//将信号量的计数加1，系统会自动通知wait说信号量发生了变化
        });
    });    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);//系统等待信号量不为0时才能继续下一步    
    NSLog(@"here 2");
}
```
```
//细粒度地控制在同一时间一个操作可以被并发得执行次数
dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);//生成数量为1的信号量，让后面的wait不是进入等待状态，而是继续下一步
NSMutableArray *array = [[NSMutableArray alloc] init];
for (int i = 0; i < 10000; ++i) {
    dispatch_async(queue, ^{
        //如果不进行这样的操作，代码会大概率发生崩溃，因为并发的执行很容易发生内存错误。
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);//系统等待信号量不为0时才能继续下一步，因为初始化时数量为1，所以第一次不会进入等待，而是继续执行  
        [array addObject:@(i)];
        dispatch_semaphore_signal(semaphore);//将信号量的计数加1，系统会自动通知wait说信号量发生了变化
    });
}
```
引用来源：[GCD 中那些你可能不熟悉的知识](http://liuduo.me/2018/02/17/gcd-maybe-you-dont-know/)

## 安全知识
很多App都有类似的问题，在安全方面投入太少。
* 客户端没有做ssl pinning，所以可以通过中间人攻击分析请求。
* Server端也没有针对replay attack做任何防范。
* 做App还是要多注意下安全方面的东西，即使上了https，也要做多做一层加密保护。安全方面的工作，做得再多也为过。


## 普通人如何实现top5

> 呆伯特漫画的作者亚当斯（ Scott Adams），有一次谈到自己的成功秘诀。

> 他的经历其实很普通。小时候喜欢画画，画得还可以，但远远不算优秀。长大以后，在一家公司当经理，管理企业，也是业绩平平。无论是选择当画家，或者继续当公司经理，也许都能够干下去，但应该都不会很成功。于是，他灵机一动，把自己的这两个特点结合起来，选择了另一条路：专门画讽刺企业管理的漫画，结果走红了，成了世界闻名的漫画家。

> 他说，任何领域最优秀的前5%的人，都能拿到很好的报酬，比如，最优秀的那5%的程序员、面包师、钢琴家、美发师都是高收入的。但是，想要挤进这5%，是很不容易的，需要拼掉其他95%的人。但是，如果标准放宽一点，挤进前25%，普通人经过努力，还是很有希望达到的。

成功的秘诀就是，**你必须有两个能达到前25%水平的领域，这两个领域的交集就是你的职业方向**。

> 简单计算就可以知道，两个领域都是前25%，那么交集就是 25% 乘以 25%，等于 6.25%，即很有可能挤进前5%。更进一步，如果在两个领域里面，你都属于前10%的优秀人才，那么在交集里面，就可以达到顶尖的1%。总之，选择交集作为职业方向，你的竞争力会提升一个量级，收入也会随之大涨。

> 举例来说，袁腾飞是一个中学历史老师，但是表达能力非常好，特别能说，简直能当脱口秀演员。如果他一直当中学历史老师，或者选择说脱口秀（就像黄西那样），可能都不会很成功，竞争者太多了。但是他把两者结合起来，专门在网上视频说历史，讲得就很有意思，非常受欢迎，另一方面这个领域的竞争者也很少。

> 当市场出现大的热潮时，最好的策略通常不是参与这个热潮，而是成为工具提供者。