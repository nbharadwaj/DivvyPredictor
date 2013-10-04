//
//  BaseMapPopoverView.m
//  Discover-iPhone
//
//  Created by Ryan Sander on 4/23/13.
//  Copyright (c) 2013 Discover Financial. All rights reserved.
//

#import "BaseMapPopoverView.h"
#import "UIView+Utils.h"
//#import "Colors.h"
#import "BaseMapPopoverViewConstants.h"

@interface BaseMapPopoverView()

@property (nonatomic,strong) UIView *specifiedContentView;

@property (nonatomic,weak) IBOutlet UIView *contentView;
@property (nonatomic,weak) IBOutlet UIView *backgroundView;
@property (nonatomic,weak) IBOutlet UIView *greyBorderView;
@property (nonatomic,weak) IBOutlet UIView *arrowView;

@end

@implementation BaseMapPopoverView

- (id)initWithContentView:(UIView *)contentView
{
    //This gets set later based off content view
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.specifiedContentView = contentView;
        [self setNibView];
    }
    return self;
}

- (void)setNibView {
    UIView *nibView = [[[NSBundle mainBundle] loadNibNamed:kBaseMapPopoverViewNibName owner:self options:nil] objectAtIndex:0];
    
    [self setFrame:
     CGRectMake(CGFLOAT_ZERO,
                CGFLOAT_ZERO,
                self.specifiedContentView.frame.size.width+(BORDER_WIDTH*2),
                self.specifiedContentView.frame.size.height+(BORDER_WIDTH*2)+(self.arrowView.frame.size.height/2))];
    
//    self.contentView = self.specifiedContentView;
    [self.backgroundView addSubview:self.specifiedContentView];
    [self adjustContentViewToCompensateForBorder];
    [self setBackgroundViewProperties];
    
//    [self.contentView roundCornersWithRadius:BORDER_RADIUS];
    [self.backgroundView roundCornersWithRadius:BORDER_RADIUS];
    self.backgroundView.clipsToBounds = YES;
    [self.arrowView addBorderWithColor:[UIColor colorWithRed:138.0f/255.0f green:148.0f/255.0f blue:153.0f/255.0f alpha:1.0f] andWidth:BORDER_WIDTH];
    [self adjustArrowPositionForSizeOfContentView];
    [self rotateArrowView];
    
    [self setGreyBorderViewProperties];
    
    [self addSubview:nibView];
}

- (void)adjustContentViewToCompensateForBorder {
    [self.contentView setFrame:CGRectMake(BORDER_WIDTH, BORDER_WIDTH, self.specifiedContentView.frame.size.width, self.specifiedContentView.frame.size.height)];
}

- (void)setBackgroundViewProperties {
    [self adjustBackgroundHeightForSizeOfContentView];
    [self.backgroundView roundCornersWithRadius:CONTENT_RADIUS];
}

- (void)adjustBackgroundHeightForSizeOfContentView {
    [self.backgroundView setFrame:CGRectMake(BORDER_WIDTH, BORDER_WIDTH, self.specifiedContentView.frame.size.width, self.specifiedContentView.frame.size.height)];
}

- (void)setGreyBorderViewProperties {
    [self.greyBorderView setFrame:
     CGRectMake(CGFLOAT_ZERO,
                CGFLOAT_ZERO,
                self.specifiedContentView.frame.size.width+(BORDER_WIDTH*2),
                self.specifiedContentView.frame.size.height+(BORDER_WIDTH*2))];
    [self.greyBorderView setBackgroundColor:[UIColor colorWithRed:138.0f/255.0f green:148.0f/255.0f blue:153.0f/255.0f alpha:1.0f]];
    [self.greyBorderView roundCornersWithRadius:BORDER_RADIUS];
}

- (void)adjustArrowPositionForSizeOfContentView {
    [self.arrowView setFrame:
     CGRectMake((self.specifiedContentView.frame.size.width/2)-(self.arrowView.frame.size.height/2),
                self.specifiedContentView.frame.size.height-(self.arrowView.frame.size.height/2)-ARROW_OFFSET,
                self.arrowView.frame.size.width,
                self.arrowView.frame.size.height)];
}

- (void)rotateArrowView {
    self.arrowView.transform = CGAffineTransformMakeRotation(M_PI/4);
}

#pragma mark - Failsafes

- (id)initWithFrame:(CGRect)frame {
    [NSException raise:@"Unsupported Method Exception" format:@"%@ Cannot be instantiated. Use initWithContentView:",[self class]];
    return nil;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    [NSException raise:@"Unsupported Method Exception" format:@"%@ Cannot be instantiated. Use initWithContentView:",[self class]];
    return nil;
}

- (id)init {
    [NSException raise:@"Unsupported Method Exception" format:@"%@ Cannot be instantiated. Use initWithContentView:",[self class]];
    return nil;
}

@end
