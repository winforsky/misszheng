---
title: UITableView的大数据处理问题
comments: false
date: 2019-04-09 20:04:03
tags:
categories:
---



以上是摘要部分
<!--more-->

## 一、UITableView

## 二、大数据量的刷新

## 三、缓存高度

### 1)计算高度

使用一个专门的cell用来动态计算cell的高度

```oc
// 根绝数据计算cell的高度
/*
UITableView 对应的Cell
*/
- (CGFloat)heightForModel:(CellDataModel *)dataModel {
    [self setDataModel:dataModel];
    <!-- 如果cell中有UILabel，需要提前指定Label的最大宽度或约束 -->
    <!-- self.textLabel.preferredMaxLayoutWidth = CGRectGetWidth(cell.frame)-20; -->
    //强制立即刷新布局
    [self layoutIfNeeded];
    //额外的 1 是为了留给分割线
    CGFloat cellHeight = [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height+1;
    return cellHeight;
}
```

### 2)缓存高度

```oc
/*
数据模型
*/
@interface CellDataModel : NSObject
/*
中间省去具体的属性
*/
// 该Model对应的Cell高度
@property (nonatomic, assign) CGFloat cellHeight;
@end

/*
tableView的代理实现
*/
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CellDataModel *model = self.dataArr[indexPath.row];
    if (model.cellHeight == 0) {
        //self.tempCell 是专门为计算高度而临时设置的cell
        CGFloat cellHeight = [self.tempCell heightForModel:self.dataArr[indexPath.row]];
        // 缓存给model
        model.cellHeight = cellHeight;
        return cellHeight;
    } else {
        return model.cellHeight;
    }
}
```