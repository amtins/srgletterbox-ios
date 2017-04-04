//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "UIImage+SRGLetterbox.h"

#import <SRGDataProvider/SRGDataProvider.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (SRGLetterbox)

/**
 *  Standard loading indicator. Call `-startAnimating` to animate.
 */
+ (UIImageView *)srg_loadingImageView35WithTintColor:(nullable UIColor *)tintColor;

/**
 *  Request an image for the specified object, for a given scale.
 *
 *  @param object               The object to request the image for.
 *  @param scale                The scale to use
 *  @param placeholderImageName The name of the placeholder image name to use
 */
- (void)srg_requestImageForObject:(nullable id<SRGImageMetadata>)object
                        withScale:(SRGImageScale)imageScale
             placeholderImageName:(nullable NSString *)placeholderImageName;
- (void)srg_cancelCurrentImageRequest;

@end

NS_ASSUME_NONNULL_END
