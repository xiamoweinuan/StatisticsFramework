//
//  StatisticsUtils.m
//  MoreLive
//
//  Created by tg on 2020/12/18.
//  Copyright © 2020 tiange. All rights reserved.
//

#import "StatisticsUtil.h"
#import "DeviceInformation.h"
#import "ConfigFile.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CommonCrypto/CommonDigest.h>
#import "IPAddress.h"
#import "AFNetworking.h"
#define DEFAULTKEYSTATISTICS @"DEFAULTKEYSTATISTICS"

#define TIMEKEY @"TIMEKEY"
#define COUNTKEY @"COUNTKEY"


@interface StatisticsUtil()
@property (nonatomic, strong)NSString *ltype; //记录类型  1 登录，2 列表，3 视频拉流，4 进房间  5：服务端 6:推流情况
@property (nonatomic, strong)NSString *useridx; // 用户idx
@property (nonatomic, strong)NSString *roomid;  // 房间idx
@property (nonatomic, strong)NSString *anchoridx; // 主播idx
@property (nonatomic, strong)NSString *clientip; // 客户端ip
@property (nonatomic, strong)NSString *cpu; // 客户端cpu类型
@property (nonatomic, strong)NSString *ram; // 客户端内存
@property (nonatomic, strong)NSString *apiurl; // 接口地址
@property (nonatomic, strong)NSString *hostip; // 接口ip
@property (nonatomic, strong)NSString *times; // 接口时间
@property (nonatomic, strong)NSString *networkname; // 网络运营商名称
@property (nonatomic, strong)NSString *nettype; //网络类型 3G 4G  5G WIFI
@property (nonatomic, strong)NSString *device; // 设备名
@property (nonatomic, strong)NSString *uniqueid; // 设备唯一码
@property (nonatomic, strong)NSString *packname; // 包名
@property (nonatomic, strong)NSString *apptype; // app类型，那个包
@property (nonatomic, strong)NSString *flv; // 播放地址
@property (nonatomic, strong)NSString *appversion; // 版本号
@property (nonatomic, strong)NSString *lng; // 经度
@property (nonatomic, strong)NSString *lat; // 纬度
@property (nonatomic, assign)NSTimeInterval startTime; //开始时间
@property (nonatomic, assign)NSTimeInterval endTime; //结束时间
@property (nonatomic,assign)NSString *count; // 次数
@property (nonatomic,assign)BOOL isShowDebugLogs;


@property (nonatomic, strong)NSString *timesLtype6; // 接口时间

@end
@implementation StatisticsUtil
static StatisticsUtil *util = nil;
+ (instancetype)install{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        util = [[StatisticsUtil alloc] init];
        [[IPAddress sharedInstance] getLocalIPAddress];
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            util.nettype  = [StatisticsUtil getNetconnType];
        }];
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    });
    return util;
}

-(void)statisticsUpLoadWithType:(NSString*)ltype withIsStartTime:(BOOL)isStartTime{
    if (isStartTime) {
        [StatisticsUtil startSaveTime];
    }else{
        [StatisticsUtil endSaveTime];
    }
    [self statisticsUpLoadWithType:ltype];
}

