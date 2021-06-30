//
//  IPAddress.m
//  9158Live
//
//  Created by lushuang on 16/8/30.
//  Copyright © 2016年 tiange. All rights reserved.
//

#import "IPAddress.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperation.h"
#import "StatisticsUtil.h"

@interface IPAddress() {
}

@end

static IPAddress *gIpAddress = nil;

@implementation IPAddress


#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

+ (IPAddress *)sharedInstance
{
    static dispatch_once_t dis;
    dispatch_once(&dis, ^{
        if (gIpAddress == nil) {
            gIpAddress = [[IPAddress alloc] init];
        }
    });
    return gIpAddress;
}


- (void)getLocalIPAddress {
    NSString *URLTmp = @"https://ipapi.co/json/";
    NSString *URLTmp1 = [URLTmp stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];  //转码成UTF-8  否则可能会出现错误
    //    [URLTmp stringByAddingPercentEncodingWithAllowedCharacters:(nonnull NSCharacterSet *)]
    URLTmp = URLTmp1;
    NSURLRequest *request =
    [NSURLRequest requestWithURL:[NSURL URLWithString: URLTmp]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:
     ^(AFHTTPRequestOperation *operation, id responseObject) {
//         NSLog(@"Success: %@", operation.responseString);
         NSString *requestTmp = [NSString stringWithString:operation.responseString];
         NSData *resData = [[NSData alloc] initWithData:[requestTmp dataUsingEncoding:NSUTF8StringEncoding]];
         //系统自带JSON解析
         NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
         if (resultDic) {
//                 _area = [resultDic objectForKey:@"area"];
//                 _areadId = [[resultDic objectForKey:@"area_id"] integerValue];
                 _city = [resultDic objectForKey:@"city"];
//                 _cityId = [[resultDic objectForKey:@"city_id"] integerValue];
                 _country = [resultDic objectForKey:@"country"];
                 _countryId = [resultDic objectForKey:@"country_code"];
                 _ip = [resultDic objectForKey:@"ip"];
//                 _isp = [resultDic objectForKey:@"isp"];
//                 _ispId = [[resultDic objectForKey:@"isp_id"] integerValue];
                 _region = [resultDic objectForKey:@"region"];
//            [StatisticsUtil install].networkname = [resultDic objectForKey:@"org"];
//            [StatisticsUtil install].clientip = [resultDic objectForKey:@"ip"];
//            [StatisticsUtil install].lng = [resultDic objectForKey:@"longitude"];
//            [StatisticsUtil install].lat = [resultDic objectForKey:@"latitude"];
             [[StatisticsUtil install] setValue:[resultDic objectForKey:@"org"] forKey:@"networkname"];
             [[StatisticsUtil install] setValue:[resultDic objectForKey:@"ip"] forKey:@"clientip"];
             [[StatisticsUtil install] setValue:[resultDic objectForKey:@"longitude"] forKey:@"lng"];
             [[StatisticsUtil install] setValue:[resultDic objectForKey:@"latitude"] forKey:@"lat"];
             
         }
         
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Failure: %@", error);
     }];
    [operation start];
}

/**
 *  域名解析
 *
 *  @param hostName 域名
 *
 *  @return ips
 */
+(NSMutableArray *) getIPWithHostName:(const NSString *)hostName
{
    NSMutableArray *tempDNS = [[NSMutableArray alloc] init];
    CFHostRef hostRef = CFHostCreateWithName(kCFAllocatorDefault, (__bridge CFStringRef)hostName);
    if (hostRef)
    {
        Boolean result = CFHostStartInfoResolution(hostRef, kCFHostAddresses, NULL);
        if (result == TRUE)
        {
            NSArray *addresses = (__bridge NSArray*)CFHostGetAddressing(hostRef, &result);
            
            
            for(int i = 0; i < addresses.count; i++)
            {
                struct sockaddr_in* remoteAddr;
                CFDataRef saData = (CFDataRef)CFArrayGetValueAtIndex((__bridge CFArrayRef)addresses, i);
                remoteAddr = (struct sockaddr_in*)CFDataGetBytePtr(saData);
                
                if(remoteAddr != NULL)
                {
                    const char *strIP41 = inet_ntoa(remoteAddr->sin_addr);
                    
                    NSString *strDNS =[NSString stringWithCString:strIP41 encoding:NSASCIIStringEncoding];
                    [tempDNS addObject:strDNS];
                }
            }
        }
        CFRelease(hostRef);
    }
    
    return tempDNS;
}
- (void)getIpLoaction {
    NSString *URLTmp = [NSString stringWithFormat:@"http://int.dpool.sina.com.cn/iplookup/iplookup.php?format=json&ip=%@&qq-pf-to=pcqq.c2c", _ip];
    NSString *URLTmp1 = [URLTmp stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];  //转码成UTF-8  否则可能会出现错误
    //    [URLTmp stringByAddingPercentEncodingWithAllowedCharacters:(nonnull NSCharacterSet *)]
    URLTmp = URLTmp1;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString: URLTmp]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:
     ^(AFHTTPRequestOperation *operation, id responseObject) {

         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Failure: %@", error);
     }];
    [operation start];
}

@end
