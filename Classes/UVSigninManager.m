//
//  UVSigninManager.m
//  UserVoice
//
//  Created by Austin Taylor on 11/20/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import "UVSigninManager.h"
#import "UserVoice.h"
#import "UVSession.h"
#import "UVUser.h"
#import "UVAccessToken.h"
#import "UVUtils.h"
#import "UVRequestToken.h"
#import "UVBabayaga.h"
#import <Foundation/NSRegularExpression.h>

@interface UVSigninManager()
@property (nonatomic, retain) UIAlertController *alertController;
@end


@implementation UVSigninManager {
    NSInteger _state;
    UVCallback *_callback;
    NSRegularExpression *_emailFormat;
}

+ (UVSigninManager *)manager {
    return [self new];
}

- (UVSigninManager *)init {
    if ((self = [super init])) {
        _emailFormat = [NSRegularExpression regularExpressionWithPattern:@"\\A(\\w[-+.\\w!\\#\\$%&'\\*\\+\\-/=\\?\\^_`\\{\\|\\}~]*@([-\\w]*\\.)+[a-zA-Z]{2,9})\\z" options:NSRegularExpressionCaseInsensitive error:nil];
    }
    return self;
}

- (void)showEmailAlertView {
    _state = STATE_EMAIL;

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTableInBundle(@"Enter your email", @"UserVoice", [UserVoice bundle], nil)
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.keyboardType = UIKeyboardTypeEmailAddress;
        textField.returnKeyType = UIReturnKeyDone;
        textField.delegate = self;
    }];
    [self addButtonsWithTitles:@[NSLocalizedStringFromTableInBundle(@"Cancel", @"UserVoice", [UserVoice bundle], nil), NSLocalizedStringFromTableInBundle(@"Done", @"UserVoice", [UserVoice bundle], nil)] toAlert:alert];
    [self showAlert:alert];
}

- (void)showPasswordAlertView {
    _state = STATE_PASSWORD;

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"Enter UserVoice password for %@", @"UserVoice", [UserVoice bundle], nil), _email]
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.secureTextEntry = YES;
        textField.returnKeyType = UIReturnKeyDone;
        textField.delegate = self;
    }];
    [self addButtonsWithTitles:@[NSLocalizedStringFromTableInBundle(@"Cancel", @"UserVoice", [UserVoice bundle], nil), NSLocalizedStringFromTableInBundle(@"Sign in", @"UserVoice", [UserVoice bundle], nil)] toAlert:alert];
    [self showAlert:alert];
}

- (void)showFailedAlertView {
    _state = STATE_FAILED;

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTableInBundle(@"There was a problem logging you in.", @"UserVoice", [UserVoice bundle], nil)
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [self addButtonsWithTitles:@[NSLocalizedStringFromTableInBundle(@"Try again", @"UserVoice", [UserVoice bundle], nil), NSLocalizedStringFromTableInBundle(@"Forgot password", @"UserVoice", [UserVoice bundle], nil), NSLocalizedStringFromTableInBundle(@"Cancel", @"UserVoice", [UserVoice bundle], nil)] toAlert:alert];
    [self showAlert:alert];
}

- (void)showUnknownError {
    [self showMessageAlertWithTitle:NSLocalizedStringFromTableInBundle(@"There was a problem logging you in.", @"UserVoice", [UserVoice bundle], nil) buttonTitle:NSLocalizedStringFromTableInBundle(@"Done", @"UserVoice", [UserVoice bundle], nil)];
    [self invokeDidFail];
}

- (void)showEmailFormatError {
    [self showMessageAlertWithTitle:NSLocalizedStringFromTableInBundle(@"Please enter a valid email address.", @"UserVoice", [UserVoice bundle], nil) buttonTitle:NSLocalizedStringFromTableInBundle(@"Done", @"UserVoice", [UserVoice bundle], nil)];
    [self invokeDidFail];
}

/// Adds one action per title. Tapping one calls alertButtonTappedAtIndex: with its position, matching
/// the button indexes the UIAlertView-based flow used.
- (void)addButtonsWithTitles:(NSArray *)titles toAlert:(UIAlertController *)alert {
    __weak UVSigninManager *weakSelf = self;
    [titles enumerateObjectsUsingBlock:^(NSString *title, NSUInteger index, BOOL *stop) {
        [alert addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [weakSelf alertButtonTappedAtIndex:index];
        }]];
    }];
}

/// A single-button alert that only informs; tapping the button does nothing else.
- (void)showMessageAlertWithTitle:(NSString *)title buttonTitle:(NSString *)buttonTitle {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:buttonTitle style:UIAlertActionStyleDefault handler:nil]];
    [self showAlert:alert];
}

- (void)showAlert:(UIAlertController *)alert {
    _alertController = alert;
    [UVUtils presentAlertController:alert];
}

