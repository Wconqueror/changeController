//
//  AppDelegate.m
//  runtime(万能界面跳转)
//
//  Created by 王得胜 on 2018/11/20.
//  Copyright © 2018 com.youqii.com. All rights reserved.
//

#import "AppDelegate.h"
#import <objc/runtime.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc]initWithFrame:UIScreen.mainScreen.bounds];
    UINavigationController *nav = [[UINavigationController alloc]init];
    self.window.rootViewController = nav;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self test];
    });
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)test{
    //具体格式与服务端协商好!
    NSDictionary *dict = @{
                           @"class"    : @"DSViewController",
                           @"property" : @{
                                   @"ID"   : @"123",
                                   @"type" : @"1111"
                                   }
                           };
    [self push:dict];
}


-(void)push:(NSDictionary *)params{
    NSString *class = [NSString stringWithFormat:@"%@",params[@"class"]];
    const char *className = [class cStringUsingEncoding:NSASCIIStringEncoding];
    
    //由字符串生成类
    Class newclass = NSClassFromString(class);
    if (!newclass) {
        //创建一个类
        Class superClass = [NSObject class];
        newclass = objc_allocateClassPair(superClass, className, 0);
        //注册创建的类
        objc_registerClassPair(newclass);
    }
    
    //创建对象
    id instance = [[newclass alloc]init];
    
    NSDictionary *propertys = params[@"property"];
    [propertys enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        //检查这个对象是否存在该属性
        if ([self checkIsExistPropertyWithInstance:instance verifyPropertyName:key]) {
            [instance setValue:obj forKey:key];
        }
    }];
    
    //获取导航控制器
 
    UINavigationController *nav = (UINavigationController *)self.window.rootViewController;
    
    //跳转到对应的控制器
    [nav pushViewController:instance animated:YES];
    
}

/**
 *  检测对象是否存在该属性
 */
- (BOOL)checkIsExistPropertyWithInstance:(id)instance verifyPropertyName:(NSString *)verifyPropertyName{
    unsigned int outCount;
    
    //获取对象的属性列表
    objc_property_t *properties = class_copyPropertyList([instance class], &outCount);
    
    for (int i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        //属性名转化成字符串
        
        NSString *propertyName = [[NSString alloc]initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        //判断该属性是否存在
        if ([propertyName isEqualToString:verifyPropertyName]) {
            free(properties);
            return YES;
        }
    }
    free(properties);
    
    return NO;
}


@end
