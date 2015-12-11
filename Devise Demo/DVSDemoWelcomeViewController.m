//
//  WelcomeViewController.m
//  Devise
//
//  Created by Grzegorz Lesiak on 20/11/14.
//  Copyright (c) 2014 Netguru.co. All rights reserved.
//

#import "DVSDemoWelcomeViewController.h"
#import "UIAlertView+DeviseDemo.h"
#import "DVSMacros.h"

#import "Devise.h"

static NSString * const DVSHomeSegue = @"DisplayHomeView";
static NSString * const DVSDefaultWelcomeCell = @"defaultCell";
static NSString * const DVSTitleForAlertCancelButton = @"Close";


@interface DVSDemoWelcomeViewController () <DVSAccountRetrieverViewControllerDelegate>

@end

@implementation DVSDemoWelcomeViewController

#pragma mark - Object lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDataSource];
}

#pragma mark - Setup

- (void)setupDataSource {
    [self addMenuEntryWithTitle:NSLocalizedString(@"Sign up", nil)
                       subtitle:NSLocalizedString(@"Create new account", nil)
             accessibilityLabel:DVSAccessibilityLabel(@"Sign up")
                         target:self
                         action:@selector(didSelectRegister)];
    
    [self addMenuEntryWithTitle:NSLocalizedString(@"Log in", nil)
                       subtitle:NSLocalizedString(@"Already registered?", nil)
             accessibilityLabel:DVSAccessibilityLabel(@"Log in")
                         target:self
                         action:@selector(didSelectLogIn)];

    [self addMenuEntryWithTitle:NSLocalizedString(@"Sign in using Facebook", nil)
                       subtitle:nil
             accessibilityLabel:DVSAccessibilityLabel(@"Sign in using Facebook")
                         target:self
                         action:@selector(didSelectFacebookSigning)];

    [self addMenuEntryWithTitle:NSLocalizedString(@"Sign in using Google", nil)
                       subtitle:nil
             accessibilityLabel:DVSAccessibilityLabel(@"Sign in using Google")
                         target:self
                         action:@selector(didSelectGoogleSigning)];
}

#pragma mark - Menu actions

- (void)didSelectLogIn {
    
    DVSAccountRetrieverFields logInFields = DVSAccountRetrieverFieldEmailAndPassword | DVSAccountRetrieverFieldProceedButton | DVSAccountRetrieverFieldPasswordReminder;
    DVSAccountRetrieverViewController *logInController = [[DVSAccountRetrieverViewController alloc] initWithType:DVSRetrieverTypeLogIn fields:logInFields];
    
    logInController.delegate = self;
    [self.navigationController pushViewController:logInController animated:YES];
}

- (void)didSelectRegister {
    DVSAccountRetrieverFields signUpFields = DVSAccountRetrieverFieldEmailAndPassword | DVSAccountRetrieverFieldProceedButton;
    DVSAccountRetrieverViewController *signUpController = [[DVSAccountRetrieverViewController alloc] initWithType:DVSRetrieverTypeSignUp fields:signUpFields];
    
    signUpController.delegate = self;
    [self.navigationController pushViewController:signUpController animated:YES];
}

- (void)didSelectFacebookSigning {
    [[DVSUserManager defaultManager] signInUsingFacebookWithSuccess:^{
        [self moveToHomeView];
    } failure:^(NSError *error) {
        [self handleSignInWithFacebookError:error];
    }];
}

- (void)didSelectGoogleSigning {
    [[DVSUserManager defaultManager] signInUsingGoogleWithSuccess:^{
        [self moveToHomeView];
    } failure:^(NSError *error) {
        [self handleSignInWithGoogleError:error];
    }];
}

#pragma mark - DVSMenuTableViewController methods

- (NSString *)defaultCellId {
    return DVSDefaultWelcomeCell;
}

#pragma mark - DVSAccountRetrieverViewControllerDelegate

- (void)accountRetrieverViewController:(DVSAccountRetrieverViewController *)controller didSuccessForAction:(DVSRetrieverAction)action user:(DVSUser *)user {
    switch (action) {
        case DVSRetrieverActionLogIn:
        case DVSRetrieverActionSignUp:
            [self moveToHomeView];
            break;
            
        case DVSRetrieverActionPasswordRemind:
            [self handlePasswordRemind];
            break;
            
        default:
            break;
    }
}

- (void)accountRetrieverViewController:(DVSAccountRetrieverViewController *)controller didFailWithError:(NSError *)error forAction:(DVSRetrieverAction)action {
    switch (action) {
        case DVSRetrieverActionLogIn:
            [self handleLogInError:error];
            break;
            
        case DVSRetrieverActionSignUp:
            [self handleSignUpError:error];
            break;
            
        case DVSRetrieverActionPasswordRemind:
            [self handlePasswordRemindError:error];
            break;
    }
}

- (void)accountRetrieverViewControllerDidTapDismiss:(DVSAccountRetrieverViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Actions

- (void)moveToHomeView {
    [self performSegueWithIdentifier:DVSHomeSegue sender:self];
}

- (void)handlePasswordRemind {
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Remind successful", nil)
                                message:NSLocalizedString(@"You will receive e-mail with instructions how to reset your password.", nil)
                               delegate:self
                      cancelButtonTitle:NSLocalizedString(DVSTitleForAlertCancelButton, nil)
                      otherButtonTitles:nil] show];
}

- (void)handleLogInError:(NSError *)error {
    UIAlertView *errorAlert = [UIAlertView dvs_alertViewForError:error
                                    statusDescriptionsDictionary:@{ @401: NSLocalizedString(@"Incorrect e-mail or password.", nil) }];
    [errorAlert show];
}

- (void)handleSignUpError:(NSError *)error {
    UIAlertView *errorAlert = [UIAlertView dvs_alertViewForError:error
                                    statusDescriptionsDictionary:@{ @422: NSLocalizedString(@"E-mail is already taken.", nil) }];
    [errorAlert show];
}

- (void)handleSignInWithFacebookError:(NSError *)error {
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Facebook login failed.", nil)
                                                         message:[error localizedDescription]
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [errorAlert show];
    });
}

- (void)handleSignInWithGoogleError:(NSError *)error {
    UIAlertView *errorAlert = [UIAlertView dvs_alertViewForError:error
                                    statusDescriptionsDictionary:@{ @0: NSLocalizedString(@"Google login failed.", nil) }];
    [errorAlert show];
}

- (void)handlePasswordRemindError:(NSError *)error {
    UIAlertView *errorAlert = [UIAlertView dvs_alertViewForError:error
                                    statusDescriptionsDictionary:@{ @404: NSLocalizedString(@"Account for given e-mail does not exist.", nil) }];
    [errorAlert show];
}

@end