- (void)signInWithCallback:(UVCallback *)callback {
    if ([self user]) {
        [callback invokeCallback:nil];
    } else {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *storedEmail = [prefs stringForKey:@"uv-user-email"];
        NSString *storedName = [prefs stringForKey:@"uv-user-name"];
        if (storedEmail && [storedEmail length] > 0) {
            [self signInWithEmail:storedEmail name:storedName callback:callback];
        } else {
            _callback = callback;
            [self showEmailAlertView];
        }
    }
}

- (void)signInWithEmail:(NSString *)theEmail name:(NSString *)theName callback:(UVCallback *)callback {
    if (self.user && [self.user.email isEqualToString:theEmail]) {
        [callback invokeCallback:nil];
    } else if ([_emailFormat numberOfMatchesInString:theEmail options:0 range:NSMakeRange(0, [theEmail length])] == 0) {
        [self showEmailFormatError];
    } else {
        _state = STATE_EMAIL;
        _email = theEmail;
        _name = theName;
        _callback = callback;
        [UVUser discoverWithEmail:_email delegate:self];
    }
}

- (UVUser *)user {
    return [UVSession currentSession].user;
}

#pragma mark - Invoke UVSigninManagerDelegate methods

- (void)invokeDidSignIn {
    if (_callback) {
        [_callback invokeCallback:self.user];
        _callback = nil;
    }

    if ([_delegate respondsToSelector:@selector(signinManagerDidSignIn:)]) {
        [_delegate signinManagerDidSignIn:self.user];
    }
}

- (void)invokeDidFail {
    if ([_delegate respondsToSelector:@selector(signinManagerDidFail)]) {
        [_delegate signinManagerDidFail];
    }
}

- (void)didRetrieveAccessToken:(UVAccessToken *)token {
    [token persist];
    [UVSession currentSession].accessToken = token;
    [UVUser retrieveCurrentUser:self];
}


#pragma mark - UVUserDelegate

- (void)didCreateUser:(UVUser *)theUser {
    [UVSession currentSession].user = theUser;
    [[UVSession currentSession].accessToken persist];
    [UVBabayaga track:AUTHENTICATE];
    [self invokeDidSignIn];
}

- (void)didRetrieveCurrentUser:(UVUser *)theUser {
    [UVSession currentSession].user = theUser;
    [UVBabayaga track:AUTHENTICATE];
    [self invokeDidSignIn];
}

- (void)didDiscoverUser:(UVUser *)theUser {
    [self showPasswordAlertView];
}

- (void)didSendForgotPassword:(id)obj {
    [self showMessageAlertWithTitle:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"Password reset email sent to %@", @"UserVoice", [UserVoice bundle], nil), _email]
                        buttonTitle:NSLocalizedStringFromTableInBundle(@"OK", @"UserVoice", [UserVoice bundle], nil)];

    [self invokeDidFail];
}

- (void)alertButtonTappedAtIndex:(NSInteger)buttonIndex {
    if (_state == STATE_EMAIL) {
        if (buttonIndex == 1) {
            NSString *text = _alertController.textFields.firstObject.text;
            if (text.length == 0)
                return;

            _email = text;
            [UVUser discoverWithEmail:text delegate:self];
        }
    } else if (_state == STATE_PASSWORD) {
        if (buttonIndex == 1) {
            _password = _alertController.textFields.firstObject.text;
            if ([UVSession currentSession].requestToken == nil) {
                [UVRequestToken getRequestTokenWithDelegate:self];
            } else {
                [UVAccessToken getAccessTokenWithDelegate:self andEmail:_email andPassword:_password];
                _password = nil;
            }
        } else {
            [self invokeDidFail];
        }
    } else if (_state == STATE_FAILED) {
        if (buttonIndex == 0) {
            [self showPasswordAlertView];
        } else if (buttonIndex == 1) {
            [UVUser forgotPassword:_email delegate:self];
        } else {
            [self invokeDidFail];
        }
    }
}

- (void)didRetrieveRequestToken:(UVRequestToken *)token {
    [UVSession currentSession].requestToken = token;
    if (_state == STATE_EMAIL) {
        [UVUser findOrCreateWithEmail:_email andName:_name andDelegate:self];
    } else if (_state == STATE_PASSWORD) {
        [UVAccessToken getAccessTokenWithDelegate:self andEmail:_email andPassword:_password];
        _password = nil;
    }
}

- (void)didReceiveError:(NSError *)error {
    if (_state == STATE_EMAIL && [UVUtils isNotFoundError:error]) {
        if ([UVSession currentSession].requestToken == nil) {
            [UVRequestToken getRequestTokenWithDelegate:self];
        } else {
            [UVUser findOrCreateWithEmail:_email andName:_name andDelegate:self];
        }
    } else if (_state == STATE_EMAIL) {
        [self showUnknownError];
    } else if ([UVUtils isAuthError:error] || [UVUtils isNotFoundError:error]) {
        [self showFailedAlertView];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // Return acts as the alert's second button ("Done" / "Sign in").
    __weak UVSigninManager *weakSelf = self;
    [_alertController dismissViewControllerAnimated:YES completion:^{
        [weakSelf alertButtonTappedAtIndex:1];
    }];
    return YES;
}

@end
