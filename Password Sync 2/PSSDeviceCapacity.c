//
//  PSSDeviceCapacity.c
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-09-22.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#include <sys/sysctl.h>
#include <stdbool.h>



unsigned int PSSCountCores()
{
    // Count the cpus on the machine
    size_t len;
    unsigned int ncpu;
    
    len = sizeof(ncpu);
    sysctlbyname ("hw.ncpu",&ncpu,&len,NULL,0);
    
    return ncpu;
}

bool PSSShouldRunAdvancedFeatures() {
    
    // Will prevent single cpu from running some advanced features (eg. iPhone 4)
    
    if (PSSCountCores() <= 1) {
        return false;
    }
    
    return true;
}