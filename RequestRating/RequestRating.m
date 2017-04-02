//
//  RequestRating.m
//  RequestRating
//
//  Created by Emre Cakirlar on 4/2/17.
//  Copyright © 2017 Emre Cakirlar. All rights reserved.
//

#import "RequestRating.h"

static NSString * const kReviewURLBelowiOS8              = @"itms-apps://itunes.apple.com/app/id%@";
static NSString * const kReviewURL                       = @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?"\
                                                            "id=%@&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software"; // Purple Software is required and Purple is a code name for iPhone device for those who are curious.
static NSString * const kAlertTitle                      = @"Enjoying Our App?";
static NSString * const kAlertMessage                    = @"We're glad you love our app. Please take a moment to rate your experience.";
static NSString * const kAlertOKButtonTitle              = @"Rate";
static NSString * const kAlertRemindMeLaterButtonTitle   = @"Remind Later";
static NSString * const kAlertCanceButtonTitle           = @"Don't Show Again";

NSString * const kTrackingAppVersion                    = @"RR_TRACKING_APP_VERSION";
NSString * const kFirstUseDate                          = @"RR_FIRST_USE_DATE";
NSString * const kUseCount                              = @"RR_USE_COUNT";
NSString * const kDidRateVersion                        = @"RR_DID_RATE_VERSION";
NSString * const kDidDeclineToRate                      = @"RR_DID_DECLINE_TO_RATE";
NSString * const kRemindLater                           = @"RR_REMIND_LATER";
NSString * const kRemindLaterDate                       = @"RR_REMIND_LATER_DATE";

@interface RequestRating () <UIAlertViewDelegate>
{
    NSString *appID;
    int promptAfterDays;
    int promptAfterUses;
    int intervalDaysToPrompt;
}
@property (nonatomic, strong) NSString *currentAppVersion;
@property (nonatomic, assign) BOOL isFirstRun;
@property (nonatomic, strong) UIViewController *rootVC;
@property (nonatomic, strong) RequestRating *alertViewDelegate;

@end

@implementation RequestRating

#pragma mark - Initializations

- (instancetype)initWithAppID:(NSString*)_appID andDays:(int)days andUses:(int)uses andIntervalDays:(int)interval
{
    UIViewController *defaultRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [self initWithAppID:_appID andDays:days andUses:uses andIntervalDays:interval andRootViewController:defaultRootVC];
}


- (instancetype)initWithAppID:(NSString*)_appID andDays:(int)days andUses:(int)uses andIntervalDays:(int)interval andRootViewController:(UIViewController *)vc
{
    self = [super init];
    if (self)
    {
        self.rootVC = vc;
        appID = _appID;
        promptAfterDays = days;
        promptAfterUses = uses;
        intervalDaysToPrompt = interval;
        self.alertViewDelegate = self;
    }
    return self;
}

- (void)initializeDefaultInfo
{
    [[NSUserDefaults standardUserDefaults] setObject:self.currentAppVersion forKey:kTrackingAppVersion];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kFirstUseDate];
    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:kUseCount];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kDidRateVersion];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kDidDeclineToRate];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kRemindLater];
    [self syncUserDefaults];
}
#pragma mark -

- (void)requestRatingIfNeeded
{
    if(self.isFirstRun)
    {
        [self initializeDefaultInfo];
    }
    else
    {
        NSDate *firstUseDate          = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:kFirstUseDate];
        NSInteger useCount            = [[NSUserDefaults standardUserDefaults] integerForKey:kUseCount];
        BOOL didRateVersion           = [[NSUserDefaults standardUserDefaults] boolForKey:kDidRateVersion];
        BOOL didDeclineToRate         = [[NSUserDefaults standardUserDefaults] boolForKey:kDidDeclineToRate];
        BOOL willRemindLater          = [[NSUserDefaults standardUserDefaults] boolForKey:kRemindLater];
        int daysCount                 = ([[NSDate date] timeIntervalSinceDate:firstUseDate]/3600)/24;
        
        if(didDeclineToRate || didRateVersion)
            return;
        else if(willRemindLater)
        {
            NSDate *remindLater = (NSDate *) [[NSUserDefaults standardUserDefaults] objectForKey:kRemindLaterDate];
            NSTimeInterval timeIntervalSinceRemindLater = [[NSDate date] timeIntervalSinceDate:remindLater];
            int pastDays = (timeIntervalSinceRemindLater/3600)/24;
            
            if(pastDays >= intervalDaysToPrompt)
                [self promptRatingRequest];
        }
        else if(daysCount >= promptAfterDays)
        {
            if(useCount >= promptAfterUses)
                [self promptRatingRequest];
        }
        [self incrementValueForKey:kUseCount];
    }
}

