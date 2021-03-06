//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGFullScreenButton.h"

#import "NSBundle+SRGLetterbox.h"

static void commonInit(SRGFullScreenButton *self);

@implementation SRGFullScreenButton

#pragma mark Object lifecycle

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        commonInit(self);
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        commonInit(self);
    }
    return self;
}

#pragma mark Accessibility

- (NSString *)accessibilityLabel
{
    return self.selected ? SRGLetterboxAccessibilityLocalizedString(@"Exit full screen", @"Full screen button label in the letterbox view, when the view is in the full screen state") : SRGLetterboxAccessibilityLocalizedString(@"Full screen", @"Full screen button label in the letterbox view, when the view is NOT in the full screen state");
}

#pragma mark Interface Builder integration

- (void)prepareForInterfaceBuilder
{
    [super prepareForInterfaceBuilder];
    
    commonInit(self);
}

@end

static void commonInit(SRGFullScreenButton *self)
{
    [self setImage:[UIImage imageNamed:@"fullscreen-48" inBundle:NSBundle.srg_letterboxBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:@"cancel_fullscreen-48" inBundle:NSBundle.srg_letterboxBundle compatibleWithTraitCollection:nil] forState:UIControlStateSelected];
}
