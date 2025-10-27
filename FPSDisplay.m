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

CGRect frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 4 - 4, [UIScreen mainScreen].bounds.size.height - 12, [UIScreen mainScreen].bounds.size.width / 2  + 10, 16);
    self.displayLabel = [[UILabel alloc] initWithFrame: frame];
    self.displayLabel.layer.cornerRadius = 12;
    self.displayLabel.clipsToBounds = YES;
    self.displayLabel.textAlignment = NSTextAlignmentLeft;
        self.displayLabel.textAlignment = NSTextAlignmentCenter;
    self.displayLabel.userInteractionEnabled = NO;

//  self.displayLabel.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.200]; //background

    _font = [UIFont fontWithName:@"Menlo" size:14];
    if (_font) {
        _subFont = [UIFont fontWithName:@"Menlo" size:4];
    } else {
        _font = [UIFont fontWithName:@"Courier" size:14];
        _subFont = [UIFont fontWithName:@"Courier" size:4];
    }

    [self initCADisplayLink];

    [[UIApplication sharedApplication].keyWindow addSubview:self.displayLabel];
}

- (void)initCADisplayLink {
    self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
    [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)tick:(CADisplayLink *)link
{
    if(self.lastTime == 0){
        self.lastTime = link.timestamp;
        return;
    }
    self.count += 1;
    NSTimeInterval delta = link.timestamp - _lastTime;
    if(delta >= 1.f){
        self.lastTime = link.timestamp;
        float fps = self.count / delta;
        self.count = 0;
        [self updateDisplayLabelText: fps];
    }
}

- (void)updateDisplayLabelText:(float)fps
{
    // Cập nhật chữ
    self.displayLabel.text = @"Khổng Mạnh Yên";

    // Hiệu ứng đổi màu cầu vồng
    static CGFloat hue = 0;
    hue += 0.03; // tốc độ đổi màu (có thể tăng lên nếu muốn nhanh hơn)
    if (hue > 1.0) hue -= 1.0;
    UIColor *rainbowColor = [UIColor colorWithHue:hue saturation:1.0 brightness:1.0 alpha:1.0];
    self.displayLabel.textColor = rainbowColor;

    // Font chữ to, đậm, bo tròn nhẹ
    self.displayLabel.font = [UIFont fontWithName:@"AvenirNext-Bold" size:18];
    self.displayLabel.layer.cornerRadius = 8;
    self.displayLabel.clipsToBounds = YES;
    self.displayLabel.textAlignment = NSTextAlignmentCenter;

    // Hiệu ứng glow (phát sáng xung quanh)
    self.displayLabel.layer.shadowColor = rainbowColor.CGColor;
    self.displayLabel.layer.shadowRadius = 6.0;
    self.displayLabel.layer.shadowOpacity = 0.9;
    self.displayLabel.layer.shadowOffset = CGSizeZero;

    // Thêm nền mờ nhẹ phía sau cho nổi bật
    self.displayLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.25];
}
@end

