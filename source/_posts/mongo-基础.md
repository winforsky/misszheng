---
title: mongo 基础
comments: false
date: 2019-01-22 09:45:53
tags:
categories:
---

最近参加mongodb university 提供的mongodb基础入门的课程，学习mongodb的基础入门知识，现记录一下。

课程分为三部分+考试

1）Chapter 1: Introduction
Introduction to MongoDB, Compass, and Basic Queries

2）Chapter 2: The MongoDB Query Language + Atlas
Create, Read, Update, and Delete (CRUD) operations; cursors, projections, Atlas free-tier basics.

3）Chapter 3: Deeper Dive on the MongoDB Query Language
Query operators: element operators, logical operators, array operators, and the regex operator

4）Final Exam
Any topic in this course might be addressed in the final exam.

课程由浅入深，手把手教会你如何操作，讲解比较细，有兴趣的朋友可以自行去了解。
<!--more-->

## 1）Chapter 1: Introduction
`Introduction to MongoDB, Compass, and Basic Queries`
本章节主要介绍了MongoDB的基本概念，MongoDB官方图形界面工具Compass的基本使用。
### MongoDB的基本概念
* Database 数据库， use myNewDB 数据库myNewDB不存在时会自动创建
* Collection 集合， db.myNewCollection1.insertOne( { x: 1 } ) 集合myNewCollection1 不存在时会自动创建
* Document 文档  =》BSON =》{}

**由dbName.collectionName组成namespace**

**都是{}, 无论是document，还是filter条件，还是options选项**



### Compass的安装
* MongoDB官方推出的图形界面工具，功能强大，随用随知道。
* 从官网下载安装即可

### Compass的基本使用
* 连接数据库服务器：按照基础设置连接官方为本次课程准备的数据库服务器。
* 查看数据库信息：连接上之后可以看到当前数据库服务器上提供的数据库及其占用空间、集合数以及索引数量等信息。
* 查看数据库下的某个数据集合的具体信息：选中数据库下的某个数据集合点击进去即可查看到相关信息，包含Documents、Aggregations、Schema、Explain Plan、Indexes、Indexes等
在SChema标签下，可以看到当前collection中的document的字段相关信息，包含字段名称、字段数据类型、字段数据类型分布比例，字段数据内容等

