//
//  RSColorPickerView.h
//  RSColorPicker
//
//  Created by Ryan Sullivan on 8/12/11.
//  Copyright 2011 Freelance Web Developer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class RSColorPickerView, BGRSLoupeLayer;

@protocol RSColorPickerViewDelegate <NSObject>
-(void)colorPickerDidChangeSelection:(RSColorPickerView*)cp;
@end

@interface RSColorPickerView : UIView

@property (nonatomic) BOOL cropToCircle;
@property (nonatomic) CGFloat brightness;
@property (nonatomic) CGFloat opacity;
@property (nonatomic) UIColor *selectionColor;
@property (nonatomic, weak) id <RSColorPickerViewDelegate> delegate;
@property (nonatomic, readonly) CGPoint selection;

-(UIColor*)colorAtPoint:(CGPoint)point; //Returns UIColor at a point in the RSColorPickerView

@end
