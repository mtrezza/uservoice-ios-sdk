//
//  main.m
//  UserVoiceExample
//
//  A minimal host app for checking SDK screens in the simulator during development.
//  It presents the contact form on launch. It is not part of the published library.
//

#import <UIKit/UIKit.h>
#import <UserVoice/UserVoice.h>

// The contact form is presented through SDK internals so that it renders without a UserVoice site,
// network access or credentials; the public API first loads the site configuration over the network.
@interface UserVoice (Example)
+ (void)presentUserVoiceController:(UIViewController *)viewController forParentViewController:(UIViewController *)parentViewController;
@end

@interface ExampleViewController : UIViewController
@end

@implementation ExampleViewController {
    BOOL _presentedOnLaunch;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemGroupedBackgroundColor;

    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"Show Contact Form" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showContactForm) forControlEvents:UIControlEventTouchUpInside];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:button];
    [NSLayoutConstraint activateConstraints:@[
        [button.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [button.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
    ]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!_presentedOnLaunch) {
        _presentedOnLaunch = YES;
        [self showContactForm];
    }
}

- (void)showContactForm {
    UIViewController *contactViewController = [NSClassFromString(@"UVContactViewController") new];
    [UserVoice presentUserVoiceController:contactViewController forParentViewController:self];
}

@end

@interface ExampleSceneDelegate : UIResponder <UIWindowSceneDelegate>
@property (nonatomic, strong) UIWindow *window;
@end

@implementation ExampleSceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    self.window = [[UIWindow alloc] initWithWindowScene:(UIWindowScene *)scene];
    self.window.rootViewController = [ExampleViewController new];
    [self.window makeKeyAndVisible];
}

@end

@interface ExampleAppDelegate : UIResponder <UIApplicationDelegate>
@end

@implementation ExampleAppDelegate
@end

int main(int argc, char *argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass(ExampleAppDelegate.class));
    }
}
