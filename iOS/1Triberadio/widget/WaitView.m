//
//  WaitView.m
//  baccarat
//
//  Created by kimks on 5/28/13.
//  Copyright (c) 2013 com. All rights reserved.
//

#import "WaitView.h"
#import "CommonUtils.h"


@interface WaitView ()
@property(nonatomic, retain) UIActivityIndicatorView *rounding;
@end

@implementation WaitView

@synthesize msgText;
@synthesize rounding;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        msgText = @"Please Wait...";
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


- (void)setup
{
    CGFloat osVer = [CommonUtils osVersion];
    if (osVer < 7.0f) {
        rounding = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(10, 5, 60, 60)];
        rounding.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        UIFont *font = [UIFont systemFontOfSize:20];
        CGSize textSize = [msgText sizeWithFont:font];
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 5, textSize.width, 60)];
        [messageLabel setBackgroundColor:[UIColor clearColor]];
        [messageLabel setText:msgText];
        [messageLabel setTextColor:[UIColor whiteColor]];
        [self addSubview:rounding];
        [self addSubview:messageLabel];
        [rounding startAnimating];
    } else {
        rounding = nil;
        [self setMessage:msgText];
    }
}

- (void)execute
{
    [self setup];
    [self show];
}

- (void)close
{
    if (rounding) {
        [rounding stopAnimating];
    }

    [self dismissWithClickedButtonIndex:-1 animated:NO];
    if (self) {
        [self removeFromSuperview];
    }
}

@end
