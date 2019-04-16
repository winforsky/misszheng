---
title: UITableView处理键盘遮挡的问题
comments: false
date: 2019-04-09 17:27:11
tags:
categories:
---
实际开发过程中经常会遇到需要用户填写信息的情况，极端情况下，还会需要用户填写很多，虽然不建议这么做，但是产品说老板就要这么做，肿么办？

只能按照要求办了，实际开发过程中考虑使用UITableView来做也不失好办法。
但经常会遇到在点击输入框时，弹出的键盘挡住了输入框，用户不能及时看到输入的信息，体验及其不好。

本文针对的就是这种情况的处理，具体三步轻松解决.
<!--more-->
1）监听键盘显示/隐藏事件

```object-c
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWillShowKeyboard:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWillHideKeyboard:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
```

2）处理键盘显示/隐藏事件

```object-c
- (void)handleWillShowKeyboard:(NSNotification *)notification {
    //获取键盘弹出完成之后的Rect
    CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    // 修改滚动条和tableView的contentInset
    self.tableView.contentInset=UIEdgeInsetsMake(0, 0, keyboardRect.size.height, 0);
    // 注意这里，需要同步更新，这里容易被忽略
    // 修改tableView的滚动条的scrollIndicatorInsets
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, keyboardRect.size.height, 0);
}

- (void)handleWillHideKeyboard:(NSNotification *)notification {
    self.tableView.contentInset=UIEdgeInsetsZero;
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
}
```

3）滚动输入框到新的位置

```object-c
//indexPath：当前输入框对应的cell的indexPath
- (void)editingAtIndexPath:(NSIndexPath *)indexPath {
    // 跳转到当前点击的输入框所在的cell
    // 注意这里的延迟时间
    // 是用来避免因使用自定义输入法时导致触发多次键盘弹出事件的问题
    [UIView animateWithDuration:0.2 animations:^{
        [self.tableView scrollToRowAtIndexPath:indexPath
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:NO];
    }];
}

```

使用`+ (void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations`这个方法的原因：

```js
 iOS8之后开始，iOS系统开始支持第三方输入法了，在第三方键盘弹出的时候，UIKeyboardWillShowNotification会有三次通知，
 相应的键盘处理事件方法会执行三次，而三次的键盘高度可能是不一样的，以最后一次高度为准，
 所以tableView在滚动的时候，默认的动画在多次执行时，可能会存在前一个动画没执行完成，后面的方法就不会执行，
 从而导致tableView无法滚动到目标位置的问题。
 使用UIView的这个动画方法就能解决。
```

参考资料

* [UITableView+UIScrollView的键盘弹出处理](https://www.jianshu.com/p/c01d19b81eed)