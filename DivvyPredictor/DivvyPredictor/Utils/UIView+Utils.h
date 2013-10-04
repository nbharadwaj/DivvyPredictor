//
//  UIView+Utils.h
//  Discover-iPhone
//
//  Created by Jeremy Conkin on 1/10/13.
//  Copyright (c) 2013 Discover Financial. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Utils)

//Getter helper methods
- (CGFloat)y;
- (CGFloat)x;
- (CGFloat)height;
- (CGFloat)width;

//Getter for the max coordinates of the frame
- (CGFloat)maxY;
- (CGFloat)maxX;

// Position setting methods
-(void)setOrigin:(CGPoint)newOrigin;
//TODO: consolidate
-(void)setX:(float)newX;
-(void)setY:(float)newY;
-(void)setOriginX:(float)newX;
-(void)setOriginY:(float)newY;

// Size setting methods
-(void)setSize:(CGSize)newSize;
-(void)setWidth:(CGFloat)newWidth;
-(void)setHeight:(CGFloat)newHeight;

-(CGFloat)subviewContainingHeight;

//Remove subviews
- (void)removeAllSubviews;

- (void)roundCornersWithRadius:(CGFloat)radius;
- (void)addBorderWithColor:(UIColor *)color andWidth:(CGFloat)width;

@end
