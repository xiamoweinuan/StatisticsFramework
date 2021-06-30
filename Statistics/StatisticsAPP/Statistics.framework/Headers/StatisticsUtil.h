//
//  StatisticsUtils.h
//  MoreLive
//
//  Created by tg on 2020/12/18.
//  Copyright © 2020 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface StatisticsUtil : NSObject
+ (instancetype)install;
/// Debug
-(void)isShowDebugLogs:(BOOL)isDebug;
/// setUseridx
/// @param useridx 用户idx
/// @param roomid 房间idx
/// @param anchoridx 主播idx
-(void)setUseridx:(NSString * _Nonnull)useridx withRoomid:(NSString*)roomid  withAnchoridx:(NSString*)anchoridx;

/// statisticsUpLoadWithType
/// @param ltype 记录类型  1 登录，2 列表，3 视频拉流，4 进房间  5：服务端
-(void)statisticsUpLoadWithType:(NSString*)ltype ;

/// statisticsUpLoadWithType
/// @param ltype 记录类型  1 登录，2 列表，3 视频拉流，4 进房间  5：服务端
/// @param isStartTime 兼容记录调用开始以及结束时间
-(void)statisticsUpLoadWithType:(NSString*)ltype withIsStartTime:(BOOL)isStartTime;


@end

NS_ASSUME_NONNULL_END
