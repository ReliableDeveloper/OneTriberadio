//
//  BlurredViewController.h
//  Triberadio
//
//  Created by YingZhi on 6/15/14.
//  Copyright (c) 2014 MobileDev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accelerate/Accelerate.h>
#import <QuartzCore/QuartzCore.h>
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define DEFAULT_LEFT_WIDTH SCREEN_WIDTH-60
#define DEFAULT_RIGHT_WIDTH SCREEN_WIDTH-60
#define DEFAULT_ALPHA 0.5
#define DEFAULT_DIM_ALPHA 0.4

@interface BlurredViewController : UIViewController

@property (nonatomic, assign) CGFloat leftWidth;

//The layer alpha of the side views.
@property (nonatomic, assign) CGFloat sideViewAlpha;

//The tint color of the side views.
@property (nonatomic, retain) UIColor *sideViewTintColor;

//The background image.
@property (nonatomic, retain) UIImage *backgroundImage;

@property (nonatomic, retain) UIView *leftContentView;

@property (nonatomic, retain) UIView *centerContentView;

@property (nonatomic, assign) BOOL dim;

@property (nonatomic, assign) unsigned screenStatus;

- (void)openLeftView:(BOOL)animated;
- (void)closeSideView:(BOOL)animated;

//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
@end
