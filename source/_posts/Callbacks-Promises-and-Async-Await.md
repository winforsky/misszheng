---
title: 'Callbacks, Promises and Async/Await'
comments: false
date: 2019-02-26 11:09:22
tags:
categories:
---

以上是摘要部分
<!--more-->

# 原文

来自 [Callbacks, Promises and Async/Await](https://medium.com/front-end-weekly/callbacks-promises-and-async-await-ad4756e01d90)

# 异步编程

有2种解决方法：

* callback 回调函数风格
* Promises 风格

# callback 回调函数

* callback回调函数 是指函数A作为一个参数传入另外一个函数B中，并在函数B中被调用。

```js
function printString(string, callback){
  setTimeout(
    () => {
      console.log(string)
      callback()
    },
    Math.floor(Math.random() * 100) + 1
  )
}
```

* callback回调函数的多级嵌套引入了回调黑洞的问题

```js
function printAll(){
  printString("A", () => {
    printString("B", () => {
      printString("C", () => {})
    })
  })
}
printAll()
```

# Promises 用来解决回调黑洞

* 将整个功能函数包含在Promises中，用resolve,reject来替代callback回调函数。
* resolve返回正常结果=》调用方用then来处理
* reject返回错误结果=》调用方用catch来处理

```js
function printString(string){
  return new Promise((resolve, reject) => {
    setTimeout(
      () => {
       console.log(string)
       resolve()
      },
     Math.floor(Math.random() * 100) + 1
    )
  })
}
```

调用使用Promises重写之后的方法，看起来是不是优雅很多

```js
function printAll(){
  printString("A")
  .then(() => {
    return printString("B")
  })
  .then(() => {
    return printString("C")
  })
}
printAll()
```

这种调用方法也称为Promise Chain链式调用。

因为链式调用的方法中只有一行，可以使用箭头函数进一步进行精简。

```js
function printAll(){
  printString("A")
  .then(() => printString("B"))
  .then(() => printString("C"))
}
printAll()
```

# Await Promises的语法糖，基于Promises的语法上使用

使用await使得异步编程变得和同步编程一样容易被人理解。

```js
async function printAll(){
  await printString("A")
  await printString("B")
  await printString("C")
}
printAll()
```

注意这里的async，

* 第一，是为了让JS知道我们正在使用 async/await 语法糖。
* 第二，同时也可以让外部根据需要判断是否需要使用await。

这意味着你不能在全局global级别使用await，如果真的需要的话，通常需要wrapper包含。

大多数的JS代码是在函数内部运行，因此这也不算什么大问题。

# 还有一个返回值的问题

上面的示例函数是一个独立的函数，没有返回值，此时我们需要关系的仅仅是执行顺序。

但是当你在下一个函数中需要上一个函数的返回值，并将函数的返回值继续向下传递时，这需要怎么操作？

下面使用一个新的例子来做示范：

## callback回调函数

声明

```js
function addString(previous, current, callback){
  setTimeout(
    () => {
      callback((previous + ' ' + current))
    },
    Math.floor(Math.random() * 100) + 1
  )
}
```

使用

```js
function addAll(){
  addString('', 'A', result => {
    addString(result, 'B', result => {
      addString(result, 'C', result => {
       console.log(result) // Prints out " A B C"
      })
    })
  })
}
addAll()
```

## Promises

声明

```js
function addString(previous, current){
  return new Promise((resolve, reject) => {
    setTimeout(
      () => {
        resolve(previous + ' ' + current)
      },
      Math.floor(Math.random() * 100) + 1
    )
  })
}
```

使用

```js
function addAll(){  
  addString('', 'A')
  .then(result => {
    return addString(result, 'B')
  })
  .then(result => {
    return addString(result, 'C')
  })
  .then(result => {
    console.log(result) // Prints out " A B C"
  })
}
addAll()
```

## Await 基于Promise

使用

```js
async function addAll(){
  let toPrint = ''
  toPrint = await addString(toPrint, 'A')
  toPrint = await addString(toPrint, 'B')
  toPrint = await addString(toPrint, 'C')
  console.log(toPrint) // Prints out " A B C"
}
addAll()
```

简单说法就是：

* await是将异步操作同步化。

* 当需要向下传递参数时，resolve(paramToNextFunction)