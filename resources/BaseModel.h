
#import <Foundation/Foundation.h>
#import <AutoCoding/AutoCoding.h>
#import <Mantle/Mantle.h>


/**
 *  数值类型
 */
typedef NS_ENUM(NSInteger, ClassType) {
    ClassTypeNSNumber = 1,    //数值类型
    ClassTypeNSString = 2,      //指针类型
    ClassTypeNSValue = 3,      //指针类型
    ClassTypeNSArray = 4,  //NSArray  add by linyawen
    ClassTypeNSDictionary = 5,//NSDictionary by linyawen
    ClassTypeNoDefined = 6,       //未定义
   
};

/**
 *  存储本地文件的版本号，以后随着版本上升这个enum也会一直增长
 */
typedef NS_ENUM(NSInteger, ModelVersion) {
    ModelVersion_0 = 0,     // 初始版本，现在1.4（含）之前的版本都是这个值
    ModelVersion_1_5 = 1,
    ModelVersion_1_6 = 2
};

/**
 *  todo: 用各种用例详细测试一下空值的情况
 *  实体基类
    主要是
    1，提供自动序列化功能。
    2，服务端json 自动化解析功能。
    3，统一的接口错误 json 处理功能。
 */
@interface BaseModel : MTLModel <MTLJSONSerializing>
/**
 *  该属性主要是放遍kvo使用，当修改 BaseModel 的任何属性时，都会触发 这个属性的kvo监听。
 */
@property(nonatomic,assign)BOOL needRefresh;
@end
