//
//  PSSDeviceCapacity.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-09-22.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSDeviceCapacity.h"
#include <sys/sysctl.h>

@implementation PSSDeviceCapacity

+(unsigned int) countCores{
    // Count the cpus on the machine
    size_t len;
    unsigned int ncpu;
    
    len = sizeof(ncpu);
    sysctlbyname ("hw.ncpu",&ncpu,&len,NULL,0);
    
    return ncpu;
}

+(BOOL)shouldRunAdvancedFeatures{
    
    // Will prevent single cpu from running some advanced features (eg. iPhone 4)
    
    if ([PSSDeviceCapacity countCores] <= 1) {
        return NO;
    }
    
    return YES;
}

@end
