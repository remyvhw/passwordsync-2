//
//  TSMessageView.m
//  Toursprung
//
//  Created by Felix Krause on 24.08.12.
//  Copyright (c) 2012 Toursprung. All rights reserved.
//

#import "TSMessageView.h"
#import "HexColor.h"

#define TSMessageViewPadding 15.0

#define TSDesignFileName @"design.json"

static NSMutableDictionary *_notificationDesign;

@interface TSMessageView ()

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *buttonTitle;
@property (nonatomic, strong) UIViewController *viewController;

/** Internal properties needed to resize the view on device rotation properly */
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIView *borderView;
@property (nonatomic, strong) UIImageView *backgroundImageView;

@property (nonatomic, assign) CGFloat textSpaceLeft;
@property (nonatomic, assign) CGFloat textSpaceRight;

@property (copy) void (^callback)();
@property (copy) void (^buttonCallback)();

- (CGFloat)updateHeightOfMessageView;
- (void)layoutSubviews;

@end


@implementation TSMessageView

+ (NSMutableDictionary*)notificationDesign
{
    return nil;
}

+ (void)addNotificationDesignFromFile:(NSString*)filename
{
    return;
}

- (id)initWithTitle:(NSString *)title
        withContent:(NSString *)content
           withType:(TSMessageNotificationType)notificationType
       withDuration:(CGFloat)duration
   inViewController:(UIViewController *)viewController
       withCallback:(void (^)())callback
    withButtonTitle:(NSString *)buttonTitle
 withButtonCallback:(void (^)())buttonCallback
         atPosition:(TSMessageNotificationPosition)position
  shouldBeDismissed:(BOOL)dismissAble
{
    
    if ((self = [self init]))
    {
        _title = title;
        _content = content;
        _buttonTitle = buttonTitle;
        _duration = duration;
        _viewController = viewController;
        _messagePosition = position;
        self.callback = callback;
        self.buttonCallback = buttonCallback;
        
        CGFloat screenWidth = self.viewController.view.bounds.size.width;
        NSDictionary *current;
        NSString *currentString;
        switch (notificationType)
        {
            case TSMessageNotificationTypeMessage:
            {
                currentString = @"message";
                break;
            }
            case TSMessageNotificationTypeError:
            {
                currentString = @"error";
                break;
            }
            case TSMessageNotificationTypeSuccess:
            {
                currentString = @"success";
                break;
            }
            case TSMessageNotificationTypeWarning:
            {
                currentString = @"warning";
                break;
            }
                
            default:
                break;
        }
        
        
        self.alpha = 0.0;
        
        UIImage *image;
        if ([current valueForKey:@"imageName"])
        {
            image = [UIImage imageNamed:[current valueForKey:@"imageName"]];
        }
        
        
        self.backgroundColor = [UIColor whiteColor];
        
        UIColor *fontColor = [UIColor colorWithWhite:0.1 alpha:1.0];
        
        
        self.textSpaceLeft = 2 * TSMessageViewPadding;
        if (image) self.textSpaceLeft += image.size.width + 2 * TSMessageViewPadding;
        
        // Set up title label
        _titleLabel = [[UILabel alloc] init];
        [self.titleLabel setText:title];
        [self.titleLabel setTextColor:fontColor];
        [self.titleLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]];
        [self.titleLabel setBackgroundColor:[UIColor clearColor]];
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:self.titleLabel];
        
        // Set up content label (if set)
        if ([content length])
        {
            _contentLabel = [[UILabel alloc] init];
            [self.contentLabel setText:content];
            
           
            [self.contentLabel setTextColor:fontColor];
            [self.contentLabel setBackgroundColor:[UIColor clearColor]];
            [self.contentLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
            self.contentLabel.lineBreakMode = self.titleLabel.lineBreakMode;
            self.contentLabel.numberOfLines = 0;
            
            [self addSubview:self.contentLabel];
        }
        
        if (image)
        {
            _iconImageView = [[UIImageView alloc] initWithImage:image];
            self.iconImageView.frame = CGRectMake(TSMessageViewPadding * 2,
                                                  TSMessageViewPadding,
                                                  image.size.width,
                                                  image.size.height);
            [self addSubview:self.iconImageView];
        }
        
        // Set up button (if set)
        if ([buttonTitle length])
        {
            _button = [UIButton buttonWithType:UIButtonTypeCustom];
            
            
            [self.button setBackgroundColor:[UIColor colorWithRed:46./255.0 green:144./255.0 blue:90./255.0 alpha:1.0]];
            [self.button setTitle:self.buttonTitle forState:UIControlStateNormal];
            
            UIColor *buttonTitleTextColor = [UIColor whiteColor];
            
            
            [self.button setTitleColor:buttonTitleTextColor forState:UIControlStateNormal];
            self.button.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
            [self.button addTarget:self
                            action:@selector(buttonTapped:)
                  forControlEvents:UIControlEventTouchUpInside];
            
            self.button.contentEdgeInsets = UIEdgeInsetsMake(0.0, 5.0, 0.0, 5.0);
            [self.button sizeToFit];
            self.button.frame = CGRectMake(screenWidth - TSMessageViewPadding - self.button.frame.size.width,
                                           0.0,
                                           self.button.frame.size.width,
                                           31.0);
            
            [self addSubview:self.button];
            
            self.textSpaceRight = self.button.frame.size.width + TSMessageViewPadding;
        }
        
        // Add a border on the bottom (or on the top, depending on the view's postion)
        _borderView = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                               0.0, // will be set later
                                                               screenWidth,
                                                               0.5)];
        self.borderView.backgroundColor = [UIColor lightGrayColor];
        self.borderView.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
        [self addSubview:self.borderView];
        
        
        CGFloat actualHeight = [self updateHeightOfMessageView]; // this call also takes care of positioning the labels
        CGFloat topPosition = -actualHeight;
        
        if (self.messagePosition == TSMessageNotificationPositionBottom)
        {
            topPosition = self.viewController.view.bounds.size.height;
        }
        
        self.frame = CGRectMake(0.0, topPosition, screenWidth, actualHeight);
        
        if (self.messagePosition == TSMessageNotificationPositionTop)
        {
            self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        }
        else
        {
            self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
        }
        
        if (dismissAble)
        {
            UISwipeGestureRecognizer *gestureRec = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                             action:@selector(fadeMeOut)];
            [gestureRec setDirection:(self.messagePosition == TSMessageNotificationPositionTop ?
                                      UISwipeGestureRecognizerDirectionUp :
                                      UISwipeGestureRecognizerDirectionDown)];
            [self addGestureRecognizer:gestureRec];
            
            UITapGestureRecognizer *tapRec = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(fadeMeOut)];
            [self addGestureRecognizer:tapRec];
        }
    }
    return self;
}


