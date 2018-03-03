//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGLetterboxControllerView.h"

@implementation SRGLetterboxControllerView

#pragma mark Getters and setters

- (void)setController:(SRGLetterboxController *)controller
{
    _controller = controller;
    
    [self updateForController:controller];
}

#pragma mark Subclassing hooks

- (void)updateForController:(SRGLetterboxController *)controller
{}

@end
