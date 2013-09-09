//
//  PSSBarcodeScannerViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-09-04.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSBarcodeScannerViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface PSSBarcodeScannerViewController () <AVCaptureMetadataOutputObjectsDelegate>

@property (strong, nonatomic) AVCaptureSession* session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (strong,nonatomic) AVCaptureMetadataOutput *metadataOutput;
@property (nonatomic) BOOL didAlreadyCaptureBarcode;

@end

@implementation PSSBarcodeScannerViewController

-(void)dismissWithQRString:(NSString*)contentString{
    
    // Might be called multiple times
    if (self.didAlreadyCaptureBarcode) {
        return;
    }
    
    self.didAlreadyCaptureBarcode = YES;
    
    if (self.scannerDelegate) {
        [self.scannerDelegate barcodeScanner:self finishedWithString:contentString];
    }
    
}

-(void)cancelAndDismiss:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIBarButtonItem * cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAndDismiss:)];
    
    self.navigationItem.leftBarButtonItem = cancelButton;
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    
    self.session = [AVCaptureSession new];
    [self.session setSessionPreset:AVCaptureSessionPresetPhoto];
    
    [self updateCameraSelection];
    
    // For displaying live feed to screen
    CALayer *rootLayer = self.view.layer;
    [rootLayer setMasksToBounds:YES];
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    [self.previewLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    [self.previewLayer setFrame:[rootLayer bounds]];
    [rootLayer addSublayer:self.previewLayer];
    
    [self setupBarcodeDetection];
    
    [self.session startRunning];
    
}

- (void)teardownBarcodeDetection {
    if ( self.metadataOutput ) {
        [self.session removeOutput:self.metadataOutput];
    }
    [self cancelAndDismiss:nil];
}

- (void)setupBarcodeDetection {
    self.metadataOutput = [AVCaptureMetadataOutput new];
    if ( ! [self.session canAddOutput:self.metadataOutput] ) {
        [self teardownBarcodeDetection];
        return;
    }
    
    // Metadata processing will be fast, and mostly updating UI which should be done on the main thread
    // So just use the main dispatch queue instead of creating a separate one
    [self.metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [self.session addOutput:self.metadataOutput];
    
    if ( ! [self.metadataOutput.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode] ) {
        [self teardownBarcodeDetection];
        return;
    }
    
    self.metadataOutput.metadataObjectTypes = @[ AVMetadataObjectTypeQRCode];
}

- (void) captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)faces fromConnection:(AVCaptureConnection *)connection {
    for (AVMetadataMachineReadableCodeObject *object in faces) {
        if ([object.stringValue hasPrefix:@"otpauth://"]) {
            [self dismissWithQRString:object.stringValue];
            break;
        }
    }
}

- (AVCaptureDeviceInput*) pickCamera {
    AVCaptureDevicePosition desiredPosition;
    if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
        desiredPosition = AVCaptureDevicePositionBack;
    } else {
        desiredPosition = AVCaptureDevicePositionFront;
    }

    BOOL hadError = NO;
    
    for (AVCaptureDevice *d in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if ([d position] == desiredPosition) {
            NSError *error = nil;
            AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:d error:&error];
            if (error) {
                hadError = YES;
                displayErrorOnMainQueue(error, @"Could not initialize for AVMediaTypeVideo");
            } else if ( [self.session canAddInput:input] ) {
                return input;
            }
        }
    }
    
    if ( ! hadError ) {
        // no errors, simply couldn't find a matching camera
        displayErrorOnMainQueue(nil, @"No camera found for requested orientation");
    }
    
    return nil;
}

- (void) updateCameraSelection {
    // Changing the camera device will reset connection state, so we call the
    // update*Detection functions to resync them.  When making multiple
    // session changes, wrap in a beginConfiguration / commitConfiguration.
    // This will avoid consecutive session restarts for each configuration
    // change (noticeable delay and camera flickering)
    
    [self.session beginConfiguration];
    
    // have to remove old inputs before we test if we can add a new input
    NSArray* oldInputs = [self.session inputs];
    
    for (AVCaptureInput *oldInput in oldInputs)
        [self.session removeInput:oldInput];
    
    AVCaptureDeviceInput* input = [self pickCamera];
    if ( ! input ) {
        // failed, restore old inputs
        for (AVCaptureInput *oldInput in oldInputs)
            [self.session addInput:oldInput];
    } else {
        // succeeded, set input and update connection states
        [self.session addInput:input];
    }
    
    [self.session commitConfiguration];
}

- (void)dealloc {
    [self.session stopRunning];
    
    [self.previewLayer removeFromSuperlayer];
    self.previewLayer = nil;
    
    self.session = nil;
}

void displayErrorOnMainQueue(NSError *error, NSString *message)
{
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        UIAlertView* alert = [UIAlertView new];
        if(error) {
            alert.title = [NSString stringWithFormat:@"%@ (%zd)", message, error.code];
            alert.message = [error localizedDescription];
        } else {
            alert.title = message;
        }
        
        [alert addButtonWithTitle:@"Dismiss"];
        [alert show];
    });
}

@end
