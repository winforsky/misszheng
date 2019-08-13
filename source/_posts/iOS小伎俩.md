---
title: iOS小伎俩
comments: false
date: 2019-08-13 14:52:24
tags:
categories:
---

1、 Time Profiler

2、 Allocations

3、 Visual Memory Debugger

以上是摘要部分
<!--more-->

## Time Profiler

### Call Tree

1、Separate by State: This option groups results by your application’s life cycle state and is a useful way to inspect how much work your app is doing and when.

2、Separate by Thread: Each thread should be considered separately. This enables you to understand which threads are responsible for the greatest amount of CPU use.

3、Invert Call Tree: With this option, the stack trace is considered from most recent to least recent.

4、Hide System Libraries: When this option is selected, only symbols from your own app are displayed. It’s often useful to select this option, since usually you only care about where the CPU is spending time in your own code – you can’t do much about how much CPU the system libraries are using!

5、Flatten Recursion: This option treats recursive functions (ones which call themselves) as one entry in each stack trace, rather than multiple.
Top Functions: Enabling this makes Instruments consider the total time spent in a function as the sum of the time directly within that function, as well as the time spent in functions called by that function. So if function A calls B, then A’s time is reported as the time spent in A PLUS the time spent in B. This can be really useful, as it lets you pick the largest time figure each time you descend into the call stack, zeroing in on your most time-consuming methods.

## Allocations

* Allocations =》Generations =〉Mark Generation =〉Growth 查看内存分配增长是因为什么问题导致

* Allocations =》Statistics =〉过滤器 “Instruments”[工程名] =〉# Persistent and # Transient =》通过查看对象的数量来看强引用的排查Strong Reference Cycles

说明：

1. Persistent column keeps a count of the number of objects of each type that currently exist in memory.

2. Transient column shows the number of objects that have existed but have since been deallocated.

3. Persistent objects are using up memory, transient objects have had their memory released.

## Visual Memory Debugger

从XCode 8开始，debug时可以看到内存分配图，调用方式和查看视图层次的操作一样。

the Visual Memory Debugger is a neat tool that can help you further diagnose memory leaks and retain cycles.

Cross-referencing insights from both the Allocations instrument and the Visual Memory Debugger is a powerful technique that can make your debugging workflow a lot more effective.

### 准备工作

1. 编辑项目的scheme =》Edit Scheme选项=》Run选项 =》Diagnostics标签=》Malloc Stack 选项打勾+ Live Allocations Only 选项

2. 运行项目，到Debug导航找到 =》左边：View Memory Graph Hierarchy 选项 =》左边：XXX(次数) =》中间：选中XXX =》右边：Memory inspector 选项 可以看到调用路径

### 窗口描述

the Visual Memory Debugger displays the following information:

1. Heap contents (Debug navigator pane): This shows you the list of all types and instances allocated in memory at the moment your app was paused. Clicking on a type unfolds the row to show you the separate instances of the type in memory.

2. Memory graph (main window): The main window shows a visual representation of objects in memory. The arrows between objects represent the references between them (strong and weak relationships).

3. Memory Inspector (Utilities pane): This includes details such as the class name and hierarchy, and whether a reference is strong or weak.