///记录推流端成功失败ltype = 6
-(void)statisticsPushStreamIsSuccess:(BOOL)isSuccess{
    self.ltype = @"6";
    NSString* str = @"";
    if(isSuccess){
        str = @"CONNECT";
    }else{
        str = @"ERROR";
    }
    self.timesLtype6 =[[self cnm_Date_geStringtCurrentTimes] stringByAppendingString:str];
    [self getURLRequest];
    
}
-(void)statisticsUpLoadWithType:(NSString*)ltype{
    NSInteger countType = 0;
    
    if (_startTime>=_endTime) {
        
        NSDictionary* dictUserDefaults = [[NSUserDefaults standardUserDefaults] valueForKey:DEFAULTKEYSTATISTICS];
        
        NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithDictionary:dictUserDefaults];
        
        NSString* strDate =dict[ltype][TIMEKEY];
        if (strDate) {
            
            NSMutableDictionary* dictType=[NSMutableDictionary dictionaryWithDictionary:dict[ltype]];
            
            
            if ([self isTodayWith:[self getDateForString:strDate format:nil]]) {//是今天，开始计数
                NSInteger count =[dict[ltype][COUNTKEY]  integerValue];
                dictType[COUNTKEY] = [NSString stringWithFormat:@"%d",count+1];
                
                dict[ltype] =dictType;
                
                
            }else{//不是今天，需要上传，并且恢复默认值
                NSInteger count =[dict[ltype][COUNTKEY]  integerValue];
                countType = count;
                
                dictType[TIMEKEY] = [self cnm_Date_geStringtCurrentTimes];
                dictType[COUNTKEY] = @"1";
                dict[ltype] =dictType;
                
                
            }
            
            
        }else{//默认值
            NSMutableDictionary* dictType =@{}.mutableCopy;
            dictType[TIMEKEY] = [self cnm_Date_geStringtCurrentTimes];
            dictType[COUNTKEY] = @"1";
            
            dict[ltype] =dictType;
            
        }
        if (_isShowDebugLogs) {
            NSLog(@"StatisticsLOG****储存的类型，次数，以及上传时间=%@",dict);
        }
        
        [[NSUserDefaults standardUserDefaults] setValue:dict forKey:DEFAULTKEYSTATISTICS];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    self.ltype = ltype;
    self.count = [NSString stringWithFormat:@"%ld",(long)countType];
    
    //统计到数据后第二天才上传
    if (countType !=0) {
        [self getURLRequest];
    }
    
}
-(void)getURLRequest{
    NSString *url = @"http://210.246.248.113:5001/timeoutlogs";
//    NSString *url = @"http://logger.mlive.la/timeoutlogs";
    NSString *urlString = [NSString stringWithFormat:@"%@?paramstr=%@",url,[self jsonData]];
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSURL *requestUrl = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestUrl];
    
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"]; // 设置请求体(json类型)
    if (_isShowDebugLogs) {
        NSLog(@"StatisticsLOG****url=%@",request.URL);
        
    }
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data.bytes) {
            
            id jsonClass = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            if (self->_isShowDebugLogs) {
                NSLog(@"StatisticsLOG****jsonDict = %@",jsonClass);
                
            }
        }
        if (error) {
            if (self->_isShowDebugLogs) {
                NSLog(@"StatisticsLOG****error = %@",error);
                
            }
        }
    }];
    
    [task resume];
}
-(void)setIsShowDebugLogs:(BOOL)isShowDebugLogs{
    if (DEBUG) {
        _isShowDebugLogs = isShowDebugLogs;
    }
}
-(void)isShowDebugLogs:(BOOL)isDebug;{
    self.isShowDebugLogs = isDebug;
}
-(void)setUseridx:(NSString *)useridx withRoomid:(NSString *)roomid withAnchoridx:(NSString *)anchoridx{
    self.useridx = useridx;
    self.roomid = roomid;
    self.anchoridx = anchoridx;

}

//- (NSString *)useridx{
//    NSString *idx = @"";
//    if (idx.length == 0) {
//        return @"";
//    }
//    return idx;
//}
//
//- (NSString *)roomid{
//    NSString *rmidx = @"";
//    if (rmidx.length == 0) {
//        return @"";
//    }
//    return rmidx;
//}
//
//- (NSString *)anchoridx{
//    NSString *idx = @"";
//    if (idx.length == 0) {
//           return @"";
//       }
//       return idx;
//}

- (NSString *)hostip{
    return [DeviceInformation getIPAddressByHostName:@"home.mlive.in.th"];
}

- (NSString *)device{
    return [DeviceInformation getDeviceName];
}

- (NSString *)uniqueid{
    return [StatisticsUtil generateIdentify];
}

- (NSString *)appversion{
    return [ConfigFile getCurrentVersion];
}

- (NSString *)packname{
    return [ConfigFile getAppDisplayName];
}

- (NSString *)apptype{
    return [NSString stringWithFormat:@"%d",[ConfigFile getCurrentAppType]];
}

//- (NSString *)nettype{
//    return [StatisticsUtil getNetconnType];
//}

- (NSString *)cpu{
    return [DeviceInformation getCPUType];
}

- (NSString *)ram{
    return [DeviceInformation getTotalMemory];
}

- (NSString *)times{
    NSTimeInterval second = _endTime - _startTime;
    return [NSString stringWithFormat:@"%fd",second];
}

+ (void)startSaveTime{
    [StatisticsUtil install].startTime = [[NSDate date] timeIntervalSince1970];
}

