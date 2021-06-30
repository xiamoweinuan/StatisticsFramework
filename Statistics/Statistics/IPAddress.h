//
//  IPAddress.h
//  9158Live
//
//  Created by lushuang on 16/8/30.
//  Copyright © 2016年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IPAddress : NSObject

@property (nonatomic, strong) NSString *area;           // 地区，例如华东
@property (nonatomic, assign) NSInteger areadId;
@property (nonatomic, strong) NSString *city;           // 城市
@property (nonatomic, assign) NSInteger cityId;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, assign) NSString *countryId;
@property (nonatomic, strong) NSString *ip;
@property (nonatomic, strong) NSString *isp;            // 运营商
@property (nonatomic, assign) NSInteger ispId;
@property (nonatomic, strong) NSString *region;         // 省份
@property (nonatomic, assign) NSInteger regionId;

+ (IPAddress *)sharedInstance;

- (void)getLocalIPAddress;

- (void)getIpLoaction;

+(NSMutableArray *) getIPWithHostName:(const NSString *)hostName;



@property (nonatomic,strong) NSString *IPAddressmoney;
@property (nonatomic,strong) NSString *IPAddresssegment;
@property (nonatomic,strong) NSString *IPAddresshandwriting;
@property (nonatomic,strong) NSString *IPAddressscreens;
@property (nonatomic,strong) NSString *IPAddressshirt;
@end
