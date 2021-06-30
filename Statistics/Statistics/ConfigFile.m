//
//  ConfigFile.m
//  9158Live
//
//  Created by zhongqing on 2016/11/10.
//  Copyright © 2016年 tiange. All rights reserved.
//

#import "ConfigFile.h"

#define kMCatLiveBundleID  @"com.mcat.mcatlive" 
#define kEnterpriseMLiveBundleID @"com.hi.applive"
#define  kBeegoliveBundleID  @"com.beegolive.beegolive"
#define kMLiveBundleID      @"com.live.morelive"
#define kBananaliveBundleID @"com.bananalive.bananalive"

@implementation ConfigFile

+(NSString *)bundleidType
{
    NSString * nType = @"3";
    NSString * bundle = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleIdentifier"];
    if ([bundle isEqualToString:kBeegoliveBundleID]) {
        nType = @"33";//之前是30，现在要改33了
    }else if ([bundle isEqualToString:kEnterpriseMLiveBundleID]){//企业包
        nType = @"34";
    }else if([bundle isEqualToString:kMCatLiveBundleID]){
        nType = @"35";
    }
    return nType;
}

+ (BOOL)isCompileMajia {
    NSString *name = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    if ([name isEqualToString:kMLiveBundleID] || [name isEqualToString:kMCatLiveBundleID]){
        return NO;
    }
    
    return YES;
}
+(BOOL)isEnterpriseMLive{
    NSString * bundle = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleIdentifier"];
    if ([bundle isEqualToString:kEnterpriseMLiveBundleID]) {
        return YES;
    }
    return NO;
}
+(BOOL)isMCatLive{
    NSString * bundle = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleIdentifier"];
    if ([bundle isEqualToString:kMCatLiveBundleID]) {
        return YES;
    }
    return NO;
}
+ (NSString *) getAppDisplayName {
    NSString *name = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    return name;
}

+ (NSString *) getAppStoreLink
{
    NSString* nType = @"https://itunes.apple.com/th/app/mlive/id1132516774?mt=8";
    NSString *bundle = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleIdentifier"];
    if ([bundle isEqualToString:kMLiveBundleID]) {
        nType = @"https://itunes.apple.com/app/id1477011497";
    } else if ([bundle isEqualToString:kBeegoliveBundleID]) {
        nType = @"https://itunes.apple.com/app/id1202796892";
    } else if ([bundle isEqualToString:kBananaliveBundleID]) {
        nType = @"https://itunes.apple.com/app/id1216562888";
    }else if([bundle isEqualToString:kMCatLiveBundleID]){
        nType = @"https://itunes.apple.com/app/id1387371333";
    }
    return nType;
}

+ (NSString *) getMainPackageAppStoreLink
{
    return @"https://itunes.apple.com/app/id1477011497";
}

+ (NSString *) getCompanyName
{
    NSString * name = @"Winner Online Pacific Pty Ltd";
    NSString *bundle = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleIdentifier"];
    if ([bundle isEqualToString:kMLiveBundleID]) {
        name = @"Winner Pacific Pty Ltd";
    } else if ([bundle isEqualToString:kBeegoliveBundleID]) {
        name = @"BeeGo";
    } else if ([bundle isEqualToString:kBananaliveBundleID]) {
        name = @"Banana Live";
    }
    return name;
}

+ (NSString *) getCurrentVersion
{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    return version;
}

+ (NSString *) getAppIdentifier{
    NSString *Identifier = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
       return Identifier;
}

 //platform: mlive传1 mcat传2 winnerMLive传3  winnerMCat传4 mglobal5
+ (int)getCurrentAppType{
    return 1;
}

// 因为Roomlive用的是mlive的bundleid，所以增加一个参数做区分,
// Roolive: 1  morelive:2
+ (NSString*)appType{
    return @"2";
}
@end
