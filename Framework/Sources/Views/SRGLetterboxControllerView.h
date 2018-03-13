//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGLetterboxBaseView.h"
#import "SRGLetterboxController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SRGLetterboxControllerView : SRGLetterboxBaseView

/**
 *  The controller bound to the view.
 */
@property (nonatomic, weak, nullable) IBOutlet SRGLetterboxController *controller;

@end

NS_ASSUME_NONNULL_END
