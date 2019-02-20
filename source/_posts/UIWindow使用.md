---
title: UIWindow使用
comments: false
date: 2019-02-15 18:27:35
tags:
categories:
---

在市场上，“会来事儿”是非常容易，因为在这里，大家的利益取向是透明的，每个个体都是逐利的。因为在这里，不仅毫不隐藏，而且连指标都倾向于清清楚楚。

> 任何一笔交易，都有人赚，赚到的人就会开心。

> 若是某一笔交易令人赔了，那他就不会开心。

> 若是你想出来的一笔交易在你赚到的同时别人也能赚到，那么所有人都会赞：“牛逼！漂亮！会来事儿！”

> 如果你想出来的交易结局是你赚到，对方赔掉，那么对方就会记恨你，通常会忍不住天天琢磨，终究琢磨出个什么办法找回来，甚至不惜使用“损人不利己”的方式让你“舒服不了几天！”

因此，所谓的“会来事儿”，只需要做几点正常的决策判断就可以了：

* 想办法让别人也赚到；
* 损人利己的事儿坚决不做；
* 损人不利己，是智商有问题……

所谓的“会来事儿”不过是“懂得如何制造**双赢**甚至**多赢**局面”。

深入思考，分析，需求分析、干系人分析

> 在这个新的环境里，我要面对的人群都有什么特性，
> 如果我想要在这样的新环境里创造多赢局面，我应该认真考虑到哪些人的利益？

以上是摘要部分
<!--more-->

```objc
- (void)createNewWindow
{
    self.backView = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds]];
    UIXXView * resultView =[[UIXXView alloc]initWithFrame:frame entity:entity];
    resultView.resultDelegate = self;
    [self.backView addSubview:resultView];
    self.backView.windowLevel = UIWindowLevelAlert ; //关键地方
    self.backView.hidden = NO;
    [self.backView  makeKeyAndVisible];//关键地方
}

#pragma mark - UIXXViewDelegate
- (void)restartWithtype:(EXPWrongPlarerType)type
{
    [self.backView resignKeyWindow];//关键地方
    [self.backView removeFromSuperview];
    self.backView.hidden = YES ;
    self.backView = nil;
}
```