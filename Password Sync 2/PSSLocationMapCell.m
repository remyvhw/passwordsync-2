//
//  PSSLocationMapCell.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-20.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSLocationMapCell.h"

@implementation PSSLocationMapCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        MKMapView * mapView = [[MKMapView alloc] initWithFrame:self.frame];
        mapView.delegate = self;
        self.mapView = mapView;
        
        [self addSubview:mapView];
        
        self.shouldDrawCircle = NO;
        self.circleRadius = @150;
        self.userDidChangeMapRegion = NO;
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self.mapView setFrame:self.bounds];
}


-(void)rearrangePinAndMapLocationWithRegion:(MKCoordinateRegion)region location:(CLLocation*)pinLocation{
    
    self.userDidChangeMapRegion = YES;
    
   if (!self.locationPin) {
        MKPointAnnotation * pinMarker = [[MKPointAnnotation alloc] init];
        self.locationPin = pinMarker;
        
        [self.mapView addAnnotation:pinMarker];
    }
    
    [self.locationPin setCoordinate:pinLocation.coordinate];
        
    [self.mapView removeOverlays:[self.mapView overlays]];
    if (self.shouldDrawCircle) {
        // Clean previous overlays
        MKCircle *circle = [MKCircle circleWithCenterCoordinate:pinLocation.coordinate radius:[self.circleRadius doubleValue]];
        [self.mapView addOverlay:circle];
    }
    
    
    
    
    [self.mapView setRegion:region animated:YES];
    
}

-(MKCoordinateRegion)defaultRegionForLocation:(CLLocation*)location{
    MKCoordinateSpan span;
    if (self.userEditable) {
           span = MKCoordinateSpanMake(1/60, 1/60);
    } else {
            span = MKCoordinateSpanMake(0.007, 0.007);
    }

    MKCoordinateRegion region = MKCoordinateRegionMake(location.coordinate, span);
    return region;
}

-(void)rearrangePinAndMapLocationWithLocation:(CLLocationCoordinate2D)pinLocation{
    
    CLLocation * location = [[CLLocation alloc] initWithLatitude:pinLocation.latitude longitude:pinLocation.longitude];
    
    [self rearrangePinAndMapLocationWithRegion:[self defaultRegionForLocation:location] location:location];
    
    self.userDidChangeMapRegion = YES;
}

-(void)rearrangePinAndMapLocationWithPlacemark:(CLPlacemark *)pinPlacemark{
    
    
    
    [self rearrangePinAndMapLocationWithRegion:[self defaultRegionForLocation:pinPlacemark.location] location:pinPlacemark.location];
    
}

#pragma mark - MKMapViewProtocol

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    if (animated) {
        self.userDidChangeMapRegion = YES;
    }
    
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState{
    if (newState == MKAnnotationViewDragStateEnding) {
        
        double delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            CLLocationCoordinate2D droppedAt = view.annotation.coordinate;
            [self.mapView setCenterCoordinate:droppedAt animated:YES];
        });
        
    }
}


-(MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    
    static NSString *reuseId = @"draggablePin";
    MKPinAnnotationView *pav = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
    if (pav == nil)
    {
        pav = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
        pav.draggable = self.userEditable;
        pav.pinColor = MKPinAnnotationColorGreen;
        pav.canShowCallout = NO;
    }
    else {
        pav.annotation = annotation;
    }
    
    return pav;
}

- (MKOverlayView *)mapView:(MKMapView *)map viewForOverlay:(id <MKOverlay>)overlay
{
    MKCircleView *circleView = [[MKCircleView alloc] initWithOverlay:overlay];
    circleView.strokeColor = [UIColor colorWithRed:46./255.0 green:144./255.0 blue:90./255.0 alpha:0.9];
    circleView.fillColor = [UIColor colorWithWhite:1.0 alpha:0.2];
    return circleView;
}

@end
