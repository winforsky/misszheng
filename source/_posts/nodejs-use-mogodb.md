---
title: nodejs use mogodb
comments: false
date: 2019-02-18 19:46:07
tags:
categories:
---

以上是摘要部分
<!--more-->

cluter config:

配置用户名密码：
username: m220student
password: m220password2

配置白名单：
IP Whitelist: Allow Access from Anywhere

数据恢复：
mongorestore --drop --gzip --uri \
  "mongodb+srv://m220student:m220password2@<YOUR_CLUSTER_URI>" data

例如：
mongo "mongodb+srv://mflix-nqc3b.azure.mongodb.net/test" --username m220student
mongorestore --drop --gzip --uri "mongodb+srv://m220student:m220password2@mflix-nqc3b.azure.mongodb.net/test" data

npm  test -t xxx
expect(A).toBe("A result"): 期望A的结果是"A result"
好文章推荐：
[callbacks-promises-and-async-await](https://medium.com/front-end-weekly/callbacks-promises-and-async-await-ad4756e01d90)
callback：回调函数
promise：异步执行函数的方法之一
async/await：异步执行函数的方法之一

function(params, callback(result, error))
function(params).then(result=>{}).catch(e=>{})
Asynchronous Programming in Node.js

```
If a callback isn't provided, asynchronous methods in the Node driver will return a Promise.

This is correct. The asynchronous driver methods will inspect whether a callback was provided and return a Promise if one isn't.
All await statements should be surround by a try/catch block.

This is correct. This is how rejected Promises are caught and handled.
To use the await keyword, the enclosing function must be marked async .

This is correct. Failing to do so will cause errors. All functions provided to you in the mflix-js project have been properly marked.
Incorrect Answer

The MongoDB Node driver only supports callbacks.

If a callback is not provided to an asynchronous method, the driver will return a Promise.
```

问题描述：

```
Problem:

User Story 用户故事

"As a user, I'd like to be able to search movies by country and see a list of movie titles. I should be able to specify a comma-separated list of countries to search multiple countries."

Task 实现任务

Implement the getMoviesByCountry method in src/dao/moviesDAO.js to search movies by country and use projection to return the title field. The _id field will be returned by default.

MFlix Functionality 涉及功能

Once you complete this ticket, the UI will allow movie searches by one or more countries.

Testing and Running the Application 测试和运行

Make sure to look at the tests in projection.test.js to understand what is expected.

You can run the unit tests for this ticket by running:

npm test -t projection
Once the unit tests are passing, run the application with:

npm start
Now proceed to the status page to run the full suite of integration tests and get your validation code.

After passing the relevant unit tests, what is the validation code for Projection?
```
