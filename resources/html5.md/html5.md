
# HTML5基础知识

[CANVAS——Draw on the Web](https://airingursb.gitbooks.io/canvas/20.html)

## head中的元素

|标签|描述|其他|
|-|-|-|
|head|定义文档的信息||
|title|定义文档的标题||
|base|定义页面链接标签的默认链接地址||
|link|定义一个文档和外部资源之间的关系||
|meta|定义HTML文档中的元数据||
|script|定义客户端的脚本文件||
|style|定义HTML文档的样式文件||

## body中的元素

|标签|描述|其他|
|-|-|-|
|div|||
|canvas|||
|p|||
|pre|||

## 文档对象模型DOM

* window对象是DOM的最高一级，需要对这个对象进行检测来确保开始使用Canvas应用程序之前已经加载来所有的资源和代码。
* document对象包含所有在HTML页面上的HTML标签，需要在这个对象中检索出可供操作的标签。

* JS的放置位置，或放在head中，或最近有趋势是放置</body>之前，或放置在外部文件中，无论放置在何地，使用前都需要检查整个页面是否已经加载完毕。

## 画布canvas

使用步骤

`window.onload = function() {`需要整个页面加载完毕后开始

1、先获取canvas对象
`var canvas = document.getElementById("canvas");`

`canvas`是透明的，如果不设置背景色，那么它就会被`<body>`纹理所覆盖，想要使其拥有背景色（白色），只有绘制矩形覆盖`canvas`这一个方法。

2、再获得上下文环境
`var context = canva.getContext("2d");`

类比: 上下文环境 可以理解为 一支用来绘画的笔

想象场景: 使用画笔在画布上画图, 动笔之前需要先构思好布局&位置，设置好大小&颜色等，以上动作完成之后才开始真正的画图。

3、画图

`canvas`是基于状态的绘制，之前的操作是确定好状态，最后一步才是绘制。

* 画线条

步骤

0、开始绘制beginPath

1、移动画笔到线条的起点位置moveTo

2、移动画笔到指定的终点位置lineTo

3、设置画笔的大小&颜色lineWidth&strokeStyle&fillStyle

3.1、设置闭合路径closePath【可选，根据需要使用】

4、确定绘画：描边stroke&填充fill

闭合closePath是指将绘画路径完成闭合的动作，如三角形只画前面2笔，后面的一笔会根据闭合自动构建。

所以需要根据实际情况判定是否需要closePath进行闭合的操作。

* 画矩形rect

实现方法1、 使用上面的画线条画4条线

实现方法2、 使用rect方法直接画

### 关于线条属性

* lineCap定义上下文中线的端点形态，butt默认&round圆形&square矩形，只在起点和终点位置的端点有效
* lineJoin定义上下文中两条线相交产生的拐角，miter默认&bevel对角线斜角&round圆形
* lineWidth定义上下文中线的宽度
* strokeStyle&fillStyle定义上下文中描边&填充的样式

### 关于渐变

步骤

1、添加渐变线, 2个基本选项：线性&径向

* 线性渐变创建一个水平、垂直或者对角线的填充图案。

`var grd = context.createLinearGradient(xstart,ystart,xend,yend);`

其中的坐标是相对于context的实际坐标位置。

渐变线的起点和终点不一定要在图像内，颜色断点的位置也是一样的。

但是如果图像的范围大于渐变线，那么在渐变线范围之外，就会自动填充离端点最近的断点的颜色。

* 径向渐变自中心点创建一个放射状填充。

`var grd = context.createRadialGradient(x0,y0,r0,x1,y1,r1);`

2、为渐变线设置关键点

* stop取值范围0-1的浮点数，代表断点到(xstart,ystart)的距离占整个渐变色长度是比例。

`grd.addColorStop(stop,color);`

3、应用渐变

```js
context.fillStyle = grd;
context.strokeStyle = grd;
```

### 关于填充样式

纹理 就是 图案的重复

填充图案通过createPattern(img, repeat-style)来初始化

* img表示待填充的图案

```js
var img = new Image();//创建Image对象
img.src = "x.jpg";//为Image对象指定图片源
img.onload=function(){//注意图片有一个加载过程
```

Image的onload事件，它的作用是对图片进行预加载处理，即在图片加载完成后才立即除非其后function的代码体。

这个是必须的，如果不写的话，画布将会显示黑屏。因为没有等待图片加载完成就填充纹理，导致浏览器找不到图片。

* repeat-style表示图片的填充类型，有4种：

平面重复`repeat`&X轴重复`repeat-x`&Y轴重复`repeat-y`&不重复`no-repeat`

* 填充纹理

```js
var pattern = context.createPattern(img,"repeat");
context.fillStyle = pattern;
```

## 绘制曲线

### 画圆弧arc

有四种方法

* 标准圆弧arc(x,y,radius,startAngle,endAngle,anticlockwise)

> x,y,radius三个参数，分别是圆心坐标与圆半径。

> startAngle、endAngle使用的是弧度值，不是角度值。弧度的规定是绝对的。

> anticlockwise表示绘制的方法，默认false顺时针绘制，true逆时针绘制

弧度的绝对值说明

```js
    1.5Pi
1Pi         0Pi 或 2Pi
    0.5Pi
```

* 复杂圆弧arcTo(x1,y1,x2,y2,radius)

> 以给定的半径绘制一条弧线，圆弧的起点与当前路径的位置到(x1, y1)点的直线相切，圆弧的终点与(x1, y1)点到(x2, y2)的直线相切。

> 其通常配合moveTo()或lineTo()使用。

> 其能力是可以被更为简单的arc()替代的，其复杂就复杂在绘制方法上使用了切点。

* 二次贝塞尔曲线quadraticCurveTo(cpx,cpy,x,y)

> P0是起始点，所以通常搭配moveTo()或lineTo()使用。P1(cpx, cpy)是控制点，P2(x, y)是终止点，它们不是相切的关系。

> 贝塞尔曲线是一条由起始点、终止点和控制点所确定的曲线。而n阶贝塞尔曲线就有n-1个控制点。

> 推荐一个在线转换器 [Canvas Quadratic Curve Example](http://blogs.sitepointstatic.com/examples/tech/canvas-curves/quadratic-curve.html)

* 三次贝塞尔曲线bezierCurveTo(cp1x,cp1y,cp2x,cp2y,x,y)

> 传入的6个参数分别为控制点cp1 (cp1x, cp1y)，控制点cp2 (cp2x, cp2y)，与终止点 (x, y)。
> 推荐一个在线转换器 [Canvas Bézier Curve Example](http://blogs.sitepointstatic.com/examples/tech/canvas-curves/bezier-curve.html)

## 保存和恢复Canvas状态

> 保存 `cxt.save();//保存历史状态，完成本次绘画时再恢复`

> 恢复 `cxt.restore();//恢复历史状态`

## 图形变换

图形变换是指用数学方法调整所绘形状的物理属性，其实质是坐标变形。所有的变换都依赖于后台的数学矩阵运算。

变换是基于上一次的context状态进行变换，所以需要注意状态的保存和恢复。

因此建议：

> 使用图形变换的时候必须搭配save()与restore()方法，一方面重置旋转角度，另一方面重置坐标系原点。

> 在每次平移之前使用context.save()，在每次绘制之后，使用context.restore()。

* 平移变换：translate(x,y)

* 旋转变换：rotate(deg)

> deg是弧度，不是角度

> 这个旋转是以坐标系的原点（0，0）为圆心进行的顺时针旋转。

> 每次旋转都以正方形左上角顶点为原点进行旋转。

> 在使用rotate()之前，通常需要配合使用translate()平移坐标系，确定旋转的圆心。即，旋转变换通常搭配平移变换使用的。

* 缩放变换：scale(sx,sy)

> sx,sy两个参数分别是水平方向和垂直方向上对象的缩放倍数。

对于缩放变换有两点问题需要注意：

> 缩放时，图像左上角坐标的位置也会对应缩放。

> 缩放时，图像线条的粗细也会对应缩放。

比如：左上角的坐标是（50，50），线条宽度是5px，但是放大2倍后，左上角坐标变成了（100，100），线条宽度变成了10px。

很遗憾，没有什么好的方法去解决这些副作用。

平移变换、旋转变换、缩放变换都属于坐标变换，或者说是画布变换。

因此，缩放并非缩放的是图像，而是**整个坐标系、整个画布**！就像是对坐标系的单位距离缩放了一样，所以坐标和线条都会进行缩放。仔细想想，这一切是不是挺神奇的。

* 变换矩阵：transform(a,b,c,d,e,f)

> a c e  => 水平缩放(1) 垂直倾斜(0) 水平位移(0)

> b d f  => 水平倾斜(0) 垂直缩放(1) 垂直位移(0)

> 0 0 1  =>     0         0          1

当我们想对一个图形进行变换的时候，只要对变换矩阵相应的参数进行操作，操作之后，对图形的各个定点的坐标分别乘以这个矩阵，就能得到新的定点的坐标。

```js
transform()方法的行为相对于由 rotate(),scale(), translate(), or transform() 完成的其他变换。
例如：如果我们已经将绘图设置为放到两倍，则 transform() 方法会把绘图放大两倍，那么我们的绘图最终将放大四倍。这一点和之前的变换是一样的。
```

建议使用transform()的时候，可以在如下几个情况下使用：

> 使用context.transform (1,0,0,1,dx,dy)代替context.translate(dx,dy)

> 使用context.transform(sx,0,0,sy,0,0)代替context.scale(sx, sy)

> 使用context.transform(0,b,c,0,0,0)来实现倾斜效果(最实用)。

* context.setTransform(a,b,c,d,e,f)方法

> 参数的意义与transform(a,b,c,d,e,f)一致

> 不同的是：调用 setTransform() 时，它都会重置前一个变换矩阵然后构建新的矩阵

## 文本API

* 属性 font：文本内容的当前字体属性

> context.font = "[font-style] [font-variant] [font-weight] [font-size/line-height] [font-family]"

font-style:默认normal&斜体italic&倾斜oblique

font-variant:默认normal&小型大写字母的字体small-caps

font-weight:默认normal&粗体bold&更粗bolder&更细lighter&具体大小100-400-700-900

font-size:设置字体的尺寸，xx-small x-small small medium[默认] large x-large xx-large 具体大小，单位px

line-height:设置行间的距离（行高）

* 属性 textAlign：文本内容的当前对齐方式 【水平对齐】

context.textAlign="center|end|left|right|start";

* 属性 textBaseline：在绘制文本时使用的当前文本基线【垂直对齐】

context.textBaseline="alphabetic|top|hanging|middle|ideographic|bottom";

* 方法 fillText()在画布上绘制“被填充的”文本【填充】
* 方法 strokeText()在画布上绘制文本（无填充）【中空】

* 方法 measureText()返回包含指定文本对象的宽度

> 文本度量使用measureText()方法实现，这个api在换行显示判断中会有奇效。

> 通过context.measureText(text).width;来实现判断在对话的字符长度超出一定值时换行显示。

显示文字的三步骤：

1、设置font字体

2、设置fillStyle字体颜色

3、使用fillText显示文字

## 阴影效果与图像合成

创建阴影效果需要操作以下4个属性：
> context.shadowColor：阴影颜色。[必须设置]

> context.shadowOffsetX：阴影x轴位移。正值向右，负值向左。[三至少选一]

> context.shadowOffsetY：阴影y轴位移。正值向下，负值向上。[三至少选一]

> context.shadowBlur：阴影模糊滤镜。数据越大，扩散程度越大。[三至少选一]

## 全局透明 globalAlpha

* 默认值为1.0，代表完全不透明，取值范围是0.0（完全透明）~1.0（完全不透明）

## 图像合成globalCompositeOperation

* globalCompositeOperation属性设置或返回如何将一个源（新的）图像绘制到目标（已有）的图像上。

> 源图像 = 您打算放置到画布上的绘图。

> 目标图像 = 您已经放置在画布上的绘图。

|值|描述|
|-|-|
|source-over|默认。在目标图像上显示源图像。|
|source-atop|在目标图像顶部显示源图像。源图像位于目标图像之外的部分是不可见的。|
|source-in|在目标图像中显示源图像。只有目标图像内的源图像部分会显示，目标图像是透明的。|
|source-out|在目标图像之外显示源图像。只会显示目标图像之外源图像部分，目标图像是透明的。|
|destination-over|在源图像上方显示目标图像。|
|destination-atop|在源图像顶部显示目标图像。源图像之外的目标图像部分不会被显示。|
|destination-in|在源图像中显示目标图像。只有源图像内的目标图像部分会被显示，源图像是透明的。|
|destination-out|在源图像外显示目标图像。只有源图像外的目标图像部分会被显示，源图像是透明的。|
|lighter|显示源图像 + 目标图像。|
|copy|显示源图像。忽略目标图像。|
|xor|使用异或操作对源图像与目标图像进行组合。|

详见[Canvas之globalCompositeOperation属性详解](https://blog.csdn.net/laijieyao/article/details/41862473)

## 裁剪区域clip()

使用Canvas绘制图像时经常会遇到想要只保留图像的一部分的情况，这时可以使用canvas API的图像裁剪功能来实现这一想法。

Canvas API的图像裁剪功能是指：在画布内使用路径，只绘制该路径内所包含区域的图像，不绘制路径外的图像。这有点像Flash中的图层遮罩。

必须先创建好路径，创建完整后，调用clip()方法来设置裁剪区域。

需要注意的是裁剪是对画布进行的，裁切后的画布不能恢复到原来的大小，也就是说画布是越切越小的。

要想保证最后仍然能在canvas最初定义的大小下绘图需要注意save()和restore()。

画布是先裁切完了再进行绘图。并不一定非要是图片，路径也可以放进去~

```js
//开始创建路径
cxt.beginPath();
//裁剪画布从(0，0)点至(500，500)的正方形
cxt.rect(0,0,500,500);
//设置裁剪区域，只绘制该路径内所包含区域的图像
cxt.clip();
```

## 绘制图像drawImage()

> drawImage()是一个很关键的方法，它可以引入图像、画布、视频，并对其进行缩放或裁剪。

有三种表现形式：

* 三参数：context.drawImage(img,x,y)
* 五参数：context.drawImage(img,x,y,width,height)
* 九参数：context.drawImage(img,sx,sy,swidth,sheight,x,y,width,height)

|参数|描述|
|-|-|
|img|规定要使用的图像、画布或视频。|
|sx|可选。开始剪切的 x 坐标位置。|
|sy|可选。开始剪切的 y 坐标位置。|
|swidth|可选。被剪切图像的宽度。|
|sheight|可选。被剪切图像的高度。|
|x|在画布上放置图像的 x 坐标位置。|
|y|在画布上放置图像的 y 坐标位置。|
|width|可选。要使用的图像的宽度。（伸展或缩小图像）|
|height|可选。要使用的图像的高度。（伸展或缩小图像）|

## 非零环绕规则 确定是在外面还是在里面

非零环绕原则来判断哪块区域是里面，哪块区域是外面。

接下来，我们具体来看下什么是非零环绕原则。
非零环绕原则

首先，我们得给图形确定一条路径，只要“一笔画”并且“不走重复路线”就可以了。

如图，标出的是其中的一种路径方向。

我们先假定路径的正方向为1（其实为-1啥的也都可以，正负方向互为相反数，不是0就行），那么反方向就是其相反数-1。

然后，我们在子路径切割的几块区域内的任意一点各取一条方向任意的射线，这里我只取了三个区域的射线为例，来判断这三块区域是“里面”还是“外面”。

接下来，我们就来判断了。

S1中引出的射线L1，与S1的子路径的正方向相交，那么我们就给计数器+1，结果为+1，在外面。

S2中引出的射线L2，与两条子路径的正方向相交，计数器+2，结果为+2，在外面。

S3中引出的射线L3，与两条子路径相交，但是其中有一条的反方向，计数器+1-1，结果为0，在里面。

没错，只要结果不为0，该射线所在的区域就在外面。

* 非零环绕原则的应用

2个不同路径方向的同心圆在一起会是什么效果？

同心圆环。

一正一负 为0，在里面。

镂空剪纸效果

* 需要注意

不能在绘制镂空三角形和绘制镂空矩形的方法里使用beginPath()和closePath()，不然它们就会是新的路径、新的图形，而不是剪纸的子路径、子图形，就无法使用非零环绕原则。

逃逸途中遇到的 顺时针 路径数 + 逆时针 路径数 想加，0为空，在里面。

* 橡皮擦clearRect

> clearRect(x,y,w,h)清空指定矩形上的画布上的像素。

* 判定点是否在路径上isPointInPath()

> context.isPointInPath(x,y)

## 像素操作API

还有最后六个关于像素操作的API，基本不会用到，这里就不详细说了。

列表如下。
|属性|描述|
|-|-|
|width|返回 ImageData 对象的宽度|
|height|返回 ImageData 对象的高度|
|data|返回一个对象，其包含指定的 ImageData 对象的图像数据|

|方法|描述|
|-|-|
|createImageData()|创建新的、空白的 ImageData 对象|
|getImageData()|返回 ImageData 对象，该对象为画布上指定的矩形复制像素数据|
|putImageData()|把图像数据（从指定的 ImageData 对象）放回画布上|

## 结束语
