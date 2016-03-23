#import "FeaturedConversationCollectionViewController.h"
#import "UIColor+Rivet.h"
#import "UIFont+Rivet.h"
#import "ConversationRepository.h"
#import "AppState.h"
#import "ConversationCache.h"
#import "SortUtil.h"
#import "ConstUtil.h"
#import "FeaturedConversationCollectionViewCell.h"
#import "EventTrackingUtil.h"
#import "ListContainerViewController.h"
#import "BarOnBottomNavigationDelegate.h"
#import "FeaturedConversationFlowLayout.h"
#import "LocationUtil.h"
#import "UserRepository.h"
#import "EmptyFeaturedConversationCollectionViewCell.h"

NSString *const kFeaturedConversationControllerTag = @"FEATURED_CONVERSATION_CONTROLLER_TAG";
NSString *const kFeaturedConversationCellViewIdentifier = @"kFeaturedConversationCellViewIdentifier";
NSString *const kEmptyConversationCellViewIdentifier = @"kEmptyConversationCellViewIdentifier";

NSString *const kCollectionType_global = @"GLOBAL";
NSString *const kCollectionType_nearby = @"NEARBY";

@interface FeaturedConversationCollectionViewController()<UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSArray          *conversationSummaries;
@property (strong, nonatomic) NSIndexPath      *selectedIndexPath;
@property (strong, nonatomic) UIView           *gradientView;
@property (nonatomic) NSInteger                 cellWidth;
@property (strong, nonatomic) LocationUtil     *locationUtil;

@end

@implementation FeaturedConversationCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.collectionView];
    self.navigationController.navigationBar.barTintColor = [UIColor rivetDarkBlue];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont rivetNavigationBarHeaderFont]};
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.title = @"";
    self.navigationController.navigationBar.translucent = NO;
    if ([AppState justOpenedApp]) {
        [self updateLocation];
    } else if ([AppState timeSinceLastListViewRefresh] > 60 * 10) {
        [self loadFreshConversations:^{} refreshAll:YES];
    }
    [self setupConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self addObservers];
    [self.collectionView reloadData];
    [self loadCachedConversations];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeObservers];
    [AppState setJustOpenedApp:NO];
    [BaseRepository cancelRequestsWithTag:kFeaturedConversationControllerTag];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    UIEdgeInsets insets = self.collectionView.contentInset;
    CGFloat value = (self.view.frame.size.width - ((UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout).itemSize.width) * 0.5;
    insets.left = value;
    insets.right = value;
    self.collectionView.contentInset = insets;
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    CGRect frame = self.view.bounds;
    frame.size.width += 1000;
    frame.origin.x -= 500;
    gradient.frame = frame;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor rivetDarkBlue] CGColor], (id)[[UIColor rivetLightBlue] CGColor], nil];
    [self.gradientView.layer insertSublayer:gradient atIndex:0];
}

- (void)setupConstraints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.collectionView
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.collectionView
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.collectionView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.collectionView
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:0]];
}

#pragma mark - Getters

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[FeaturedConversationFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, [ConstUtil screenWidth], self.view.frame.size.height)
                                             collectionViewLayout:flowLayout];
        _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:[FeaturedConversationCollectionViewCell class] forCellWithReuseIdentifier:kFeaturedConversationCellViewIdentifier];
        [_collectionView registerClass:[EmptyFeaturedConversationCollectionViewCell class] forCellWithReuseIdentifier:kEmptyConversationCellViewIdentifier];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.backgroundView = self.gradientView;
    }
    return _collectionView;
}

- (UIView *)gradientView {
    if (!_gradientView) {
        _gradientView = [[UIView alloc] init];
        _gradientView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _gradientView;
}

- (NSInteger)cellWidth {
    if (_cellWidth == 0) {
        _cellWidth = MIN([ConstUtil screenWidth] - 60, 320);
    }
    return _cellWidth;
}

- (LocationUtil *)locationUtil {
    if (!_locationUtil) {
        _locationUtil = [[LocationUtil alloc] init];
    }
    return _locationUtil;
}

#pragma mark - Update Location

- (void)updateLocation {
    __weak FeaturedConversationCollectionViewController *weakSelf = self;
    [UserRepository sendCurrentLocationWithLocationUtil:self.locationUtil
                                     withSuccessHandler:^{
                                         [weakSelf loadFreshConversations:^{} refreshAll:YES];
                                     }
                                     withFailureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         [weakSelf loadFreshConversations:^{} refreshAll:YES];
                                     }];
}

