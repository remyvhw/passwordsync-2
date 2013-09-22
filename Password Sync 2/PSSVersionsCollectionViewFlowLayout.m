//
//  PSSVersionsCollectionViewFlowLayout.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-07.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSVersionsCollectionViewFlowLayout.h"
#import "PSSDeviceCapacity.h"

@interface PSSVersionsCollectionViewFlowLayout ()


@end

@implementation PSSVersionsCollectionViewFlowLayout


- (void)prepareLayout
{
    
    [super prepareLayout];
    
    // Create animator
    if (!_dynamicAnimator) {
        _dynamicAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
        
        CGSize contentSize = [self collectionViewContentSize];
        NSArray * items = [super layoutAttributesForElementsInRect:CGRectMake(0, 0, contentSize.width, contentSize.height)];
        
        // Iterate through items returned by super flow layout
        for (UICollectionViewLayoutAttributes * item in items) {
            
            UIAttachmentBehavior * spring = [[UIAttachmentBehavior alloc] initWithItem:item attachedToAnchor:item.center];
            
            // Fuddle with these as much as you need
            /*if (PSSShouldRunAdvancedFeatures()) {
                
                
                // Has to be 0 so it stays to rest at the anchor point and not in an arbritary place
                spring.length = 0;
                spring.damping = 0.9;
                spring.frequency = 0.9;
                
            }*/
            [self.dynamicAnimator addBehavior:spring];
            
            
            
        }
    }
}

-(void)prepareForCollectionViewUpdates:(NSArray *)updateItems{
}


-(NSArray*)layoutAttributesForElementsInRect:(CGRect)rect{
    return [self.dynamicAnimator itemsInRect:rect];
}

-(UICollectionViewLayoutAttributes*)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    return [self.dynamicAnimator layoutAttributesForCellAtIndexPath:indexPath];
}

-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
    
    if (self.preventBounce) {
        return [super shouldInvalidateLayoutForBoundsChange:newBounds];
    }
    
    CGFloat scrollDelta = newBounds.origin.y - self.collectionView.bounds.origin.y;
    CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
    
    
    
    // Strech the springs by the amount we just scrolled
    for (UIAttachmentBehavior * spring in _dynamicAnimator.behaviors) {
        
        CGPoint anchorPoint = spring.anchorPoint;
        CGFloat distanceFromTouch = fabsf(touchLocation.y - anchorPoint.y);
        
        // Play around with this value; the more resistance the bouncier the views.
        CGFloat scrollResistance = distanceFromTouch/700;
        
        // Grab the item
        UICollectionViewLayoutAttributes * item = [spring.items firstObject];
        
        CGPoint center = item.center;
        center.y += MIN(scrollDelta, scrollDelta * scrollResistance); // So when we're under the finger, we don't really have resistance
        item.center = center;
        
        [self.dynamicAnimator updateItemUsingCurrentState:item];
    }
    
    
    return NO;
}

@end
