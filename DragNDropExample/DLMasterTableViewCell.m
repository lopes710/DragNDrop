//
//  DLMasterTableViewCell.m
//  DragNDropExample
//
//  Created by Duarte Lopes on 01/08/15.
//  Copyright (c) 2015 Duarte Lopes. All rights reserved.
//

#import "DLMasterTableViewCell.h"

@implementation DLMasterTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    self.backgroundColor = [UIColor orangeColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
