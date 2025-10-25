#import <UIKit/UIKit.h>
#import "FPSDisplay.h"
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
@interface FPSDisplay ()
@property (strong, nonatomic) UILabel *displayLabel;
@property (strong, nonatomic) CADisplayLink *link;
@property (assign, nonatomic) NSInteger count;
@property (assign, nonatomic) NSTimeInterval lastTime;
@property (strong, nonatomic) UIFont *font;
@property (strong, nonatomic) UIFont *subFont;
@end
@implementation FPSDisplay
+(void)load
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [self shareFPSDisplay];
    });
}
+ (instancetype)shareFPSDisplay {
    static FPSDisplay *shareDisplay;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareDisplay = [[FPSDisplay alloc] init];
    });
    return shareDisplay;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initDisplayLabel];
    }
    return self;
}

- (void)initDisplayLabel {
    // HUD góc phải trên
    CGRect frame = CGRectMake(SCREEN_WIDTH - 110, 28, 105, 26);
    self.displayLabel = [[UILabel alloc] initWithFrame:frame];
    self.displayLabel.layer.cornerRadius = 8;
    self.displayLabel.clipsToBounds = YES;
    self.displayLabel.textAlignment = NSTextAlignmentCenter;
    self.displayLabel.userInteractionEnabled = NO;

    // Nền mờ trong suốt
    self.displayLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.25];
    self.displayLabel.textColor = [UIColor whiteColor];
    self.displayLabel.font = [UIFont monospacedDigitSystemFontOfSize:12 weight:UIFontWeightBold];

    // Viền trong suốt ban đầu (sẽ được fill bằng gradient)
    self.displayLabel.layer.borderWidth = 0;

    // Ánh sáng glow chữ
    self.displayLabel.layer.shadowRadius = 10.0;
    self.displayLabel.layer.shadowOpacity = 1.0;
    self.displayLabel.layer.shadowOffset = CGSizeZero;
    self.displayLabel.layer.masksToBounds = NO;

    // ✅ Tạo gradient layer cho viền ngoài
    CAGradientLayer *gradientBorder = [CAGradientLayer layer];
    gradientBorder.frame = self.displayLabel.bounds;
    gradientBorder.colors = @[
        (__bridge id)[UIColor redColor].CGColor,
        (__bridge id)[UIColor orangeColor].CGColor,
        (__bridge id)[UIColor yellowColor].CGColor,
        (__bridge id)[UIColor greenColor].CGColor,
        (__bridge id)[UIColor cyanColor].CGColor,
        (__bridge id)[UIColor blueColor].CGColor,
        (__bridge id)[UIColor purpleColor].CGColor
    ];
    gradientBorder.startPoint = CGPointMake(0, 0);
    gradientBorder.endPoint = CGPointMake(1, 1);
    gradientBorder.cornerRadius = self.displayLabel.layer.cornerRadius;
    gradientBorder.name = @"gradientBorder";

    // Mask gradient theo viền chữ
    CAShapeLayer *shape = [CAShapeLayer layer];
    shape.lineWidth = 2.0;
    shape.path = [UIBezierPath bezierPathWithRoundedRect:self.displayLabel.bounds cornerRadius:self.displayLabel.layer.cornerRadius].CGPath;
    shape.fillColor = [UIColor clearColor].CGColor;
    shape.strokeColor = [UIColor blackColor].CGColor;
    gradientBorder.mask = shape;

    [self.displayLabel.layer addSublayer:gradientBorder];

    // Thêm layer glow phụ để tạo ánh sáng lan ngoài
    CALayer *glowLayer = [CALayer layer];
    glowLayer.frame = self.displayLabel.bounds;
    glowLayer.backgroundColor = [UIColor clearColor].CGColor;
    glowLayer.shadowColor = [UIColor colorWithRed:0.2 green:1.0 blue:0.3 alpha:1.0].CGColor;
    glowLayer.shadowRadius = 18.0;
    glowLayer.shadowOpacity = 0.8;
    glowLayer.shadowOffset = CGSizeZero;
    glowLayer.name = @"glowLayer";
    [self.displayLabel.layer insertSublayer:glowLayer below:self.displayLabel.layer];

    [self initCADisplayLink];
    [[UIApplication sharedApplication].keyWindow addSubview:self.displayLabel];
}
- (void)updateDisplayLabelText:(float)fps {
    // Hiệu ứng rainbow mượt (đổi màu liên tục)
    static CGFloat hue = 0;
    hue += 0.005;
    if (hue > 1.0) hue = 0;
    UIColor *color = [UIColor colorWithHue:hue saturation:1.0 brightness:1.0 alpha:1.0];

    // Hiển thị chữ
    self.displayLabel.text = [NSString stringWithFormat:@"Khổng Mạnh Yên | %.0f FPS", fps];
    self.displayLabel.textColor = color;
    self.displayLabel.layer.shadowColor = color.CGColor;

    // Cập nhật glow layer màu theo chữ
    CALayer *glowLayer = nil;
    for (CALayer *layer in self.displayLabel.layer.sublayers) {
        if ([layer.name isEqualToString:@"glowLayer"]) {
            glowLayer = layer;
            break;
        }
    }
    if (glowLayer) {
        glowLayer.shadowColor = color.CGColor;
    }

    // Gradient border quay vòng liên tục
    CAGradientLayer *gradientBorder = nil;
    for (CALayer *layer in self.displayLabel.layer.sublayers) {
        if ([layer.name isEqualToString:@"gradientBorder"]) {
            gradientBorder = (CAGradientLayer *)layer;
            break;
        }
    }
    if (gradientBorder) {
        gradientBorder.colors = @[
            (__bridge id)[UIColor colorWithHue:hue saturation:1.0 brightness:1.0 alpha:1.0].CGColor,
            (__bridge id)[UIColor colorWithHue:hue + 0.2 saturation:1.0 brightness:1.0 alpha:1.0].CGColor,
            (__bridge id)[UIColor colorWithHue:hue + 0.4 saturation:1.0 brightness:1.0 alpha:1.0].CGColor,
            (__bridge id)[UIColor colorWithHue:hue + 0.6 saturation:1.0 brightness:1.0 alpha:1.0].CGColor,
            (__bridge id)[UIColor colorWithHue:hue + 0.8 saturation:1.0 brightness:1.0 alpha:1.0].CGColor
        ];
    }

    // Hiệu ứng nhấp sáng
    [UIView animateWithDuration:0.12 animations:^{
        self.displayLabel.layer.shadowRadius = 18.0;
        self.displayLabel.transform = CGAffineTransformMakeScale(1.06, 1.06);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.25 animations:^{
            self.displayLabel.layer.shadowRadius = 12.0;
            self.displayLabel.transform = CGAffineTransformIdentity;
        }];
    }];
}
@end

 