+ (void)endSaveTime{
    [StatisticsUtil install].endTime = [[NSDate date] timeIntervalSince1970];
}
- (NSString *)jsonData{
    StatisticsUtil *phone = [StatisticsUtil install];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[@"ltype"] = [NSNumber numberWithInt:[phone.ltype intValue]];
    dict[@"useridx"] = [NSNumber numberWithInt:[phone.useridx intValue]];
    dict[@"roomid"] = [NSNumber numberWithInt:[phone.roomid intValue]];
    dict[@"anchoridx"] = [NSNumber numberWithInt:[phone.anchoridx intValue]];
    dict[@"clientip"] = phone.clientip;
    dict[@"cpu"] = phone.cpu;
    dict[@"ram"] = phone.ram;
    dict[@"apiurl"] = ([phone.ltype intValue] == 3 || [phone.ltype intValue] == 4) ? @"" :  phone.apiurl;
    dict[@"hostip"] = phone.hostip;
    dict[@"networkname"] = phone.networkname;
    dict[@"nettype"] = phone.nettype;
    dict[@"device"] = phone.device;
    dict[@"uniqueid"] = phone.uniqueid;
    dict[@"packname"] = phone.packname;
    dict[@"apptype"] = [NSNumber numberWithInt:[phone.apptype intValue]];
    dict[@"flv"] = phone.flv;
    dict[@"appversion"] = phone.appversion;
    dict[@"lng"] = phone.lng;
    dict[@"lat"] = phone.lat;

    if (self.count.length) {
        dict[@"count"] =self.count;
    }
    
    if ([phone.ltype isEqualToString:@"6"]) {
        dict[@"count"] = self.timesLtype6;
    }else{
        dict[@"count"] = [NSNumber numberWithInteger:[phone.times integerValue]];
    }
    //由于times之前是number类型，传string会有问题，这里使用count
//    if ([phone.ltype isEqualToString:@"6"]) {
//        dict[@"times"] = self.timesLtype6;
//    }else{
//        dict[@"times"] = [NSNumber numberWithInteger:[phone.times integerValue]];
//    }
 
    if (_isShowDebugLogs) {
        NSLog(@"StatisticsLOG****dict=%@",dict);

    }
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
       return @"";
    }
    
    NSString *jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\r" withString:@"" ];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\n" withString : @"" ];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@" " withString : @"" ];
    
    return jsonString;
}

+ (NSString *)getNetconnType{
    
        NSString *netconnType = @"";

    AFNetworkReachabilityStatus statu = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;

    switch (statu) {
        case AFNetworkReachabilityStatusReachableViaWiFi:
        {
            netconnType = @"WIFI";
        }
            break;
        case AFNetworkReachabilityStatusReachableViaWWAN:
        {
            // 获取手机网络类型
            CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];

            NSString *currentStatus = info.currentRadioAccessTechnology;

            if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyGPRS"]) {

                netconnType = @"GPRS";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyEdge"]) {

                netconnType = @"2.75G EDGE";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyWCDMA"]){

                netconnType = @"3G";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSDPA"]){

                netconnType = @"3.5G HSDPA";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSUPA"]){

                netconnType = @"3.5G HSUPA";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMA1x"]){

                netconnType = @"2G";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORev0"]){

                netconnType = @"3G";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevA"]){

                netconnType = @"3G";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevB"]){

                netconnType = @"3G";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyeHRPD"]){

                netconnType = @"HRPD";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyLTE"]){

                netconnType = @"4G";
            }
        }
            break;
        default:
            break;
    }
    return netconnType;
}

+ (NSString *)generateIdentify {
    NSString *identify = @"";
    srandom(time(0));
    char letter = 'A';
    for (int i = 0 ; i < 20; i++) {
        NSInteger rand = (NSInteger)random()%26;
        identify = [identify stringByAppendingFormat:@"%c", (char)(letter + rand)];
    }
    identify = [identify stringByAppendingFormat:@"%f", [NSDate timeIntervalSinceReferenceDate]];
    identify = [StatisticsUtil md5:identify];
    
    return identify;
}
+(NSString *)md5:(NSString *)str{
    if(str){
        const char *cStr = [str UTF8String];
        unsigned char result[16];
        CC_MD5(cStr, (unsigned int)strlen(cStr), result);
        
        return [NSString stringWithFormat:
                @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                result[0], result[1], result[2], result[3],
                result[4], result[5], result[6], result[7],
                result[8], result[9], result[10], result[11],
                result[12], result[13], result[14], result[15]
                ];
    }
    return str;

}
- (BOOL)isTodayWith:(NSDate*)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitDay | NSCalendarUnitMonth |  NSCalendarUnitYear;
    
    // 1.获得当前时间的年月日
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[NSDate date]];
    
    // 2.获得self的年月日
    NSDateComponents *selfCmps = [calendar components:unit fromDate:date];
    return
    (selfCmps.year == nowCmps.year) &&
    (selfCmps.month == nowCmps.month) &&
    (selfCmps.day == nowCmps.day);
}
-(NSString*)cnm_Date_geStringtCurrentTimes{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制

    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    //现在时间,你可以输出来看下是什么格式
    
    NSDate *datenow = [NSDate date];
    
    //----------将nsdate按formatter格式转成nsstring
    
    NSString *currentTimeString = [formatter stringFromDate:datenow];
        
    return currentTimeString;
    
}
- (NSDate *)getDateForString:(NSString *)string format:(NSString *)format{
    
    if (format == nil) format = @"yyyy-MM-dd HH:mm:ss";
    
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:format];
    return [dateFormatter dateFromString:string];
}
@end
