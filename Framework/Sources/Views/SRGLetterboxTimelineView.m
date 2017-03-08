//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGLetterboxTimelineView.h"

#import "NSBundle+SRGLetterbox.h"
#import "SRGLetterboxSegmentCell.h"

#import <libextobjc/libextobjc.h>
#import <MAKVONotificationCenter/MAKVONotificationCenter.h>
#import <Masonry/Masonry.h>
#import <SRGAnalytics_DataProvider/SRGAnalytics_DataProvider.h>

static void commonInit(SRGLetterboxTimelineView *self);

@interface SRGLetterboxTimelineView ()

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@end

@implementation SRGLetterboxTimelineView

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

#pragma mark Getters and setters

- (void)setSegments:(NSArray<SRGSegment *> *)segments
{
    _segments = segments;
    [self.collectionView reloadData];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    if (selectedIndex >= self.segments.count) {
        selectedIndex = NSNotFound;
    }
    
    _selectedIndex = selectedIndex;
    [self updateCellAppearance];
}

- (void)setTime:(CMTime)time
{
    _time = time;
    [self updateCellAppearance];
}

#pragma mark Overrides

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    self.collectionView.alwaysBounceHorizontal = YES;
    
    UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    collectionViewLayout.minimumLineSpacing = 1.f;
    
    NSString *identifier = NSStringFromClass([SRGLetterboxSegmentCell class]);
    UINib *nib = [UINib nibWithNibName:identifier bundle:[NSBundle srg_letterboxBundle]];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    CGFloat height = CGRectGetHeight(self.frame);
    collectionViewLayout.itemSize = CGSizeMake(16.f / 13.f * height, height);
    
    [self.collectionView.collectionViewLayout invalidateLayout];
}

#pragma mark Cell appearance

// We must not call -reloadData to update cells when not necessary (this invalidates taps)
// Also see http://stackoverflow.com/questions/23940419/uicollectionview-cell-cant-be-selected-after-reload-in-case-if-cell-was-touched
- (void)updateCellAppearance
{
    for (SRGLetterboxSegmentCell *cell in self.collectionView.visibleCells) {
        [self updateAppearanceForCell:cell];
    }
}

- (void)updateAppearanceForCell:(SRGLetterboxSegmentCell *)cell
{
    SRGSegment *segment = cell.segment;
    
    NSUInteger index = [self.segments indexOfObject:segment];
    cell.current = (index == self.selectedIndex);
    
    // Only display time progress for segments, not chapters
    if (! [segment isKindOfClass:[SRGChapter class]]) {
        // Clamp progress so that past segments have progress = 1 and future ones have progress = 0
        float progress = CMTimeGetSeconds(CMTimeSubtract(self.time, segment.srg_timeRange.start)) / CMTimeGetSeconds(segment.srg_timeRange.duration);
        cell.progress = fminf(1.f, fmaxf(0.f, progress));
    }
    else {
        cell.progress = 0.f;
    }
}

#pragma mark Scrolling

- (void)scrollToSelectedIndexAnimated:(BOOL)animated
{
    if (self.selectedIndex == NSNotFound) {
        return;
    }
    
    if (self.collectionView.dragging) {
        return;
    }
    
    void (^animations)(void) = ^{
        if (self.selectedIndex < [self.collectionView numberOfItemsInSection:0]) {
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.selectedIndex inSection:0]
                                        atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                                animated:NO];
        }
    };
    
    if (animated) {
        // Override the standard scroll to item animation duration for faster snapping
        [UIView animateWithDuration:0.1 animations:animations completion:nil];
    }
    else {
        animations();
    }
}

#pragma mark UICollectionViewDataSource protocol

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.segments.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([SRGLetterboxSegmentCell class]) forIndexPath:indexPath];
}

#pragma mark UICollectionViewDelegate protocol

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SRGSegment *segment = self.segments[indexPath.row];
    [self.delegate letterboxTimelineView:self didSelectSegment:segment];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(SRGLetterboxSegmentCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    cell.delegate = self;
    cell.segment = self.segments[indexPath.row];
    [self updateAppearanceForCell:cell];
}

#pragma mark SRGLetterboxSegmentCellDelegate protocol

- (void)letterboxSegmentCellDidLongPress:(SRGLetterboxSegmentCell *)letterboxSegmentCell
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(letterboxTimelineView:didLongPressOnSegmentdidLongPressOnSegment:)]) {
        [self.delegate letterboxTimelineView:self didLongPressOnSegmentdidLongPressOnSegment:letterboxSegmentCell.segment];
    }
}

- (BOOL)letterboxSegmentCellHideFavoriteImage:(SRGLetterboxSegmentCell *)letterboxSegmentCell
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(letterboxTimelineView:hideFavoriteImageOnSegment:)]) {
        return [self.delegate letterboxTimelineView:self hideFavoriteImageOnSegment:letterboxSegmentCell.segment];
    }
    else {
        return YES;
    }
}

@end

static void commonInit(SRGLetterboxTimelineView *self)
{
    // This makes design in a xib and Interface Builder preview (IB_DESIGNABLE) work. The top-level view must NOT be
    // an SRGLetterboxTimelineView to avoid infinite recursion
    UIView *view = [[[NSBundle srg_letterboxBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] firstObject];
    [self addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    self.selectedIndex = NSNotFound;
    self.backgroundColor = [UIColor clearColor];
}