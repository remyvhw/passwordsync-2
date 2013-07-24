//
//  PSSSwitchTableViewCell.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-24.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSSwitchTableViewCell.h"

@implementation PSSSwitchTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        UISwitch * switchView = [[UISwitch alloc] init];
        self.switchView = switchView;
        self.accessoryView = self.switchView;
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

@end
