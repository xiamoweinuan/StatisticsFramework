//
//  ConfigFile.h
//  9158Live
//
//  Created by zhongqing on 2016/11/10.
//  Copyright © 2016年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>

/****
 *
 *     主要用于配置
 *
 *
 ****/

@interface ConfigFile : NSObject


+(NSString *)bundleidType;

//判断是不是马甲包
+ (BOOL)isCompileMajia;
//是不是企业包
+(BOOL)isEnterpriseMLive;
//是不是MCat Live
+(BOOL)isMCatLive;
//获取appstore的跳转链接
+ (NSString *) getAppStoreLink;

// 因为Roomlive用的是mlive的bundleid，所以增加一个参数做区分
+ (NSString*)appType;
//获取copyright名称
+ (NSString *) getCompanyName;

+ (NSString *) getAppDisplayName;

+ (NSString *) getAppIdentifier;

//获取版本号
+ (NSString *) getCurrentVersion;

+ (NSString *) getMainPackageAppStoreLink;

+ (int)getCurrentAppType;


@property (nonatomic,strong) NSString *ConfigFiledesignation;
@property (nonatomic,strong) NSString *ConfigFilereason;
@property (nonatomic,strong) NSString *ConfigFilepronoun;
@property (nonatomic,strong) NSString *ConfigFileanimals;
@property (nonatomic,strong) NSString *ConfigFilestrike;
@end
