//
//  main.m
//  ocdemo
//
//  Created by zsp on 2019/3/4.
//  Copyright © 2019 woop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "AppDelegate.h"
/*
 文章来源：https://www.jianshu.com/p/ee9756f3d5f6
OC中，一般Block就分为以下3种，_NSConcreteStackBlock，_NSConcreteMallocBlock，_NSConcreteGlobalBlock。
先来说明一下3者的区别。
1.从捕获外部变量的角度上来看
1）_NSConcreteStackBlock：
只用到外部局部变量、成员属性变量，且没有强指针引用的block都是StackBlock。
StackBlock的生命周期由系统控制的，一旦返回之后，就被系统销毁了。
2）_NSConcreteMallocBlock：
有强指针引用或copy修饰的成员属性引用的block会被复制一份到堆中成为MallocBlock，没有强指针引用即销毁，生命周期由程序员控制
3）_NSConcreteGlobalBlock：
没有用到外界变量或只用到全局变量、静态变量的block为_NSConcreteGlobalBlock，生命周期从创建到应用程序结束。
 2.从持有对象的角度上来看：[MRC 下使用obj.retainCount查看引用计数]
 1)_NSConcreteStackBlock是不持有对象的。
 2)_NSConcreteMallocBlock是持有对象的。
 3)_NSConcreteGlobalBlock也不持有对象
 
 以下4种情况，系统都会默认调用copy方法把Block赋复制
 1）手动调用copy
 2）Block是函数的返回值
 3）Block被强引用，Block被赋值给__strong或者id类型
 4）调用系统API入参中含有usingBlcok的方法
 
 但是当Block为函数参数的时候，就需要我们手动的copy一份到堆上了。
 这里除去系统的API我们不需要管，比如GCD等方法中本身带usingBlock的方法，
 其他我们自定义的方法传递Block为参数的时候都需要手动copy一份到堆上。
 
 copy函数把Block从栈上拷贝到堆上，dispose函数是把堆上的函数在废弃的时候销毁掉。
 
*/

/*
 Block中__block实现原理：
 1.普通非对象的变量
 ARC环境下，一旦Block赋值就会触发copy，__block就会copy到堆上，Block也是__NSMallocBlock。ARC环境下也是存在__NSStackBlock的时候，这种情况下，__block就在栈上。
 MRC环境下，只有copy，__block才会被复制到堆上，否则，__block一直都在栈上，block也只是__NSStackBlock，这个时候__forwarding指针就只指向自己了。
 2.对象的变量
 在MRC环境下，__block根本不会对指针所指向的对象执行copy操作，而只是把指针进行的复制。
 而在ARC环境下，对于声明为__block的外部对象，在block内部会进行retain，以至于在block环境内能安全的引用外部对象，所以才会产生循环引用的问题！
 
 在Block中改变变量值有2种方式：
 一是传递内存地址指针到Block中，
 二是改变存储区方式(__block),也可以理解为作用域升级。
 比如：静态全局变量，全局变量，函数参数，也是可以在直接在Block中改变变量值的，
 但是他们并没有变成Block结构体__main_block_impl_0的成员变量，
 因为他们的作用域大，所以可以直接更改他们的值。
 
 什么时候在 block 里面用 self，不需要使用 weak self？
 所谓循环引用就是 我持有你，你持有我，形成一个环。潜在问题：我持有你，你持有他，他持有我，间接形成一个环。
 
 当 block 本身不被 self 持有，而被别的对象持有，同时不产生循环引用的时候，就不需要使用 weak self 了。
 最常见的代码就是 UIView 的动画代码，
 在使用 UIView 的 animateWithDuration:animations 方法 做动画的时候，并不需要使用 weak self，因为引用持有关系是：
 a、UIView 的某个负责动画的对象持有了 block
 b、block 持有了 self
 因为 self 并不持有 block，所以就没有循环引用产生，因为就不需要使用 weak self 了。
 
 [UIView animateWithDuration:0.2 animations:^{
 self.alpha = 1;
 }];
 
 当动画结束时，UIView 会结束持有这个 block，如果没有别的对象持有 block 的话，block 对象就会释放掉，从而 block 会释放掉对于 self 的持有。整个内存引用关系被解除。
 
 
 */

