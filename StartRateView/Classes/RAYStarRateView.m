
//
//  DRStarRateView.m
//  XHStarRateView
//
//  Created by Cyfuer on 2019/10/8.
//  Copyright © 2019 duorong. All rights reserved.
//

#import "RAYStarRateView.h"


static NSString *const KForegroundStarImage = @"icon_star_yellow@2x.png";
static NSString *const KBackgroundStarImage = @"icon_star_gray@2x.png";

@interface RAYStarRateView()

@property (nonatomic, strong, readwrite) UIView *foregroundStarView;
@property (nonatomic, strong, readwrite) UIView *backgroundStarView;
@property (nonatomic, assign) BOOL isAnimation;                 // 是否动画显示，默认 NO
@end

@implementation RAYStarRateView

#pragma mark - Init Method

// nib
- (void)awakeFromNib {
    [super awakeFromNib];
    [self createStarView];
    NSLog(@"%s",__func__);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _numberOfStar       = 5;
        _rateStyle          = DRStarRateViewRateStyeHalfStar;
        _isAnimation        = YES;
        _editable           = YES;
    }
    return self;
}

// code
- (instancetype)initWithFrame:(CGRect)frame numberOfStar:(NSInteger)numberOfStar rateStyle:(DRStarRateViewRateStye)rateStyle isAnimation:(BOOL)isAnimation completion:(DRStarRateViewRateCompletionBlock)completionBlock
{
     if (self = [super initWithFrame:frame]) {
          _numberOfStar    = numberOfStar;
          _rateStyle       = rateStyle;
          _isAnimation     = isAnimation;
          _completionBlock = completionBlock;
         _editable = YES;
         
        [self createStarView];
    }
         return self;
}

- (void)dealloc {
    self.completionBlock = nil;
}

#pragma mark - Override

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat animationDuration = (self.isAnimation ? 0.2 : 0);
    [UIView animateWithDuration:animationDuration animations:^{
        self.foregroundStarView.frame = CGRectMake(0, 0, self.bounds.size.width / self.numberOfStar * self.currentRating, self.bounds.size.height);
    }];
}

#pragma mark - Custom Accessors

- (void)setCurrentRating:(CGFloat)currentRating {
    if (_currentRating == currentRating) {
        return;
    }
    if (currentRating < 0) {
        _currentRating = 0;
    } else if (currentRating > _numberOfStar) {
        _currentRating = _numberOfStar;
    } else {
        _currentRating = currentRating;
    }
    
    if (self.completionBlock) {
        _completionBlock(_currentRating);
    }
    [self setNeedsLayout];
}

#pragma mark - Private Method

- (void)createStarView {
    NSLog(@"%s",__func__);
    if (self.foregroundStarView.superview) {
        [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        self.foregroundStarView = nil;
        self.backgroundStarView = nil;
    }
    
    self.foregroundStarView = [self createStarViewWithImage:self.highlightImage ?: [self bundleImageForName:KForegroundStarImage]];
    self.backgroundStarView = [self createStarViewWithImage:self.normalImage ?: [self bundleImageForName:KBackgroundStarImage]];
    
    NSAssert(_numberOfStar != 0, @"The Value Of Rate Star should not be Zero");
    self.foregroundStarView.frame = CGRectMake(0, 0, self.bounds.size.width * _currentRating / _numberOfStar, self.bounds.size.height);
    [self addSubview:self.backgroundStarView];
    [self addSubview:self.foregroundStarView];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTapRateView:)];
    tapGesture.numberOfTapsRequired = 1;
    [self addGestureRecognizer:tapGesture];
}


- (UIImage *)bundleImageForName:(NSString *)imageName {
    NSBundle *currentBundle = [NSBundle bundleForClass:self.class];
    NSString *path = [currentBundle pathForResource:imageName ofType:nil inDirectory:@"StartRateView.bundle"];  // 目录名称
    return [UIImage imageWithContentsOfFile:path];
}

- (UIView *)createStarViewWithImage:(UIImage *)image {
    UIView *view = [[UIView alloc] initWithFrame:self.bounds];
    view.clipsToBounds = YES;
    view.backgroundColor = [UIColor clearColor];
    
    NSAssert(_numberOfStar != 0, @"The Value Of Rate Star should not be Zero");

    @autoreleasepool {
        for (NSInteger i = 0; i < _numberOfStar; i ++) {
            @autoreleasepool {
                UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
                float starWidth = self.bounds.size.width / _numberOfStar;
                float starHeigh = self.bounds.size.height;
                imageView.frame = CGRectMake(i * starWidth, 0, starWidth, starHeigh);
                imageView.contentMode = UIViewContentModeScaleAspectFit;
                [view addSubview:imageView];
            }
        }
    }
    
    return view;
}

- (void)userTapRateView:(UITapGestureRecognizer *)gesture {
    if (!self.editable) return; // 不允许更改的话
    
    CGPoint tapPoint = [gesture locationInView:self];
    CGFloat offset = tapPoint.x;
    CGFloat realRating = offset / (self.bounds.size.width / _numberOfStar);

    switch (_rateStyle) {
        case DRStarRateViewRateStyeFullStar: {
            self.currentRating = ceilf(realRating);
            break;
        }
        case DRStarRateViewRateStyeHalfStar: {
            float round = roundf(realRating);
            if (round == 0 && realRating < 0.2f && self.zeroRateEnable) {
                self.currentRating = 0.0;
            } else {
                self.currentRating = (round > realRating) ? round : (round + 0.5);
            }
            break;
        }
        case DRStarRateViewRateStyeIncompleteStar: {
            self.currentRating = realRating;
            break;
        }
    }
}


@end