- (CGFloat)updateHeightOfMessageView
{
    CGFloat currentHeight;
    CGFloat screenWidth = self.viewController.view.bounds.size.width;
    
    
    self.titleLabel.frame = CGRectMake(self.textSpaceLeft,
                                       TSMessageViewPadding,
                                       screenWidth - TSMessageViewPadding - self.textSpaceLeft - self.textSpaceRight,
                                       0.0);
    [self.titleLabel sizeToFit];
    
    if ([self.content length])
    {
        self.contentLabel.frame = CGRectMake(self.textSpaceLeft,
                                             self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 5.0,
                                             screenWidth - TSMessageViewPadding - self.textSpaceLeft - self.textSpaceRight,
                                             0.0);
        [self.contentLabel sizeToFit];
        
        currentHeight = self.contentLabel.frame.origin.y + self.contentLabel.frame.size.height;
    }
    else
    {
        // only the title was set
        currentHeight = self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height;
    }
    
    currentHeight += TSMessageViewPadding;
    
    if (self.iconImageView)
    {
        // Check if that makes the popup larger (height)
        if (self.iconImageView.frame.origin.y + self.iconImageView.frame.size.height + TSMessageViewPadding > currentHeight)
        {
            currentHeight = self.iconImageView.frame.origin.y + self.iconImageView.frame.size.height;
        }
        else
        {
            // z-align
            self.iconImageView.center = CGPointMake([self.iconImageView center].x,
                                                    round(currentHeight / 2.0));
        }
    }
    
    // z-align button
    self.button.center = CGPointMake([self.button center].x,
                                            round(currentHeight / 2.0));
    
    if (self.messagePosition == TSMessageNotificationPositionTop)
    {
        // Correct the border position
        CGRect borderFrame = self.borderView.frame;
        borderFrame.origin.y = currentHeight;
        self.borderView.frame = borderFrame;
    }
    
    currentHeight += self.borderView.frame.size.height;
    
    self.frame = CGRectMake(0.0, self.frame.origin.y, self.frame.size.width, currentHeight);
    
    
    if (self.button)
    {
        self.button.frame = CGRectMake(self.frame.size.width - self.textSpaceRight,
                                       round((self.frame.size.height / 2.0) - self.button.frame.size.height / 2.0),
                                       self.button.frame.size.width,
                                       self.button.frame.size.height);
    }
    
    
    self.backgroundImageView.frame = CGRectMake(self.backgroundImageView.frame.origin.x,
                                                self.backgroundImageView.frame.origin.y,
                                                screenWidth,
                                                currentHeight);
    
    return currentHeight;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self updateHeightOfMessageView];
}

- (void)fadeMeOut
{
    // user tapped on the message
    dispatch_async(dispatch_get_main_queue(), ^
    {
        if (self.callback)
        {
            self.callback();
        }
        
        [[TSMessage sharedMessage] performSelector:@selector(fadeOutNotification:)
                                        withObject:self];
    });
}

#pragma mark - UIButton target

- (void)buttonTapped:(id) sender
{
    if (self.buttonCallback)
    {
        self.buttonCallback();
    }
    
    [self fadeMeOut];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return ! ([touch.view isKindOfClass:[UIControl class]]);
}

@end
