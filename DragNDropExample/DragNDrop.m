//
//  DragNDrop.m
//  DragNDropExample
//
//  Created by Duarte Lopes on 03/06/15.
//  Copyright (c) 2015 Duarte Lopes. All rights reserved.
//

#import "DragNDrop.h"

typedef void(^DLCellOnLongPressCompletionBlock)(UIView *selectedCell, NSIndexPath *indexPath);

@interface DragNDrop ()

@property (nonatomic, strong) NSMutableArray *tablesArray;
@property (nonatomic, strong) NSMutableArray *dataSourceArray;
@property (nonatomic, strong) NSMutableArray *delegatesArray;

@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;
@property (nonatomic, strong) UIImageView *selectedCell;
@property (nonatomic) CGPoint pointPositionInCell;

@property (nonatomic, assign) NSInteger selectedListIndexPathRow;

@property (nonatomic) id currentDraggedItem;

@end

@implementation DragNDrop

- (instancetype)init {

    self = [super init];
    
    if (self) {
        
        _tablesArray = [NSMutableArray array];
        _dataSourceArray = [NSMutableArray array];
        _delegatesArray = [NSMutableArray array];
    }
    
    return self;
}

+ (id)sharedManager {

    static DragNDrop *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

- (void)addTable:(UITableView *)tableView datasSource:(NSArray *)datasource delegate:(id)delegate {

    [self.tablesArray addObject:tableView];
    [self.dataSourceArray addObject:datasource];
    [self.delegatesArray addObject:delegate];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    longPress.minimumPressDuration = 0.2f;
    [tableView addGestureRecognizer:longPress];
}

#pragma mark - private methods

- (UITableView *)getSelectedTableView {

    return self.tablesArray[self.selectedListIndexPathRow];
}

- (NSMutableArray *)getSelectedDataSource {
    
    return self.dataSourceArray[self.selectedListIndexPathRow];
}

- (id)getSelectedDelegate {
    
    return self.delegatesArray[self.selectedListIndexPathRow];
}

//- (Class)classOfElement:(id)element {
//
//    
//}

#pragma mark - GestureRecognizer methods

- (IBAction)longPress:(UILongPressGestureRecognizer *)sender {

    UIView *windowView = [[[UIApplication sharedApplication] windows] lastObject];
    CGPoint pointPositionPressed = [sender locationInView:windowView];

    if (sender.state == UIGestureRecognizerStateBegan) {
        
        [self getCellOnLongPress:sender
            pointPositionPressed:pointPositionPressed
           withCompletionHandler:^(UIView *selectedCell, NSIndexPath *indexPath) {
               
               if (indexPath) {
                   
                   [windowView addSubview:selectedCell];
                   [self deleteRowAt:indexPath];
               }
           }];
        
    } else if(sender.state == UIGestureRecognizerStateChanged) {
        
        // check if there is a selectedCell
        if (self.selectedCell) {
            
            NSLog(@"Long press changed");
            
            CGPoint pointPositionOriginPressed = CGPointMake(pointPositionPressed.x - self.pointPositionInCell.x, pointPositionPressed.y - self.pointPositionInCell.y);
            
            self.selectedCell.frame = CGRectMake(pointPositionOriginPressed.x, pointPositionOriginPressed.y, self.selectedCell.frame.size.width, self.selectedCell.frame.size.height);
        }
        
        
    } else if (sender.state == UIGestureRecognizerStateEnded ||
               sender.state == UIGestureRecognizerStateCancelled ||
               sender.state == UIGestureRecognizerStateFailed) {
        
        // check if there is a selectedCell
        if (self.selectedCell) {
            
            NSLog(@"Long press ended");
        }
    }
}

- (void)getCellOnLongPress:(UILongPressGestureRecognizer *)sender
          pointPositionPressed:(CGPoint)pointPositionPressed
         withCompletionHandler:(DLCellOnLongPressCompletionBlock)completionBlock {

    // set selected table
//    for (UITableView *tableView in self.tablesArray) {
//        
//        if (sender.view == tableView) {
//            
//            self.selectedTableView = tableView;
//        }
//    }
    
    [self.tablesArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if (sender.view == obj) {
        
            self.selectedListIndexPathRow = idx;
        }
    }];
    
    UITableView *selectedTableView = [self getSelectedTableView];
    
    // get point in tableView to find the indexPath of selected cell
    CGPoint pointPositionInTableView = [sender locationInView:selectedTableView];
    NSIndexPath *indexPath = [selectedTableView indexPathForRowAtPoint:pointPositionInTableView];
    
    if (indexPath) {
        
        // create image representation of cell
        UITableViewCell *cell = [selectedTableView cellForRowAtIndexPath:indexPath];
        self.selectedCell = [[UIImageView alloc] initWithFrame:cell.frame];
        
        UIGraphicsBeginImageContext(cell.bounds.size);
        [cell.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *imageCell = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIImageView *imageViewCell = [[UIImageView alloc] initWithImage:imageCell];
        
        [self.selectedCell addSubview:imageViewCell];
        
        
        // antigo
//        self.selectedCell = [selectedTableView cellForRowAtIndexPath:indexPath];
//        self.pointPositionInCell = [sender locationInView:self.selectedCell];
        
        // get point in selectedCell to reposition the copied cell to the correct place
        self.pointPositionInCell = [sender locationInView:cell];

        CGPoint pointPositionOriginPressed = CGPointMake(pointPositionPressed.x - self.pointPositionInCell.x, pointPositionPressed.y - self.pointPositionInCell.y);
        
        self.selectedCell.frame = CGRectMake(pointPositionOriginPressed.x, pointPositionOriginPressed.y, self.selectedCell.frame.size.width, self.selectedCell.frame.size.height);
        
        completionBlock(self.selectedCell, indexPath);
        
    } else {
        
        // The user didn´t touch a cell
        self.selectedCell = nil;
        completionBlock(nil, nil);
    }
    
}

#pragma mark - tableView Updates

- (void)deleteRowAt:(NSIndexPath *)indexPath {
    
    UITableView *selectedTableView = [self getSelectedTableView];
    id <DragNDropDelegate> delegate = [self getSelectedDelegate];
    
    if([delegate respondsToSelector:@selector(didDragOutside:updatedDatasource:)]) {
    
        NSMutableArray *updatedDataSource = [NSMutableArray arrayWithArray:[self getSelectedDataSource]];
        
        // save the original dataSource or item in case the cell gets back to it´s place?
        self.currentDraggedItem = updatedDataSource[indexPath.row];
        
        // remove from data source array and notify delegate of of new data source
        [updatedDataSource removeObjectAtIndex:indexPath.row];
        [delegate didDragOutside:selectedTableView updatedDatasource:updatedDataSource];
        
        // update local dataSourceArray
        self.dataSourceArray[self.selectedListIndexPathRow] = updatedDataSource;
        
        [selectedTableView beginUpdates];
        [selectedTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [selectedTableView endUpdates];
    }
}

@end
