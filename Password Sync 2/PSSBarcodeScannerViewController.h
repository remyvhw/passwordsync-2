//
//  PSSBarcodeScannerViewController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-09-04.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PSSBarcodeScannerDelegate;
@interface PSSBarcodeScannerViewController : UIViewController
@property (nonatomic, weak) id<PSSBarcodeScannerDelegate> scannerDelegate;
@end

@protocol PSSBarcodeScannerDelegate <NSObject>

-(void)barcodeScanner:(PSSBarcodeScannerViewController*)scanner finishedWithString:(NSString*)qrcode;

@end
