//
//  UVStyleSheet.h
//  UserVoice
//
//  Created by UserVoice on 10/28/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UVStyleSheet : NSObject 

+ (UVStyleSheet *)instance;

@property (nonatomic, retain) UIColor *tintColor;
@property (nonatomic, retain) UIColor *tableViewBackgroundColor;
@property (nonatomic, retain) UIColor *navigationBarActivityIndicatorColor;
@property (nonatomic, retain) UIColor *loadingViewBackgroundColor;
@property (nonatomic, assign) UIStatusBarStyle preferredStatusBarStyle;

@end
