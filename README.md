# RequestRating
An easy to use library for asking your users to rate your app.

## Usage
```objective-c
[[[RequestRating alloc] initWithAppID:@"YOUR_APP_ID HERE"
                        andDays:0 andUses:3 andIntervalDays:2] requestRatingIfNeeded];
```

This code prompts a rating request alert after 3 uses from first day of the launch.
If user taps `Remind Me Later` button, it reminds user to rate your app after 2 days (Interval Days). 

You can also change the titles and messages of the rating alert by modifying the fields below in `RequestRating.m`

```objective-c
static NSString * const kAlertTitle
static NSString * const kAlertMessage
static NSString * const kAlertOKButtonTitle
static NSString * const kAlertRemindMeLaterButtonTitle
static NSString * const kAlertCanceButtonTitle
```