- (void)promptRatingRequest
{
    if([self getSystemVersion] >= 8.0f)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:kAlertTitle
                                    
                                                                       message:kAlertMessage
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *rateAction = [UIAlertAction actionWithTitle:kAlertOKButtonTitle
                                                         style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * _Nonnull action)
        {
            [self rateAction];
        }];
        UIAlertAction *remindLaterAction = [UIAlertAction actionWithTitle:kAlertRemindMeLaterButtonTitle
                                                         style:UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction * _Nonnull action)
        {
            [self remindMeLaterAction];
        }];
        UIAlertAction *declineToRateAction = [UIAlertAction actionWithTitle:kAlertCanceButtonTitle
                                                                    style:UIAlertActionStyleDestructive
                                                                  handler:^(UIAlertAction * _Nonnull action)
        {
            [self declineToRateAction];
        }];
        
        [alert addAction:rateAction];
        [alert addAction:remindLaterAction];
        [alert addAction:declineToRateAction];
        
        dispatch_async(dispatch_get_main_queue(),
        ^{
            [self.rootVC presentViewController:alert
                                      animated:YES
                                    completion:nil];
        });
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kAlertTitle message:kAlertMessage
                                                       delegate:self.alertViewDelegate
                                              cancelButtonTitle:kAlertCanceButtonTitle
                                              otherButtonTitles:kAlertOKButtonTitle, kAlertRemindMeLaterButtonTitle, nil];
        [alert show];
    }
    
}

#pragma mark - Alert View Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0) // 0 - Decline To Rate
    {
        [self declineToRateAction];
    }
    else if(buttonIndex == 1) // 1 - Rate
    {
        [self rateAction];
    }
    else if(buttonIndex == 2) // 2 - Remind me later
    {
        [self remindMeLaterAction];
    }
}

#pragma mark - Alert Actions

- (void)rateAction
{
    NSString *reviewURLString = ([self getSystemVersion] < 8.0f) ? kReviewURLBelowiOS8 : kReviewURL;
    NSURL *appStoreURL = [NSURL URLWithString:[NSString stringWithFormat:reviewURLString, appID]];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDidRateVersion];
    [self syncUserDefaults];
    [[UIApplication sharedApplication] openURL:appStoreURL];
}

- (void)remindMeLaterAction
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kRemindLater];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kRemindLaterDate];
    [self syncUserDefaults];
}

- (void)declineToRateAction
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDidDeclineToRate];
    [self syncUserDefaults];
}

#pragma mark - Helpers

- (void)incrementValueForKey:(NSString *)key
{
    NSInteger currVal = [[NSUserDefaults standardUserDefaults] integerForKey:key];
    currVal++;
    [[NSUserDefaults standardUserDefaults] setInteger:currVal forKey:key];
    [self syncUserDefaults];
}

- (void)syncUserDefaults
{
    if([self getSystemVersion] < 10.0f) // synchronize will soon be deprecated
        [[NSUserDefaults standardUserDefaults] synchronize];
}

- (float)getSystemVersion
{
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}

#pragma mark -  Getters

- (NSString *)currentAppVersion
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

- (BOOL)isFirstRun
{
    NSString *trackingAppVersion =  [[NSUserDefaults standardUserDefaults] objectForKey:kTrackingAppVersion];
    if(!trackingAppVersion || ![trackingAppVersion isEqualToString:self.currentAppVersion])
        return YES;
    
    return NO;
}

@end
