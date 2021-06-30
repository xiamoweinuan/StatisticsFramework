//
//  ViewController.m
//  StatisticsAPP
//
//  Created by tg on 2020/12/21.
//

#import "ViewController.h"
//#import "StatisticsUtil.h"
#import <Statistics/StatisticsUtil.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化
    [StatisticsUtil install];
    [[StatisticsUtil install]setUseridx:@"111" withRoomid:@"111" withAnchoridx:@"111"];
    [[StatisticsUtil install] isShowDebugLogs:YES];

    
    //统计类型次数，第二天才上传
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[StatisticsUtil install] statisticsUpLoadWithType:@"2"];
    });
    
    
    
    //统计推流成功失败
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
 
        [[StatisticsUtil install] statisticsPushStreamIsSuccess:YES];
    });
    
    
    // Do any additional setup after loading the view.
}


@end
