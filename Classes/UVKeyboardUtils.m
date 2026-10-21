//
//  UVKeyboardUtils.m
//  UserVoice
//
//  Created by Austin Taylor on 11/7/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UVKeyboardUtils.h"

static UVKeyboardUtils *sharedInstance;

@implementation UVKeyboardUtils

+ (UVKeyboardUtils *)sharedInstance {
    return sharedInstance;
}

+ (void)load {
    @autoreleasepool {
        sharedInstance = [self new];
    }
}

+ (BOOL)visible {
    return [[self sharedInstance] visible];
}

+ (CGFloat)height {
    return [[self sharedInstance] height];
}

- (id)init {
    if (self = [super init]) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(willShow:) name:UIKeyboardWillShowNotification object:nil];
        [center addObserver:self selector:@selector(willHide) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (BOOL)visible {
    return visible;
}

- (CGFloat)height {
    return kbHeight;
}

- (void)willShow:(NSNotification *)notification {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        CGFloat formSheetHeight = 576;
        // statusBarOrientation is a no-op on iOS 27; the screen bounds follow the interface orientation.
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        if (screenSize.width > screenSize.height) {
            kbHeight = formSheetHeight - 352;
        } else {
            kbHeight = formSheetHeight - 504;
        }
    } else {
        NSDictionary* info = [notification userInfo];
        CGRect rect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        // The keyboard frame is in interface-oriented coordinates, so its height is correct in any orientation.
        kbHeight = rect.size.height;
    }
    visible = YES;
}

- (void)willHide {
    visible = NO;
}

@end
