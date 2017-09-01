//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSNotificationCenter (Tests)

- (id<NSObject>)addObserverForLetterboxControllerPlaybackStateDidChangeNotificationUsingBlock:(void (^)(NSNotification *notification))block;

@end

NS_ASSUME_NONNULL_END
