//
//  WebVideoViewController.h
//  YTBrowser
//
//  Created by Marin Todorov on 09/01/2013.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoModel.h"
#import "LeveyPopListView.h"
#import <Twitter/Twitter.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@interface WebVideoViewController : UIViewController <LeveyPopListViewDelegate> {
    SLComposeViewController *slComposerSheet;
}

@property (weak, nonatomic) NSURL *url;
@property (weak, nonatomic) NSString *title;

@property (weak, nonatomic) VideoModel* video;
@property (strong, nonatomic) NSArray *sharebuttons;
@end
