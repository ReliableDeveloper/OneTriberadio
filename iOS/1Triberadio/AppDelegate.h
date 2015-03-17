//
//  AppDelegate.h
//  1Triberadio
//
//  Created by YingZhi on 20/6/14.
//
//

#import <UIKit/UIKit.h>
#import <CoreTelephony/CTCall.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <MediaPlayer/MediaPlayer.h>
#import "instagram/Instagram.h"
#import "ZSVRadioPlayer.h"
#import <Pushwoosh/PushNotificationManager.h>

@class RadioPlayerViewController;
@class RadioPlayer;
@class AudioStreamer;
@interface AppDelegate : UIResponder <UIApplicationDelegate,AVAudioPlayerDelegate,AVAudioSessionDelegate, PushNotificationDelegate> {
}
@property(nonatomic,assign)UIBackgroundTaskIdentifier bgTaskId;

@property (strong,nonatomic) UINavigationController *NAVIGATIONcontroller;
@property (strong, nonatomic) RadioPlayerViewController *radioController;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) Instagram *instagram;
@property (strong, nonatomic) ZSVRadioPlayer *radioPlayer;
@end
