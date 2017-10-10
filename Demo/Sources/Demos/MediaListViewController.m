//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "MediaListViewController.h"

#import "ModalPlayerViewController.h"
#import "NSBundle+LetterboxDemo.h"
#import "SettingsViewController.h"

#import <SRGDataProvider/SRGDataProvider.h>

@interface MediaListViewController ()

@property (nonatomic) MediaListType mediaListType;
@property (nonatomic, nullable) NSString *uid;

@property (nonatomic) SRGDataProvider *dataProvider;
@property (nonatomic, weak) SRGRequest *request;

@property (nonatomic) NSArray<SRGMedia *> *medias;

@end

@implementation MediaListViewController

#pragma mark Object lifecycle

- (instancetype)initWithMediaListType:(MediaListType)mediaListType uid:(NSString *)uid
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:NSStringFromClass([self class]) bundle:nil];
    MediaListViewController *viewController = [storyboard instantiateInitialViewController];
    viewController.mediaListType = mediaListType;
    viewController.uid = uid;
    return viewController;
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = [self pageTitle];
    
    static NSDictionary<NSNumber *, SRGDataProviderBusinessUnitIdentifier> *s_businessUnitIdentifiers;
    static dispatch_once_t s_onceToken;
    dispatch_once(&s_onceToken, ^{
        s_businessUnitIdentifiers = @{ @(MediaListLivecenterSRF) : SRGDataProviderBusinessUnitIdentifierSRF,
                                       @(MediaListLivecenterRTS) : SRGDataProviderBusinessUnitIdentifierRTS,
                                       @(MediaListLivecenterRSI) : SRGDataProviderBusinessUnitIdentifierRSI,
                                       @(MediaListMMFTopicList) : SRGDataProviderBusinessUnitIdentifierRTS };
    });
    
    SRGDataProviderBusinessUnitIdentifier businessUnitIdentifier = s_businessUnitIdentifiers[@(self.mediaListType)];
    NSAssert(businessUnitIdentifier != nil, @"The business unit must be supported");
    NSURL *serviceURL = (self.mediaListType == MediaListMMFTopicList) ? LetterboxDemoMMFServiceURL() : ApplicationSettingServiceURL();
    self.dataProvider = [[SRGDataProvider alloc] initWithServiceURL:serviceURL businessUnitIdentifier:businessUnitIdentifier];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:refreshControl atIndex:0];
    self.refreshControl = refreshControl;
    
    [self refresh];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
        [self.request cancel];
    }
}

#pragma mark Getters and setters

- (NSString *)pageTitle
{
    static dispatch_once_t s_onceToken;
    static NSDictionary<NSNumber *, NSString *> *s_titles;
    dispatch_once(&s_onceToken, ^{
        s_titles = @{ @(MediaListLivecenterSRF) : LetterboxDemoNonLocalizedString(@"SRF Live center"),
                      @(MediaListLivecenterRTS) : LetterboxDemoNonLocalizedString(@"RTS Live center"),
                      @(MediaListLivecenterRSI) : LetterboxDemoNonLocalizedString(@"RSI Live center"),
                      @(MediaListMMFTopicList) : LetterboxDemoNonLocalizedString(@"MMF topic list") };
    });
    return s_titles[@(self.mediaListType)] ?: LetterboxDemoNonLocalizedString(@"Unknown");
}

#pragma mark Data

- (void)refresh
{
    [self.request cancel];
    
    SRGRequest *request = nil;
    
    void (^completionBlock)(NSArray<SRGMedia *> * _Nullable, SRGPage *, SRGPage * _Nullable, NSError * _Nullable) = ^(NSArray<SRGMedia *> * _Nullable medias, SRGPage *page, SRGPage * _Nullable nextPage, NSError * _Nullable error) {
        if (self.refreshControl.refreshing) {
            [self.refreshControl endRefreshing];
        }
        
        self.medias = medias;
        [self.tableView reloadData];
    };
    
    if (self.mediaListType == MediaListMMFTopicList) {
        request = [self.dataProvider tvLatestMediasForTopicWithUid:self.uid completionBlock:completionBlock];
    }
    else {
        request =  [self.dataProvider liveCenterVideosWithCompletionBlock:completionBlock];
    }
    
    [request resume];
    self.request = request;
}

#pragma mark UITableViewDataSource protocol

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.medias.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView dequeueReusableCellWithIdentifier:@"MediaListCell" forIndexPath:indexPath];
}

#pragma mark UITableViewDelegate protocol

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    SRGMedia *media = self.medias[indexPath.row];
    NSString *text = media.title;
    if (media.blockingReason == SRGBlockingReasonStartDate) {
        text = [@"🔜 " stringByAppendingString:text];
    }
    else if (media.blockingReason == SRGBlockingReasonEndDate) {
        text = [@"🔚 " stringByAppendingString:text];
    }
    else if (media.contentType == SRGContentTypeLivestream || media.contentType == SRGContentTypeScheduledLivestream) {
        text = [@"⏺ " stringByAppendingString:text];
    }
    else {
        text = [@"▶️ " stringByAppendingString:text];
    }
    
    cell.textLabel.text = text;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SRGMediaURN *URN = [SRGMediaURN mediaURNWithString:self.medias[indexPath.row].URN.URNString];
    NSURL *serviceURL = (self.mediaListType == MediaListMMFTopicList) ? LetterboxDemoMMFServiceURL() : nil;
    NSNumber *updateIntervalNumber = (self.mediaListType == MediaListMMFTopicList) ? @(LetterboxDemoSettingUpdateIntervalShort) : nil;
    ModalPlayerViewController *playerViewController = [[ModalPlayerViewController alloc] initWithURN:URN chaptersOnly:NO serviceURL:serviceURL updateInterval:updateIntervalNumber];
    
    // Since might be reused, ensure we are not trying to present the same view controller while still dismissed
    // (might happen if presenting and dismissing fast)
    if (playerViewController.presentingViewController) {
        return;
    }
    
    [self presentViewController:playerViewController animated:YES completion:nil];
}

#pragma mark Actions

- (void)refresh:(id)sender
{
    [self refresh];
}

@end
