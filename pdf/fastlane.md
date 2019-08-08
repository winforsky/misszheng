# How to use fastlane

## 有什么用

## 安装
```
sudo gem install fastlane
```

## 基础使用
### 初始化
```
fastlane init
```
> 初始化过程中建议选择一种操作，让流程走通
> 需要输入苹果开发者账号
> 需要输入一些必要的信息

操作完成之后会在项目的目录下生成`fastlane`目录，下面有
* 目录`Appfile`，记录需要的账号信息、app信息等
* 目录`Fastfile`，用于定制操作流程，可以根据需要定制不同的流程
* 目录`Snapfile`，用于定义要截图的机型和语言
* 文件`SnapshotHelper.swift`，用于截图的辅助，后面有用到

### 截图
在项目做以下操作：

1)为你的项目添加一个UI_Test_Target，系统默认已经提供your_UI_Test_target_Name，如果没有，请添加

2) 在your_UI_Test_target_Name文件夹下添加` ./fastlane/SnapshotHelper.swift`引用

> 如果在Object-c的工程，会提示添加`your_UI_Test_target_Name-Bridging-Header.h`桥接文件，请点击`确定`

> 在Object-c 调用swift方法，需要使用`#import "your_UI_Test_target_Name-Swift.h"`导入文件

**知识扩展**
> 在Objective - C工程或者文件使用Swift的文件
当在OC文件中调用Swift文件中的类的时候，首先在OC文件中要加上 #import "
ProjectName-swift.h”(名字组成:工程名-swift)。引入后，具体类的使用，直接按照OC的方式使用即可。

> 在Swift工程或者文件使用Objective - C文件
当在Swift中使用OC文件的时候，只需在桥接文件即projectName-Bridging-Header.h文件中引入需要的头文件。
具体使用，按照对应的Swift语法结构来即可。



3) 在UITest文件的`setup`方法中调用 `setupSnapshot(app)` 来启动

* swift
```
let app = XCUIApplication()
setupSnapshot(app)
app.launch()
```

* object-c
```
XCUIApplication *app = [[XCUIApplication alloc] init];
[Snapshot setupSnapshot:app];
[app launch];
```

4) 在需要截屏的地方调用 `snapshot("0Launch")`来触发截屏

5) 确保在`Manage schemes`中新建的target已经被添加

6) 确保在`Manage schemes`中项目的scheme是 `Shared`状态

7) 到项目目录下运行 `fastlane snapshot`

### 运行测试

### 发布beta版本

### 发布正式版本

