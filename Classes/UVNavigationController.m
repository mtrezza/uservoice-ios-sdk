//
//  UVNavigationController.m
//  UserVoice
//
//  Created by Austin Taylor on 11/1/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import "UVNavigationController.h"
#import "UVStyleSheet.h"

@implementation UVNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    UVStyleSheet *styles = [UVStyleSheet instance];
    UINavigationBarAppearance *appearance = styles.navigationBarAppearance;
    if (appearance) {
        self.navigationBar.standardAppearance = appearance;
        self.navigationBar.compactAppearance = appearance;
        self.navigationBar.scrollEdgeAppearance = appearance;
        self.navigationBar.compactScrollEdgeAppearance = appearance;
    }
    if (styles.navigationBarButtonColor) {
        self.navigationBar.tintColor = styles.navigationBarButtonColor;
    }
}

- (BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [UVStyleSheet instance].preferredStatusBarStyle;
}

@end