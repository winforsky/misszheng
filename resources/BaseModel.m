#import "BaseModel.h"
#import "CommonErrorResInfo.h"
#import <objc/runtime.h>

@implementation BaseModel

#pragma mark - Overrided

/**
 *  类的属性 跟  服务端 json keypath 的映射
 *
 *  @return @{@"属性" :@"jsonKeyPath"}
 */
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    NSSet * setProperty = (NSSet *)[self propertyKeys];
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    for (NSString *propertyKey in setProperty) {
        NSString * jsonKey = [NSString stringWithFormat:@"%@",propertyKey];
        [dict setObject:jsonKey forKey:propertyKey];
    };
    return dict;
}

/**
 *  为类的属性 string 提供几种变形，映射到 jsonpath，提高自动转换成功率。
 */
+(NSArray *)pathsTransformed:(NSString *)path
{
    NSMutableArray * arrPath = [NSMutableArray array];
    [arrPath addObject:path];
    
    // 属性名 --> 首字母大写
    NSString * tmp = [[self class] firstLetterUpper:path];
    [arrPath addObject:tmp];
    
    // 属性名 --> 全部小写
    tmp = [path lowercaseString];
    if (![arrPath containsObject:tmp]) {
        [arrPath addObject:tmp];
    };
    
    // 属性名 --> 全部大写
    tmp = [path uppercaseString];
    if (![arrPath containsObject:tmp]) {
        [arrPath addObject:tmp];
    };
    return arrPath;
}

//避免服务端返回空值,而导致 转换到 native nsinteger 等标准类型会crash
-(void)setValue:(id)value forKey:(NSString *)key
{
    if (value == nil || value == NSNull.null)
    {
        BOOL ignore = NO;
        ClassType classType = [self.class checkDataType:key];
        switch (classType) {
            case ClassTypeNSNumber:
            {
                value = @(0);
                break;
            }
            case ClassTypeNSString:
//                ignore = YES;
                value = @"";
                break;
            case ClassTypeNSArray:
                value = @[];
                break;
            case ClassTypeNSDictionary:
                value = @{};
                break;
            case ClassTypeNSValue:
                break;
            default:
//            {
//                value = @"0";
//            }
            break;
        };
        if (!ignore) {
           [super setValue:value forKey:key];
        };
    }else
        [super setValue:value forKey:key];
}

/**
 *  把这个类 属性 的第一个字母改成大写，映射到 接口响应json 的 key,比如 @"userName" --> return  @"UserName"
 *
 *  @param propertyStr 类的属性 string
 *
 *  @return
 */
+(NSString *)firstLetterUpper:(NSString *)propertyStr
{
    NSString *firstChar = [propertyStr substringWithRange: NSMakeRange(0,1)];
    firstChar = [firstChar uppercaseString];
    NSMutableString *sProperty = [NSMutableString stringWithString:propertyStr];
    [sProperty replaceCharactersInRange:NSMakeRange(0, 1) withString:firstChar];
    return sProperty;
}

#pragma mark -
#pragma mark 判断属性类型

+ (ClassType)checkDataType:(NSString *)key
{
    ClassType propertyClass = ClassTypeNoDefined;
    
    //get property name
    objc_property_t property = class_getProperty(self, [key UTF8String]);;
    
    char *typeEncoding = property_copyAttributeValue(property, "T");
    switch (typeEncoding[0])
    {
        case '@':// NSMutableArray、NSDictionary、NSDate、NSString、NSURL
        {
            // 这个判断不够 严谨，还得细分   -- by linyawen，
//            if (strlen(typeEncoding) >= 3)
//            {
//                propertyClass = ClassTypeNSString;
//            }
//            break;
            if (strlen(typeEncoding) >= 3)
            {
                Class propertyCls = nil;
                char *className = strndup(typeEncoding + 2, strlen(typeEncoding) - 3);
                __autoreleasing NSString *name = @(className);
                NSRange range = [name rangeOfString:@"<"];
                if (range.location != NSNotFound)
                {
                    name = [name substringToIndex:range.location];
                }
                propertyCls = NSClassFromString(name) ?: [NSObject class];
                if ([propertyCls isSubclassOfClass:[NSArray class]])
                {
                    propertyClass = ClassTypeNSArray;
                }else if ([propertyCls isSubclassOfClass:[NSDictionary class]])
                {
                    propertyClass = ClassTypeNSDictionary;
                }else if ([propertyCls isSubclassOfClass:[NSString class]])
                {
                    propertyClass = ClassTypeNSString;
                };
    
                free(className);
            }
            break;
        }
        case 'c':
        case 'i':// int
        case 's':
        case 'l':
        case 'q':// NSInteger、
        case 'C':
        case 'I':
        case 'S':
        case 'L':
        case 'Q':
        case 'f':// float
        case 'd':// CGFloat、double
        case 'B':
        {
            propertyClass = ClassTypeNSNumber;
            break;
        }
        case '{': // Struct
        {
            propertyClass = ClassTypeNSValue;
            break;
        }
    }
    free(typeEncoding);
    
    return propertyClass;
}

#pragma mark - YWJSONParser
+(id)JSONValueWithKeypath:(NSString *)path forJSON:(NSDictionary *)json
{
    NSArray * paths = [self pathsTransformed:path];
    id value = nil;
    for (NSString * path in paths) {
        value = [json valueForKeyPath:path];
        if (nil!= value)
            break;
    };
    return value;
}

//override
+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    if ([key isEqualToString:@"needRefresh"])
    {
        NSDictionary * params = [self codableProperties];
        NSMutableSet * allSet = [NSMutableSet setWithArray:[params allKeys]];
        [allSet removeObject:key];
        NSSet * set = allSet;
        return set;
    }else
    {
        return [super keyPathsForValuesAffectingValueForKey:key];
    };
}

+ (NSUInteger)modelVersion
{
    return ModelVersion_0;
}

@end