int global_val = 11;//全局变量==》作用域广=〉传递的是指针也就是地址
static int static_global_val=22;//静态全局变量==》作用域广=〉存储区域：data区

static void valFiledDemo() {
    
    static int static_inner_val=33;//静态局部变量==》转换为指针进行捕获=〉传递的是指针也就是地址
    int common_inner_val=44;//普通局部变量==〉普通变量进行值copy
    __block int blocker_inner_val=44;//block局部变量==〉普通变量转换为其指针后被捕获=〉传递的是指针也就是地址
    NSMutableString *str= [[NSMutableString alloc] initWithString:@"hello"];
    
    //普通局部变量和静态局部变量会被捕获为成员变量追加到构造函数中
    //仅仅捕获和block内部会使用到的变量
    //查看方法clang -rewrite-objc main.m -o main.cpp
//    在Block中改变变量值有2种方式：一是传递内存地址指针到Block中，二是改变存储区方式(__block)。
    void (^myBlock)(void) = ^ {
        global_val++;
        static_global_val++;
        static_inner_val++;
        blocker_inner_val++;
//        NSLog(@"Block中 global_val= %d， static_global_val= %d， static_inner_val= %d， common_inner_val= %d", global_val, static_global_val, static_inner_val, common_inner_val);
        NSLog(@"Block中 global_val= %d， static_global_val= %d， static_inner_val= %d", global_val, static_global_val, static_inner_val);
//        [str appendString:@" append in block"];
//        NSLog(@"Block中 str=%@", str);
    };
    NSLog(@"Block type = %@", myBlock);
    
    global_val++;
    static_global_val++;
    static_inner_val++;
    common_inner_val++;
    NSLog(@"Block外 global_val= %d， static_global_val= %d， static_inner_val= %d， common_inner_val= %d", global_val, static_global_val, static_inner_val, common_inner_val);
    NSLog(@"Block外 str=%@", str);
    myBlock();
    
}

static void detailDemo_one() {
    __block int i = 0;
    NSLog(@"%p",&i);
    
    void (^myBlock)(void) = ^{
        i ++;
        NSLog(@"Block 里面的%p",&i);
    };
    
    
    NSLog(@"%@",myBlock);
    
    myBlock();
}

static void detailDemo_two() {
    __block int i = 0;
    NSLog(@"%p",&i);
    
//    堆上的Block会持有对象。
//    我们把Block通过copy到了堆上，堆上也会重新复制一份Block，并且该Block也会继续持有该__block。
//    当Block释放的时候，__block没有被任何对象引用，也会被释放销毁。
    void (^myBlock)(void) = [^{
        i ++;
        NSLog(@"这是Block 里面%p",&i);
    }copy];//这里进行了copy
    
    
    NSLog(@"%@",myBlock);
    
    myBlock();
}


@interface Student : NSObject {
@public
    int _no;
    int _age;
    short _ao;
}
@end

@implementation Student

@end

@interface Person : NSObject
@property(nonatomic, copy) NSString* name;  //8
@property(nonatomic, assign) int age;       //4
@end

@interface Person () {
    NSString *childHoodName;        //8
}

@end

@implementation Person

@end

@interface LittlePerson : Person

@property(nonatomic, copy)NSString *school;     //8
@property(nonatomic, strong)NSArray* toys;      //8
@property(nonatomic, assign)short bookCount;    //2

@end

@implementation LittlePerson

@end

static void objectPtrClassDemo() {
    NSObject *obj = [[NSObject alloc] init];
    Student *stu = [[Student alloc] init];
    
    //涉及到内存对齐
    NSLog(@"size: obj = %zu, student = %zu", class_getInstanceSize([obj class]), class_getInstanceSize([stu class]));
    
    NSLog(@"size: Person = %zu, LittlePerson = %zu", class_getInstanceSize([Person class]), class_getInstanceSize([LittlePerson class]));
    
    
    Class objClass = [NSObject class];
    Class metaObjClass = object_getClass([objClass class]);
    NSLog(@"class_isMetaClass: %@", class_isMetaClass(metaObjClass)?@"1":@"0");
}

int main(int argc, char * argv[]) {
    @autoreleasepool {
//        objectPtrClassDemo();
        valFiledDemo();
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
