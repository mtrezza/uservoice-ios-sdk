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
// Applied to all appearances of the SDK's navigation bars; nil keeps the system default. Button text colors
// per state are set through its buttonAppearance, doneButtonAppearance (prominentButtonAppearance as of
// iOS 26) and backButtonAppearance, and take precedence over navigationBarButtonColor.
@property (nonatomic, copy) UINavigationBarAppearance *navigationBarAppearance;
// Tint color of the navigation bar buttons. Before iOS 26 it colors the button text; as of iOS 26 it colors
// the text of plain buttons, fills prominent buttons such as Next and colors the back chevron. It also tints
// other controls in the bar, such as the search field. nil keeps the inherited tint.
@property (nonatomic, retain) UIColor *navigationBarButtonColor;
@property (nonatomic, retain) UIColor *navigationBarActivityIndicatorColor;
@property (nonatomic, retain) UIColor *loadingViewBackgroundColor;
// Fill color of the Close button on the success screen shown after sending a message or posting an idea.
// nil uses navigationBarButtonColor as of iOS 26, like the Next button, and the inherited tint before.
@property (nonatomic, retain) UIColor *successButtonColor;
// Title text attributes of the Close button on the success screen, such as its text color and font. nil uses
// those of navigationBarAppearance's prominentButtonAppearance as of iOS 26, like the Next button.
@property (nonatomic, copy) NSDictionary<NSAttributedStringKey, id> *successButtonTitleTextAttributes;
// Status bar style of the screens with a navigation bar. The success screen hides the bar and picks the style
// that fits its background.
@property (nonatomic, assign) UIStatusBarStyle preferredStatusBarStyle;

@end
