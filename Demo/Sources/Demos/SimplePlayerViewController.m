//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SimplePlayerViewController.h"

#import <SRGLetterbox/SRGLetterbox.h>

@interface SimplePlayerViewController ()

@property (nonatomic) SRGMediaURN *URN;

@end

@implementation SimplePlayerViewController

#pragma mark Object lifecycle

- (instancetype)initWithURN:(SRGMediaURN *)URN
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:NSStringFromClass([self class]) bundle:nil];
    SimplePlayerViewController *viewController = [storyboard instantiateInitialViewController];
    viewController.URN = URN;
    return viewController;
}

- (instancetype)init
{
    return [self initWithURN:nil];
}

#pragma mark View lifecycle

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([self isMovingToParentViewController] || [self isBeingPresented]) {
        if (self.URN) {
            [[SRGLetterboxService sharedService] playURN:self.URN withPreferredQuality:SRGQualityNone];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
        SRGLetterboxService *service = [SRGLetterboxService sharedService];
        if (! service.pictureInPictureActive) {
            [service reset];
        }
    }
}

@end
