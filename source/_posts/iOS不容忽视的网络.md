---
title: iOS不容忽视的网络
comments: false
date: 2019-02-02 16:44:58
tags:
categories:
---

以上是摘要部分
<!--more-->

## GIF转到视频

* 使用ffmpeg将GIF动画(或源文件)转换为H.264的MP4文件。

使用来自[Rigor](https://rigor.com/blog/2015/12/optimizing-animated-gifs-with-html5-video)的一行代码:

`ffmpeg -i animated.gif -movflags faststart -pix_fmt yuv420p -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" video.mp4`

* ImageOptim API还支持[将GIF动画转换为WebM视频和H.264视频](https://imageoptim.com/api/ungif)，[消除GIF的抖动](https://github.com/kornelski/undither#examples)，这可以帮助视频编解码器压缩更多的文件大小。

## 使用UIView绘制界面

* 随时调用[self setNeedsDisplay];   //强制重绘界面，目的在于更新界面
* 要自己绘制界面必须调用setNeedsDisplay方法，并重写drawRect方法。

```oc
//准备工作做好后，我们就要画虚线的矩形框了.我们需要重写drawRect方法。完整代码如下：
- (void)drawRect:(CGRect)rect //rect参数是这个view在对应cotroller中的位置
{
    NSLog(@"drawRect called ,%f %f %f %f",rect.origin.x,rect.origin.y,rect.size.width,rect.size.height);
    if(_isMoved == true){
        //获取绘图上下文-画板
        CGContextRef ref=UIGraphicsGetCurrentContext();
        //设置虚线
        float lengths[] = {10,10};
        CGContextSetLineDash(ref,2, lengths, 1);
        //画截取线框
        CGContextAddRect(ref,CGRectMake(startPoint.x,startPoint.y,finalPoint.x,finalPoint.y));
        //设置颜色
        CGContextSetStrokeColorWithColor(ref,[UIColor redColor].CGColor);
        //设置线宽
        CGContextSetLineWidth(ref,3);
        CGContextStrokePath(ref);
    }
}
```

### 注意事项

一般情况下都是直接用imageView.image = img来加载图片，但在这种需要在界面上进行绘图的情况下却不能在加载的图片上绘制矩形框

解决方法是：必须把这个img设为背景：`self.backgroundColor = [UIColor colorWithPatternImage:_orignalImage];`

这个现象很奇怪，手指移动都能检测，也能触发绘图，segcontrol也能显示，但就是画不上矩形框。

## [记录园子里的一篇有关CALayer与UIView的关系](http://www.cnblogs.com/lovecode/articles/2249548.html)

* UIView 是 CALayer 的delegate， 真正负责界面绘制的是CALayer类，UIView相当于CALayer的管理器，同时负责事件的交互与响应。
* UIView对应的CALayer树在系统内部有三份维护:

> 逻辑LayerTree【编写代码直接编辑的Layer】，
> 动画AnimationTree【动画系统直接操作的Layer，动画的缺省执行时间0.25秒】，
> 显示LayerTree【最终显示在界面上看到的Layer】

* UIView的anchorPoint属性 左上角(0, 0) 右下角(1, 1) 中间(0.5, 0.5)【默认】，各种图形变换的固定点
* frame[相对于上层的位置]属性是通过position[上层相对于（0，0）的位置]和anchorPoint共同决定的,那么所说的function又是什么呢?根据一系统推导可以得出

```oc
When you specify the frame of a layer, position is set relative to the anchor point. When you specify the position of the layer, bounds is set relative to the anchor point.
```

(0,0)=====>(0,1)
 ||          ||
 ||          ||
 ||          ||
(1,0)=====>(1,1)

```oc
frame.origin.x = position.x - anchorPoint.x * bounds.size.width;
frame.origin.y = position.y - anchorPoint.y * bounds.size.height;
```

## UIImage作为layer的内容显示

```oc
UIImage *image = [UIImage imageNamed:@"clock"];
backgroundView.layer.contents = (__bridge id)image.CGImage;
```

如果把UIImage作为内容赋值给CALayer时，需要同时设置 contentsScale。
大部分情况下不必显示设置，UIKit and AppKit automatically 会自动设置。
当你直接将bitmap位图赋值过去的时候需要手动修改设置 contentsScale。

```oc
Changing the value of the contentsScale property is only necessary if you are assigning a bitmap to your layer directly.
```

```oc
Note: You can use any type of color for the background of a layer, including colors that have transparency or use a pattern image. When using pattern images, though, be aware that Core Graphics handles the rendering of the pattern image and does so using its standard coordinate system, which is different than the default coordinate system in iOS. As such, images rendered on iOS appear upside down by default unless you flip the coordinates.
```

* CALayer可以设置圆角显示（cornerRadius），也可以设置阴影 (shadowColor)。但是如果layer树中某个layer设置了圆角，树种所有layer的阴影效果都将不显示了。因此若是要有圆角又要阴影，变通方法只能做两个重叠的UIView，一个的layer显示圆角，一个layer显示阴影。

* 变换：要在一个层中添加一个3D或仿射变换，可以分别设置层的transform或affineTransform属性。

```oc
characterView.layer.transform = CATransform3DMakeScale(-1.0,-1.0,1.0);
CGAffineTransform transform = CGAffineTransformMakeRotation(45.0);
backgroundView.layer.affineTransform = transform;
```

* 变形：Quartz Core的渲染能力，使二维图像可以被自由操纵，就好像是三维的。图像可以在一个三维坐标系中以任意角度被旋转，缩放和倾斜。CATransform3D的一套方法提供了一些魔术般的变换效果。

* CABasicAnimation 基础动画
* 显示动画

```oc
CABasicAnimation* fadeAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
fadeAnim.fromValue = [NSNumber numberWithFloat:1.0];//务必设置，否则可能与预期不符
fadeAnim.toValue = [NSNumber numberWithFloat:0.0];
fadeAnim.duration = 1.0;
[theLayer addAnimation:fadeAnim forKey:@"opacity"];
// Change the actual data value in the layer to the final value.
theLayer.opacity = 0.0;
```

* 隐式动画 `theLayer.opacity = 0.0;`

* CAKeyframeAnimation 关键帧动画

关键帧的值时指

```oc
The key frame values are the most important part of a keyframe animation.
These values define the behavior of the animation over the course of its execution.
```

```oc
// create a CGPath that implements two arcs (a bounce)
CGMutablePathRef thePath = CGPathCreateMutable();
CGPathMoveToPoint(thePath,NULL,74.0,74.0);
CGPathAddCurveToPoint(thePath,NULL,74.0,500.0,
                                   320.0,500.0,
                                   320.0,74.0);
CGPathAddCurveToPoint(thePath,NULL,320.0,500.0,
                                   566.0,500.0,
                                   566.0,74.0);
 
CAKeyframeAnimation * theAnimation;
 
// Create the animation object, specifying the position property as the key path.
theAnimation=[CAKeyframeAnimation animationWithKeyPath:@"position"];
theAnimation.path=thePath;
theAnimation.duration=5.0;
 
// Add the animation to the layer.
[theLayer addAnimation:theAnimation forKey:@"position"];
```

* 多个动画可以通过CAAnimationGroup合并到一起

* 手势 Tap点击 Pin捏合 Pan拖移-慢速移动 Swipe滑动-快速移动 Rotation旋转 LongPress长按

* 如何让scrollView禁止惯性滑动，精准定位滑动停靠点

```oc
func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
sizeView.setContentOffset(CGPointMake(CGFloat(self.sizeX), 0), animated: true)
}
```

在这个函数中设置。