支持的字段数据类型，[参见官方链接](https://docs.mongodb.com/manual/reference/bson-types/)

* 设置filter条件筛选数据，只需要在Schema标签下，选中某个字段即可看到在工具栏上方的filter中已经设置好对应的筛选条件，点击analyze按钮即可筛选数据。
* 更多强大功能，请自行摸索。

##注意Geographical Data## 
```
MongoDB Compass uses a 3rd party plugin for the geographical visualization of geospatial fields in your documents.
```
```
enable geographical visualization => Help -> Privacy Settings From MongoDB Compass Menu.  
```

## 2）Chapter 2: The MongoDB Query Language + Atlas
`Create, Read, Update, and Delete (CRUD) operations; cursors, projections, Atlas free-tier basics`

* CRUD基本概念
* mongo shell的安装
* mongo shell的基本使用

### 创建 Create by insert\insertOne\insertMany

```
db.collection.insert(
   <document or array of documents>,
   {
     writeConcern: <document>,//写入协议，不建议在事务中明确指定 Do not explicitly set the write concern for the operation if run in a transaction
     ordered: <boolean>//是否有序插入，默认true
   }
)
```

```
db.collection.insertOne(
   <document>,
   {
      writeConcern: <document>
   }
)
```

```
db.collection.insertMany(
   [ <document 1> , <document 2>, ... ],
   {
      writeConcern: <document>,
      ordered: <boolean>
   }
)
```

### 读取 Read by find、findOne

```
db.collection.find(query, projection)
```

```
db.collection.findOne(query, projection)
```
其中

* `query` 定义查询条件,使用[查询操作运算符](https://docs.mongodb.com/manual/reference/operator/)

##查询条件是数组时需要注意##

1、加了[]时表示完全匹配

2、不加[]时表示包含匹配

3、指定数组字段的索引时表示该顺序下的匹配

* `projection`定义需要返回等字段名称，0不返回，1返回

```
{ field1: <value>, field2: <value> ... }
```

* `Cursor` 游标用来指向返回的数据集合，后续操作可以直接用来获取数据

### 更新 Update by  update\updateOne\updateMany 
```
db.collection.update(
   <query>,//筛选条件
   <update>,//更新操作，包含[更新操作运算符](https://docs.mongodb.com/manual/reference/operator/update/)
   {
     upsert: <boolean>,//满足筛选条件时update or 不满足筛选条件时 insert，默认false
     multi: <boolean>,//当多条数据满足筛选条件时更新多条，默认false
     writeConcern: <document>,//
     collation: <document>,//string类型数据比较时规则验证
     arrayFilters: [ <filterdocument1>, ... ]
   }//更新操作选项
)
```
```
db.collection.updateOne(
   <filter>,
   <update>,
   {
     upsert: <boolean>,
     writeConcern: <document>,
     collation: <document>,
     arrayFilters: [ <filterdocument1>, ... ]
   }
)
```
```
db.collection.updateMany(
   <filter>,
   <update>,
   {
     upsert: <boolean>,
     writeConcern: <document>,
     collation: <document>,
     arrayFilters: [ <filterdocument1>, ... ]
   }
)
```

* 

```
```
### 删除 Delete by deleteOne\deleteMany
```
db.collection.deleteOne(
   <filter>,
   {
      writeConcern: <document>,
      collation: <document>
   }
)
```
```
db.collection.deleteMany(
   <filter>,
   {
      writeConcern: <document>,
      collation: <document>
   }
)
```

通过以上的学习，基本掌握了mongodb的基本使用。

## 3）Chapter 3: Deeper Dive on the MongoDB Query Language
`Query operators: element operators, logical operators, array operators, and the regex operator`

### 比较操作符
|Type|	Number|	Notes|
| ------ | ------ | ------ |
|`$eq`| 等于||
|`$ne`| 不等于||
|`$gt`| 大于||
|`$gte`| 大于等于||
|`$lt`| 小于||
|`$lte`| 小于等于||
|`$in`| 在数组范围内||
|`$nin`| 不在数组范围内||

### 元素操作符

|Type|	Number|	Notes|
| ------ | ------ | ------ |
|`$exists`| 根据元素是否存在来筛选| `false`时等价于对于元素值为`null`|
|`$type`| 根据元素值的类型来筛选|值类型参见最后的附录|

### 逻辑操作符
|Type|	Number|	Notes|
| ------ | ------ | ------ |
|`$or`| 等于||
|`$and`| 不等于||
|`$not`| 大于||
|`$nor`| 大于等于||

**筛选条件是数组集合**

* {$or: [{depth: 0}, {watlev: "always dry"}]}
* {"$or": [{"watlev": {"$eq": "always dry"}}, {"depth": {"$eq": 0}}]}
* 上面2个的逻辑是一致
* 数组中的筛选条件可以是相同字段的多种条件组合


### 数组操作符
**操作对象必须时数组**
|Type|	Number|	Notes|
| ------ | ------ | ------ |
|`$all`|数组内的元素必须全包含才匹配|{sections: {$all:[ "AG1", "MD1", "OA1"]}}}
|`$size`|数组的大小必须相等才匹配|{sections: {$size:2}}|
|`$elemmatch`|数组内的元素为object时，object必须满足匹配条件时才匹配|{sections: {$elemmatch:{product: "xyz", score: 8}}}|

### 表达式操作符
|Type|	Number|	Notes|
| ------ | ------ | ------ |
|`$expr`|允许用户使用查询条件表达式来匹配|`{ $expr: { $gt: [ "$spent" , "$budget" ] } }`  spent字段的数据>budget字段的数据|
|`$jsonSchema`|匹配给定的JSON格式|`MongoDB 3.6` 新引入，使用时需要注意版本，[点击查看详细使用说明](https://docs.mongodb.com/manual/reference/operator/query/jsonSchema/#op._S_jsonSchema)|
|`$mod`|取余数匹配，必须2个值，【除数，余数】|`{ field: { $mod: [ divisor, remainder ] } }` |
|`$regex`|正则匹配||
|`$text`|文本搜索，需要在建立text索引的字段上进行.||
|`$where`|根据js表达式返回的bool值进行匹配|完整的js解析器|

**`$expr`的筛选条件可以很复杂**

通过以上学习，基本掌握了Mongodb筛选条件查询的操作。

## 4）Final Exam
`Any topic in this course might be addressed in the final exam`


## 附录
### 值类型对应的名称

|Type|	Number|	Alias|	Notes|
| ------ | ------ | ------ | ------ |
|Double|	1|	“double”|	 
|String|	2|	“string”|	 
|Object|	3|	“object”|	 
|Array|	4|	“array”	 |
|Binary data|	5|	“binData”	| 
|Undefined|	6|	“undefined”|	Deprecated.
|ObjectId|	7|	“objectId”|	 
|Boolean|	8|	“bool”|	 
|Date|	9|	“date”	| 
|Null|	10|	“null”	| 
|Regular Expression|	11|	“regex”	 |
|DBPointer|	12|	“dbPointer”|	Deprecated.
|JavaScript|	13|	“javascript”|	 
|Symbol|	14|	“symbol”|	Deprecated.
|JavaScript (with scope)|	15|	“javascriptWithScope”|	 
|32-bit integer|	16|	“int”|	 
|Timestamp|	17|	“timestamp”	| 
|64-bit integer|	18|	“long”	| 
|Decimal128|	19|	“decimal”|	New in version 3.4.
|Min key|	-1|	“minKey”|	 
|Max key|	127|	“maxKey”|
| ------ | ------ | ------ | ------ |
