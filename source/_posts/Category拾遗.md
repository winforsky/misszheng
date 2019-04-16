---
title: Category拾遗
comments: false
date: 2019-04-10 16:40:03
tags:
categories:
---

以上是摘要部分
<!--more-->

## Category 为什么不直接生成属性对应的getter和setter方法

Property是Property，Ivar是Ivar。

使用@property声明属性，系统会自动生成带“_”的成员变量，以及该变量的getter和setter方法

Category是运行时进行方法绑定，而类的属性需要在编译时就确定，时机不对。

但是可以通过runtime机制来添加实现，本质是通过方法绑定来实现，是需要转化为指针，所以没有assign的修饰符。

涉及数据结构：

> AssociationsManager：class AssociationsManager manages a spinlock_t lock / hash table singleton pair维护了一个从 spinlock_t 锁到 AssociationsHashMap 哈希表的单例键值对映射；
> AssociationsHashMap：pair<const disguised_ptr_t, ObjectAssociationMap*>维护了从对象地址到 ObjectAssociationMap 的映射
> ObjectAssociationMap：map<void *, ObjcAssociation, ObjectPointerLess, ObjectAssociationMapAllocator>维护了从 key 到 ObjcAssociation 的映射，即关联记录
> ObjectAssociation：ObjcAssociation(uintptr_t policy, id value)主要包括两个实例变量，_policy 表示关联策略，_value 表示关联对象

## Category 和 Extetion有什么区别

extension看起来很像一个匿名的category，但是extension和有名字的category几乎完全是两个东西。 extension在编译期决议，它就是类的一部分，在编译期和头文件里的@interface以及实现文件里的@implement一起形成一个完整的类，它伴随类的产生而产生，亦随之一起消亡。

extension一般用来隐藏类的私有信息，你必须有一个类的源码才能为一个类添加extension，所以你无法为系统的类比如NSString添加extension。

但是category则完全不一样，它是在运行期决议的。

就category和extension的区别来看，我们可以推导出一个明显的事实，extension可以添加实例变量，而category是无法添加实例变量的（因为在运行期，对象的内存布局已经确定，如果添加实例变量就会破坏类的内部布局，这对编译型语言来说是灾难性的）。

## synthesize 自动合成  和 dynamic 动态生成

@dynamic仅仅是告诉编译器这两个方法在运行期会有的，无需产生警告。
@synthesize编译器会确实的产生getter和setter方法。

应用场景：
B类，C类分别继承A类，A类实现某个协议@protocol，协议中某个属性somePropety不想在A中实现，而在B类，C类中分别实现。
此时，如果A中不写任何代码，编译器就会给出警告:

```oc
“use @synthesize, @dynamic or provide a method implementation"
```

这时你给用@dynamic somePropety; 编译器就不会警告，同时也不会产生任何默认代码。

## assign、retain、copy、weak、strong

assign 直接赋值，引用计数不会自动加1
assign 对象时，使用完成后不会自动置为nil，再次访问可能导致crash。
所以assign常用来修饰基本类型。

retain 引用计数会自动加1，当引用计数为0时系统回收内存
copy 复制对象到新的内存区域，和原来的不再关联
weak 弱引用，引用计数不会自动加1，使用完成之后自动置为nil
strong 强引用，与retain作用一致

## delegate对象应该使用什么修饰符？strong、weak、assign

assign 弱引用，引用计数不加1，使用完成后不会自动置为nil，重复访问时可能导致crash
strong 强引用，可能导致循环引用
weak 弱引用，引用计数不加1，使用完成后自动置为nil

## 内存的分配与回收

alloc new copy分配内存，new == alloc+init 

dealloc free 释放内存

在涉及内存分配与回收的地方使用_propertyName，其它建议使用self.propertyName

mutableCopy 非线程安全

## 栈和堆

栈 系统自动分配和释放 存放函数的参数值、局部变量值等

堆 手动分配和释放，所以要注意及时释放

对象存放在堆，基本类型存储在栈

## autorelease的对象什么时候释放

