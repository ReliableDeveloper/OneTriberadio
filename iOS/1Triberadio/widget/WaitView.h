//
//  WaitView.h
//  baccarat
//
//  Created by kimks on 5/28/13.
//  Copyright (c) 2013 com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WaitView : UIAlertView

@property(nonatomic, assign) NSString *msgText;

- (void)execute;
- (void)close;

@end
