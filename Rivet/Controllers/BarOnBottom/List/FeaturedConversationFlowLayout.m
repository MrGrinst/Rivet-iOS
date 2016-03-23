#import "FeaturedConversationFlowLayout.h"
#import "ConstUtil.h"

@implementation FeaturedConversationFlowLayout

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    UICollectionView *cv = self.collectionView;
    CGRect cvBounds = cv.bounds;
    CGFloat halfWidth = cvBounds.size.width * 0.5;
    CGFloat proposedContentOffsetCenterX = proposedContentOffset.x + halfWidth;
    
    NSArray *attributesForVisibleCells = [self layoutAttributesForElementsInRect:cvBounds];
    UICollectionViewLayoutAttributes *candidateAttributes = [[UICollectionViewLayoutAttributes alloc] init];
    
    for (UICollectionViewLayoutAttributes *attributes in attributesForVisibleCells) {
        if (attributes.representedElementCategory != UICollectionElementCategoryCell) {
            continue;
        }
        
        if (candidateAttributes) {
            CGFloat a = attributes.center.x - proposedContentOffsetCenterX;
            CGFloat b = candidateAttributes.center.x - proposedContentOffsetCenterX;
            
            if (fabs(a) < fabs(b)) {
                candidateAttributes = attributes;
            }
        } else {
            candidateAttributes = attributes;
            continue;
        }
    }
    
    return CGPointMake(round(candidateAttributes.center.x - halfWidth), proposedContentOffset.y);
}

@end