不是出了作用域就被释放，
而是等到当前runloop结束时才会一次性清理被autorelease处理过的对象，本质是将对象添加到autoreleasepool里面。
本质上说是在本次runloop迭代结束时清理掉被本次迭代期间被放到autorelease pool中的对象的。

```oc
- (id) autorelease {
  [NSAutoreleasePool addObject:self];
}
```

当然什么时候结束runloop，系统并没有给出明确的duration。

```oc
void *context = objc_autoreleasePoolPush();
// {}中的代码
objc_autoreleasePoolPop(context);//当前runloop迭代结束时进行pop操作
```

objc_autoreleasePoolPush与objc_autoreleasePoolPop只是对autoreleasePoolPage的一层简单封装，它是C++数据类型，本质是一个双向链表。next就是指向当前栈顶的下一个位置。

数组的遍历方法enumerateObjectsUsingBlcok中自动加入了autoreleasepool，效率更高。

## kvo的细节

添加移除必须配对，多次释放会导致crash。
监听处理函数需要判断当前事件来源context及事件的keypath，并合理调用super来继续传递。
使用context来区分不同的事件来源对象，特别注意父子类同时kvo同一keypath。

1.当一个object有观察者时，动态创建这个object的类的子类，派生类是NSKVONotifying_Xxx，Xxx.class object_getClass(Xxx) 不一致
2.对于每个被观察的property，重写其set方法，派生类在被重写的setter方法内实现真正的通知机制。

键值观察通知依赖于NSObject 的两个方法: willChangeValueForKey: 和 didChangevlueForKey:；
在一个被观察属性发生改变之前， willChangeValueForKey:一定会被调用，这就 会记录旧的值。
而当改变发生后，didChangeValueForKey:会被调用，
继而 observeValueForKey:ofObject:change:context: 也会被调用。
willChangeValueForKey和didChangeValueForKey触发了监听方法的调用

3.在重写的set方法中调用- willChangeValueForKey:和- didChangeValueForKey:通知观察者

4.当一个property没有观察者时，删除重写的方法

5.当没有observer观察任何一个property时，删除动态创建的子类

## GCD 和 NSOperationQueue

NSOperationQueue 可控制行更强，

NSBlockOperation *uploadOperation

* dispatch_xxx_create 需要手动释放

## 将异步任务转为同步任务

* 方法1: 使用dispatch_group
dispatch_group_enter(uploadGroup);
dispatch_async(uploadQueue, ^{
    [xxxAction actionAsyncCallBack:^{
        dispatch_group_leave(uploadGroup);
    }];
});
dispatch_group_notify(uploadGroup, uploadQueue, ^{});

* 方法2: 使用dispatch_semaphore_t
{
    //资源，创建0个资源
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block UIImage * image1;
    [xxxManager resultHandler:^(UIImage *resultImage, NSDictionary *info)
        {
            image1 = resultImage;
            //生成新的资源
            dispatch_semaphore_signal(semaphore);
        }];

    //等到有资源时才执行，0个资源时一直等待
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return image1;
}

## 截整个scrollview屏幕方法

```oc
- (UIImage *)captureScrollView{
    UIImage* image = nil;
    UIGraphicsBeginImageContext(scrollView.contentSize,NO,0.0f);
    {
        //先保存当前的偏移量
        CGPoint savedContentOffset = scrollView.contentOffset;
        CGRect savedFrame = scrollView.frame;

        scrollView.contentOffset = CGPointZero;
        scrollView.frame = CGRectMake(0, 0, scrollView.contentSize.width, scrollView.contentSize.height);
        //强制渲染
        [scrollView.layer renderInContext: UIGraphicsGetCurrentContext()];
        image = UIGraphicsGetImageFromCurrentImageContext();

        //恢复之前保存的偏移量
        scrollView.contentOffset = savedContentOffset;
        scrollView.frame = savedFrame;
    }
    UIGraphicsEndImageContext();

    if (image != nil) {
        return image;
    }
    return nil;
}
```