#pragma mark - Observers

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(featuredConversationSelected:)
                                                 name:kNotification_featuredConversationSelected
                                               object:nil];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotification_featuredConversationSelected
                                                  object:nil];
}

#pragma mark - Refresh Conversation Data

- (void)loadFreshConversations:(void (^)(void))handler refreshAll:(BOOL)refreshAll {
    __weak FeaturedConversationCollectionViewController *weakSelf = self;
    BOOL globalType = [self.collectionType isEqualToString:kCollectionType_global];
    BOOL nearbyType = [self.collectionType isEqualToString:kCollectionType_nearby];
    if (globalType || refreshAll) {
        [ConversationRepository globalFeaturedConversationsWithSuccessHandler:^(NSArray *conversations) {
            if (globalType) {
                [weakSelf conversationsLoaded:conversations];
                handler();
            }
        }
                                                      withFailureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                          if (globalType) {
                                                              handler();
                                                          }
                                                      }
                                                                 withTag:kFeaturedConversationControllerTag];
    }
    if (nearbyType || refreshAll) {
        [ConversationRepository nearbyFeaturedConversationsWithSuccessHandler:^(NSArray *conversations) {
            if (nearbyType) {
                [weakSelf conversationsLoaded:conversations];
                handler();
            }
        }
                                                      withFailureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                          if (nearbyType) {
                                                              handler();
                                                          }
                                                      }
                                                                 withTag:kFeaturedConversationControllerTag];
    }
    if (refreshAll) {
        [AppState setTimestampOfLastListViewRefresh:[NSDate date]];
    }
}

- (void)loadCachedConversations {
    if ([self.collectionType isEqualToString:kCollectionType_global]) {
        [self conversationsLoaded:[ConversationCache globalFeaturedConversationCache]];
    } else {
        [self conversationsLoaded:[ConversationCache nearbyFeaturedConversationCache]];
    }
}

- (void)conversationsLoaded:(NSArray *)conversations {
    self.conversationSummaries = [SortUtil sort:conversations
                                 byAttribute:@"endTime"
                                              ascending:NO];
    ((UICollectionViewFlowLayout *) self.collectionView.collectionViewLayout).itemSize = CGSizeMake(self.cellWidth, self.view.frame.size.height);
    [self.collectionView reloadData];
}

#pragma mark - Collection View Delegate

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.conversationSummaries.count == 0) {
        EmptyFeaturedConversationCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kEmptyConversationCellViewIdentifier forIndexPath:indexPath];
        cell.collectionType = self.collectionType;
        return cell;
    } else {
        FeaturedConversationCollectionViewCell *cell = (FeaturedConversationCollectionViewCell *) [collectionView dequeueReusableCellWithReuseIdentifier:kFeaturedConversationCellViewIdentifier forIndexPath:indexPath];
        cell.conversation = [self.conversationSummaries objectAtIndex:indexPath.row];
        return cell;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.conversationSummaries.count == 0) {
        return 1;
    }
    return self.conversationSummaries.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.cellWidth, self.view.frame.size.height);
}

- (void)featuredConversationSelected:(NSNotification *)notification {
    BarOnBottomNavigationDelegate *delegate = (BarOnBottomNavigationDelegate *) self.navigationController.delegate;
    ConversationSummary *selected = [notification.userInfo objectForKey:@"conversation"];
    FeaturedConversationCollectionViewCell *cell = notification.object;
    delegate.picture = selected.picture;
    delegate.headline = selected.headline;
    delegate.desc = selected.desc;
    delegate.cardViewFrame = [cell cardViewFrame];
    delegate.cardPictureFrame = [cell pictureFrame];
    delegate.cardHeadlineFrame = [cell headlineFrame];
    delegate.cardDescriptionFrame = [cell descriptionFrame];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_segueToFeaturedConversationViewing
                                                        object:nil
                                                      userInfo:@{@"conversation":selected}];
    [EventTrackingUtil selectedFeaturedConversationFromListView:selected.conversationId];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    scrollView.tag = (NSInteger) scrollView.contentOffset.x;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    __weak FeaturedConversationCollectionViewController *weakSelf = self;
    if (fabs(velocity.x) > 0 && fabs(scrollView.tag - targetContentOffset->x) < (self.cellWidth / 2.0)) {
        [self.collectionView setContentOffset:self.collectionView.contentOffset animated:NO];
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [weakSelf.collectionView setContentOffset:*targetContentOffset];
                         }
                         completion:NULL];
    }
}

@end