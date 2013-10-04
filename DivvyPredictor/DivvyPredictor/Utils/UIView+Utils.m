//
//  UIView+Utils.m
//  Discover-iPhone
//
//  Created by Jeremy Conkin on 1/10/13.
//  Copyright (c) 2013 Discover Financial. All rights reserved.
//

#import "UIView+Utils.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (Utils)

//Shortcut to get the Y coordinate of the frame
- (CGFloat)y {
    return CGRectGetMinY(self.frame);
}

//Shortcut to get the X coordinate of the frame
- (CGFloat)x {
    return CGRectGetMinX(self.frame);
}

//Maximum coordinate Y of the frame
- (CGFloat)maxY {
    return CGRectGetMaxY(self.frame);
}

//Maximum coordinate X of the frame
- (CGFloat)maxX {
    return CGRectGetMaxX(self.frame);
}

//Shortcut to get the height of the frame
- (CGFloat)height {
    return CGRectGetHeight(self.frame);
}

//Shortcut to get the width of the frame
- (CGFloat)width {
    return CGRectGetWidth(self.frame);
}

- (void)setX:(CGFloat)x {
    [self setOriginX:x];
}

- (void)setY:(CGFloat)y {
    [self setOriginY:y];
}

// Give this view a new origin
-(void)setOrigin:(CGPoint)newOrigin
{
    CGRect newFrame = self.frame;
    newFrame.origin = newOrigin;
    self.frame = newFrame;
}

// Change the x position of this view
-(void)setOriginX:(float)newX
{
    CGRect newFrame = self.frame;
    newFrame.origin.x = newX;
    self.frame = newFrame;
}

// Change the y position of this view
-(void)setOriginY:(float)newY
{
    CGRect newFrame = self.frame;
    newFrame.origin.y = newY;
    self.frame = newFrame;
}

// Give this view new dimensions
-(void)setSize:(CGSize)newSize
{
    CGRect newFrame = self.frame;
    newFrame.size = newSize;
    self.frame = newFrame;
}

// Make this view fatter/thinner
-(void)setWidth:(CGFloat)newWidth
{
    CGRect newFrame = self.frame;
    newFrame.size.width = newWidth;
    self.frame = newFrame;
}

// Make this view taller/shorter
-(void)setHeight:(CGFloat)newHeight
{
    CGRect newFrame = self.frame;
    newFrame.size.height = newHeight;
    self.frame = newFrame;
}

- (void)removeAllSubviews
{
    for (UIView *view in self.subviews)
    {
        [view removeFromSuperview];
    }
}

- (void)roundCornersWithRadius:(CGFloat)radius {
    CALayer *layer = [self layer];
    [layer setCornerRadius:radius];
    layer.masksToBounds = YES;
}

- (void)addBorderWithColor:(UIColor *)color andWidth:(CGFloat)width {
    [self.layer setBorderColor:[color CGColor]];
    [self.layer setBorderWidth:width];
}

-(CGFloat)subviewContainingHeight
{
    CGFloat height = 0;
    
    for (UIView *view in [self subviews]) {
        height = MAX(view.frame.origin.y + view.frame.size.height, height);
    }

    return  height;
}

@end
