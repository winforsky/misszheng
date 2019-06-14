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


昨天：
1、实现步骤式教学的缓存加载并进行调试 100%
2、修复QA反馈的bug
今天：
1、完善我的画室页面逻辑
2、完善我的作品再次编辑的逻辑