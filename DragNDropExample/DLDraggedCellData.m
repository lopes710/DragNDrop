//
//  DLSelectedCellData.m
//  DragNDropExample
//
//  Created by Duarte Lopes on 23/07/15.
//  Copyright (c) 2015 Duarte Lopes. All rights reserved.
//

#import "DLDraggedCellData.h"

@interface DLDraggedCellData ()

@property (nonatomic, strong) UIImageView *draggedCell;
@property (nonatomic, assign) NSInteger selectedIndexOfList;
@property (nonatomic, strong) NSIndexPath *selectedIndexPathInsideList;
@property (nonatomic, strong) id draggedItem;

@end

@implementation DLDraggedCellData

#pragma mark - Lifecycle

- (instancetype)initWithCell:(UIImageView *)imageCell
         selectedIndexOfList:(NSInteger)index
 selectedIndexPathInsideList:(NSIndexPath *)indexPath
                        item:(id)item {

    self = [super init];
    
    if (self) {
    
        _draggedCell = imageCell;
        _selectedIndexOfList = index;
        _selectedIndexPathInsideList = indexPath;
        _draggedItem = item;
        
        [self configureWithAppearance];
        
    }
    
    return self;
}

- (void)dealloc {

    [self.draggedCell removeFromSuperview];
}

#pragma mark - Private methods

- (void)configureWithAppearance {

    // transparency and shadow
    self.draggedCell.layer.masksToBounds = NO;
    self.draggedCell.layer.cornerRadius = 2.0;
    self.draggedCell.layer.shadowOffset = CGSizeMake(-5.0, 5.0);
    self.draggedCell.layer.shadowRadius = 2.0;
    self.draggedCell.layer.shadowOpacity = 0.6;
    self.draggedCell.alpha = 0.7f;
}

@end
