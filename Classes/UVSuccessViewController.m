//
//  UVSuccessViewController.m
//  UserVoice
//
//  Created by Austin Taylor on 10/23/13.
//  Copyright (c) 2013 UserVoice Inc. All rights reserved.
//

#import "UVSuccessViewController.h"
#import "UVSession.h"
#import "UVClientConfig.h"
#import "UVStyleSheet.h"

@implementation UVSuccessViewController

- (void)loadView {
    [super loadView];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.view = [UIView new];
    self.view.frame = [self contentFrame];
    // Same background as the forms that lead here
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    UILabel *icon = [UILabel new];
    icon.text = @"\U0001F973";
    icon.font = [UIFont systemFontOfSize:64];
    UILabel *title = [UILabel new];
    title.text = _titleText;
    title.textColor = [UIColor labelColor];
    title.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
    title.font = [UIFont fontWithDescriptor:[title.font.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold] size:0];
    title.adjustsFontForContentSizeCategory = YES;
    title.numberOfLines = 0;
    title.textAlignment = NSTextAlignmentCenter;
    UILabel *text = [UILabel new];
    text.text = _text;
    text.textColor = [UIColor secondaryLabelColor];
    text.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    text.adjustsFontForContentSizeCategory = YES;
    text.numberOfLines = 0;
    text.textAlignment = NSTextAlignmentCenter;
    // Styled like the Next button of the forms, including the style sheet options that apply to it
    UIButtonConfiguration *configuration;
    UIColor *buttonColor;
    NSDictionary *titleAttributes;
    if (@available(iOS 26.0, *)) {
        configuration = [UIButtonConfiguration prominentGlassButtonConfiguration];
        buttonColor = [UVStyleSheet instance].navigationBarButtonColor;
        titleAttributes = [UVStyleSheet instance].navigationBarAppearance.prominentButtonAppearance.normal.titleTextAttributes;
    } else {
        configuration = [UIButtonConfiguration filledButtonConfiguration];
        configuration.cornerStyle = UIButtonConfigurationCornerStyleCapsule;
    }
    configuration.buttonSize = UIButtonConfigurationSizeLarge;
    configuration.title = NSLocalizedStringFromTableInBundle(@"Close", @"UserVoice", [UserVoice bundle], nil);
    configuration.contentInsets = NSDirectionalEdgeInsetsMake(14, 32, 14, 32);
    configuration.titleTextAttributesTransformer = ^NSDictionary *(NSDictionary *attributes) {
        NSMutableDictionary *result = [attributes mutableCopy];
        UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
        descriptor = [descriptor fontDescriptorByAddingAttributes:@{UIFontDescriptorTraitsAttribute: @{UIFontWeightTrait: @(UIFontWeightSemibold)}}];
        result[NSFontAttributeName] = [UIFont fontWithDescriptor:descriptor size:0];
        [result addEntriesFromDictionary:titleAttributes];
        return result;
    };
    UIButton *button = [UIButton buttonWithConfiguration:configuration primaryAction:nil];
    button.tintColor = buttonColor;
    [button addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[icon, title, text, button]];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.alignment = UIStackViewAlignmentCenter;
    stack.spacing = 8;
    [stack setCustomSpacing:20 afterView:icon];
    [stack setCustomSpacing:32 afterView:text];
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:stack];
    UILayoutGuide *guide = self.view.readableContentGuide;
    [NSLayoutConstraint activateConstraints:@[
        [stack.centerYAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.centerYAnchor],
        [stack.leadingAnchor constraintEqualToAnchor:guide.leadingAnchor constant:16],
        [stack.trailingAnchor constraintEqualToAnchor:guide.trailingAnchor constant:-16],
        [stack.topAnchor constraintGreaterThanOrEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [button.widthAnchor constraintGreaterThanOrEqualToConstant:140],
    ]];
}

// The bar is hidden, so the status bar sits on the background here instead of on the bar that the style sheet's
// status bar style is meant for
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

@end
