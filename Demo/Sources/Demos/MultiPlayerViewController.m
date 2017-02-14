//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "MultiPlayerViewController.h"

#import "UIWindow+LetterboxDemo.h"

#import <SRGAnalytics/SRGAnalytics.h>

@interface MultiPlayerViewController ()

@property (nonatomic, weak) IBOutlet SRGLetterboxView *letterboxView;
@property (nonatomic, weak) IBOutlet SRGLetterboxView *smallLetterboxView1;
@property (nonatomic, weak) IBOutlet SRGLetterboxView *smallLetterboxView2;

@property (nonatomic) IBOutlet SRGLetterboxController *letterboxController;
@property (nonatomic) IBOutlet SRGLetterboxController *smallLetterboxController1;
@property (nonatomic) IBOutlet SRGLetterboxController *smallLetterboxController2;

@property (nonatomic, weak) IBOutlet UIButton *closeButton;

@end

@implementation MultiPlayerViewController

#pragma mark Object lifecycle

- (instancetype)init
{
    id<SRGLetterboxPictureInPictureDelegate> pictureInPictureDelegate = [SRGLetterboxService sharedService].pictureInPictureDelegate;
    
    // If an equivalent view controller was dismissed for picture in picture of the same media, simply restore it
    if ([pictureInPictureDelegate isKindOfClass:[self class]]) {
        return (MultiPlayerViewController *)pictureInPictureDelegate;
    }
    else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:NSStringFromClass([self class]) bundle:nil];
        return [storyboard instantiateInitialViewController];
    }
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[SRGLetterboxService sharedService] enableWithController:self.letterboxController pictureInPictureDelegate:self];
    
    self.smallLetterboxController1.muted = YES;
    self.smallLetterboxController1.tracked = NO;
    
    self.smallLetterboxController2.muted = YES;
    self.smallLetterboxController2.tracked = NO;
    
    [self.smallLetterboxView1 setUserInterfaceHidden:YES animated:NO togglable:NO];
    [self.smallLetterboxView2 setUserInterfaceHidden:YES animated:NO togglable:NO];
    
    UIGestureRecognizer *tapGestureRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchToStream1:)];
    [self.smallLetterboxView1 addGestureRecognizer:tapGestureRecognizer1];
    
    UIGestureRecognizer *tapGestureRecognizer2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchToStream2:)];
    [self.smallLetterboxView2 addGestureRecognizer:tapGestureRecognizer2];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self isMovingToParentViewController] || [self isBeingPresented]) {
        if (! self.letterboxController.pictureInPictureActive) {
            SRGMediaURN *URN = [SRGMediaURN mediaURNWithString:@"urn:rts:video:3608506"];
            [self.letterboxController playURN:URN];
            
            SRGMediaURN *URN1 = [SRGMediaURN mediaURNWithString:@"urn:rts:video:3608517"];
            [self.smallLetterboxController1 playURN:URN1];
            
            SRGMediaURN *URN2 = [SRGMediaURN mediaURNWithString:@"urn:rts:video:1967124"];
            [self.smallLetterboxController2 playURN:URN2];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
        if (! self.letterboxController.pictureInPictureActive) {
            [self.letterboxController reset];
            [[SRGLetterboxService sharedService] disableForController:self.letterboxController];
        }
    }
}

#pragma mark SRGLetterboxPictureInPictureDelegate protocol

- (BOOL)letterboxDismissUserInterfaceForPictureInPicture
{
    [self dismissViewControllerAnimated:YES completion:nil];
    return YES;
}

- (BOOL)letterboxShouldRestoreUserInterfaceForPictureInPicture
{
    UIViewController *topPresentedViewController = [UIApplication sharedApplication].keyWindow.topPresentedViewController;
    return topPresentedViewController != self;
}

- (void)letterboxRestoreUserInterfaceForPictureInPictureWithCompletionHandler:(void (^)(BOOL))completionHandler
{
    UIViewController *topPresentedViewController = [UIApplication sharedApplication].keyWindow.topPresentedViewController;
    [topPresentedViewController presentViewController:self animated:YES completion:^{
        completionHandler(YES);
    }];
}

- (void)letterboxDidStartPictureInPicture
{
    [[SRGAnalyticsTracker sharedTracker] trackHiddenEventWithTitle:@"pip_start"];
}

- (void)letterboxDidEndPictureInPicture
{
    [[SRGAnalyticsTracker sharedTracker] trackHiddenEventWithTitle:@"pip_end"];
}

- (void)letterboxDidStopPlaybackFromPictureInPicture
{
    [self.letterboxController reset];
    [[SRGLetterboxService sharedService] disableForController:self.letterboxController];
}

#pragma mark SRGLetterboxViewDelegate protocol

- (void)letterboxViewWillAnimateUserInterface:(SRGLetterboxView *)letterboxView
{
    [letterboxView animateAlongsideUserInterfaceWithAnimations:^(BOOL hidden) {
        self.closeButton.alpha = hidden ? 0.f : 1.f;
    } completion:nil];
}

#pragma mark Actions

- (IBAction)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Gesture recognizers

- (void)switchToStream1:(UIGestureRecognizer *)gestureRecognizer
{
    // Swap controllers
    SRGLetterboxController *tempLetterboxController = self.letterboxController;
    
    self.letterboxController = self.smallLetterboxController1;
    self.letterboxView.controller = self.smallLetterboxController1;
    
    self.smallLetterboxController1 = tempLetterboxController;
    self.smallLetterboxView1.controller = tempLetterboxController;
    
    self.letterboxController.muted = NO;
    self.letterboxController.tracked = YES;
    [[SRGLetterboxService sharedService] enableWithController:self.letterboxController pictureInPictureDelegate:self];
    
    self.smallLetterboxController1.muted = YES;
    self.smallLetterboxController1.tracked = NO;
}

- (void)switchToStream2:(UIGestureRecognizer *)gestureRecognizer
{
    // Swap controllers
    SRGLetterboxController *tempLetterboxController = self.letterboxController;
    
    self.letterboxController = self.smallLetterboxController2;
    self.letterboxView.controller = self.smallLetterboxController2;
    
    self.smallLetterboxController2 = tempLetterboxController;
    self.smallLetterboxView2.controller = tempLetterboxController;
    
    self.letterboxController.muted = NO;
    self.letterboxController.tracked = YES;
    [[SRGLetterboxService sharedService] enableWithController:self.letterboxController pictureInPictureDelegate:self];
    
    self.smallLetterboxController2.muted = YES;
    self.smallLetterboxController2.tracked = NO;
}

@end
