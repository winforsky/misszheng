---
title: 学习React学习之道
comments: false
date: 2019-02-14 10:04:20
tags:
categories:
---

记录自己在学习 《[React学习之道](https://github.com/rwieruch/blog_robinwieruch_content/blob/master/the-road-to-learn-react.md)》过程中的一些要点，年纪大了，只能多记多看了，备忘。

跟随使用[create-react-app](https://facebook.github.io/create-react-app/docs/getting-started)实践

以上是摘要部分
<!--more-->

# npm 基础使用

> npm install -g <package> 安装一个全局的包,可以在终端的任何地方使用。

> npm install --save-dev <package> 安装的包只用作开发环境，并不会被作为产品代码发布。

> npm init -y 使用默认值创建项目专属的 node_modules/ 文件夹和 package.json 文件

# react导引

## 关于应用建立

* 使用create-react-app零配置搭建 React 应用解决方案

> `npx create-react-app my-app`

* 模块热替换（HMR）

> 用 create-react-app 创建的项目有一个优点就是可以让你在更改源代码的时候浏览器自
动刷新页面。
> 可以在 create-react-app 中很容易地开启这个工具：在你 React 的入口文件
`src/index.js` 中，添加一些配置代码:

```js
if (module.hot) {
module.hot.accept();
}
```

> 使用 HMR 的话，尽管你的源代码改变了，但是应用的状态也会被保持。应用本身会被重
新加载，而不是页面被重新加载。

## 关于ReactDOM

注意： **ReactDOM.render() 会使用你的 JSX 来替换你的 HTML 中的一个 DOM 节点。**

```js
ReactDOM.render(
    <App />,
    document.getElementById('root')
);
```

> 通过`ReactDOM.render()` 可以很容易地把 React 集成到每一个其他的应用中。

> `ReactDOM.render()` 可以在应用中被多次使用。你可以在多个地方使用它来加载简单的 JSX 语法、单个 React 组件、多个 React 组件或者整个应用。

> 但是在一个纯 React 的应用中，你只会使用一次用来加载整个组件树。

## 关于JSX

* 理解清楚组件、实例和元素之间的区别

> 类=》 组件：声明了一个组件以后，你可以在你项目的任何地方使用它。 `class App extends Component`

> 实例=》实例：类似于HTML标签的使用，`ReactDOM.render(<App />, document.getElementById('root'));`

> element=》元素：元素是组件的构成部分，render() 方法包含了它所返回的元素（element）。
render 方法中的代码看起来和 HTML 非常像，这就是 JSX。

```js
render() {
    var learnReact = "learn React now。"//声明变量，供jsx使用
    return ( //注意这里的()括号
        <div className="App">//[React 文档支持的 HTML 属性](https://reactjs.org/docs/dom-elements.html)
        <h2>Welcome to the Road to {learnReact}</h2>//通过{}引入变量
        </div>
    );
}
```

> .bind vs ()=> passing parameters to onClick

```js
onClick={() => this.onDismiss(item.objectID)}
//arrow functions automatically binds to the parents this scope.
this.onDismiss = this.onDismiss.bind(this);
// When you bind this in a constructor, onDismiss function will receive your components context. However, you still must pass your components function。
onClick={this.onDismiss.bind(this, item.objectID)} //另一种写法
```

> 构造函数中使用`this.onDismiss = this.onDismiss.bind(this);`绑定组件上下文
> 这个this.onDismiss不生效，因为this被替换了

```js
<div className="home-page ui container">
{
    this.state.list.map(function(item) {
    return (
        <ul key={item.objectID}>
            <li>
                <button
                onClick={ () => this.onDismiss(item.objectID)}
                type="button">
                Dismiss
                </button>
            </li>
        </ul>
    );
    })
}
</div>
```

> 这个this.onDismiss不生效，因为this被替换了

```js
<div className="home-page ui container">
{
    this.state.list.map((item) => {
    return (
        <ul key={item.objectID}>
            <li>
                <button
                onClick={ () => this.onDismiss(item.objectID)}
                type="button">
                Dismiss
                </button>
            </li>
        </ul>
    );
    })
}
</div>
```

[Why and how to bind methods in your React component classes?](https://reactkungfu.com/2015/07/why-and-how-to-bind-methods-in-your-react-component-classes/)

```js
// Before (ES 2015)
class InputExample extends React.Component {
  constructor(props) {
    super(props);

    this.state = { text: '' };
    this.change = this.change.bind(this);
  }

  change(ev) {
    this.setState({ text: ev.target.value });
  }

  render() {
    let { text } = this.state;
    return (<input type="text" value={text} onChange={this.change} />);
  }
}
// After (class properties + arrow function syntax)
class InputExample extends React.Component {
  state = { text: '' };
  change = ev => this.setState({text: ev.target.value});

  render() {
    let {text} = this.state;
    return (<input type="text" value={text} onChange={this.change} />);
  }
}
```

> 可以使用花括号（curly braces）把变量引入到 JSX 中。

> 可以使用花括号（curly braces）把JavaScript引入到 JSX 中。

> 在 React 文档支持的 HTML 属性都遵守驼峰命名法（camelCase convention)。

> 关键字（key）属性,在列表发生变化的时候识别其中成员的添加、更改和删除的状态。

## 关于ES6

* var ==》 let 变量 const 常量

* 使用 const 声明的变量不能被改变，但是如果这个变量是数组或者对象的话，它里面持有的内容可以被更新。它里面持有的内容不是不可改变的。

* 当属性名和属性值一致时，可以只写一个。`{list:list}` ==>`{list}`

* 属性名可以通过动态计算获得，如`[keyName]:keyValue`其中keyName可以动态变化

* 箭头函数表达式比普通的函数表达式更加简洁 `function (props) { ... }` ==> `(props) => { ... }`, 务必注意this对象的切换

* `getUserName: function (user) {}` ==》 `getUserName(user) {}`

> 关于**this 对象**的不同行为: 一个普通的
函数表达式总会定义它自己的 this 对象。但是箭头函数表达式仍然会使用包含它的语境
下的 this 对象。不要被这种箭头函数的 this 对象困惑了。

> 关于箭头函数的括号一个值得关注的点: 如果函数只有一个参数，就可以移除掉参
数的括号，但是如果有多个参数，就必须保留这个括号。

> 简洁函数体的返回不用显示声明，这样就可以移除掉函数的 `return({/*保留部分*/})` 表达式。

* 类class

> 类的声明

```js
class Developer {
    //类都有一个用来实例化自己的构造函数。这个构造函数可以用来传入参数来赋给类的实例。
    constructor(firstname, lastname) {
        this.firstname = firstname;
        this.lastname = lastname;
    }
    //类可以定义函数。因为这个函数被关联给了类，所以它被称为方法。通常它被当称为类的方法。
    getName() {
        return this.firstname + ' ' + this.lastname;
    }
}
```

> 类的实例化 new

```js
const robin = new Developer('Robin', 'Wieruch');
console.log(robin.getName());
```

> 在 React 中，通过继承类的方式来声明组件 `class App extends Component`

# react基础

## 组件内部状态 State, 单向数据流

> 组件内部状态也被称为局部状态，允许你保存、修改和删除存储在组件内部的属性。
> 使用 ES6 类组件可以在构造函数中初始化组件的状态。
> 构造函数只会在组件初始化时调用一次。

```js
constructor(props) {
    //super(props)会在你的构造函数中设置 this.props 以供在构造函数中访问它们。
    // 否则当在构造函数中访问 this.props ，会得到 undefined。
    super(props);//必须：需要强制调用，因为这个组件是 Component 的子类。
    this.state = {//没有上一步，这里会出问题
        list: list,
    };
}
```

> 不要直接修改 state。你必须使用 setState() 方法来修改它。
> 每次你修改组件的内部状态，组件的 render 方法会再次运行。这样你可以简单地修改组件内部状态，确保组件重新渲染并且展示从内部状态获取到的正确数据。