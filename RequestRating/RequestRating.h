//
//  RequestRating.h
//  RequestRating
//
//  Created by Emre Cakirlar on 4/2/17.
//  Copyright © 2017 Emre Cakirlar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString * const kTrackingAppVersion;
FOUNDATION_EXPORT NSString * const kFirstUseDate;
FOUNDATION_EXPORT NSString * const kUseCount;
FOUNDATION_EXPORT NSString * const kDidRateVersion;
FOUNDATION_EXPORT NSString * const kDidDeclineToRate;
FOUNDATION_EXPORT NSString * const kRemindLater;
FOUNDATION_EXPORT NSString * const kRemindLaterDate;

@interface RequestRating : NSObject

- (id)init NS_UNAVAILABLE;
+ (id)new NS_UNAVAILABLE;

- (instancetype)initWithAppID:(NSString*)_appID andDays:(int)days andUses:(int)uses andIntervalDays:(int)interval;
- (instancetype)initWithAppID:(NSString*)_appID andDays:(int)days andUses:(int)uses andIntervalDays:(int)interval andRootViewController:(UIViewController *)vc;
- (void)requestRatingIfNeeded;

@end
