//
//  DragNDrop.m
//  DragNDropExample
//
//  Created by Duarte Lopes on 03/06/15.
//  Copyright (c) 2015 Duarte Lopes. All rights reserved.
//

#import "DragNDrop.h"

typedef void(^DLCellOnLongPressCompletionBlock)(UIView *draggedCell, NSIndexPath *indexPath);

@interface DragNDrop ()

@property (nonatomic, strong) NSMutableArray *tablesArray;
@property (nonatomic, strong) NSMutableArray *dataSourceArray;
@property (nonatomic, strong) NSMutableArray *delegatesArray;

@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;

// point positions
@property (nonatomic) CGPoint pointPositionOriginPressed;
@property (nonatomic) CGPoint pointPositionInCell;

// selected data
@property (nonatomic, strong) UIImageView *draggedCell;
@property (nonatomic, assign) NSInteger selectedListIndexPathRow;
// TODO: add another selected indexPath to know which one selected inside tableview

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

#pragma mark - GestureRecognizer methods

- (IBAction)longPress:(UILongPressGestureRecognizer *)sender {
    
    UIView *windowView = [[[UIApplication sharedApplication] windows] lastObject];
    CGPoint pointPositionPressed = [sender locationInView:windowView];
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        
        NSLog(@"Long press began");
        
        [self getCellOnLongPress:sender
            pointPositionPressed:pointPositionPressed
           withCompletionHandler:^(UIView *draggedCell, NSIndexPath *indexPath) {
               
               if (indexPath) {
                   
                   // TODO: change this - create an object with all the selections data?
                   [windowView addSubview:self.draggedCell];
                   [self deleteRowAt:indexPath];
               }
           }];
        
    } else if(sender.state == UIGestureRecognizerStateChanged) {
        
        // check if there is a draggedCell
        if (self.draggedCell) {
            
            NSLog(@"Long press changed");
            
            CGPoint newPointPositionPressed = CGPointMake(pointPositionPressed.x - self.pointPositionInCell.x, pointPositionPressed.y - self.pointPositionInCell.y);
            
            self.draggedCell.frame = CGRectMake(newPointPositionPressed.x, newPointPositionPressed.y, self.draggedCell.frame.size.width, self.draggedCell.frame.size.height);
        }
        
        
    } else if (sender.state == UIGestureRecognizerStateEnded ||
               sender.state == UIGestureRecognizerStateCancelled ||
               sender.state == UIGestureRecognizerStateFailed) {
        
        // check if there is a draggedCell
        if (self.draggedCell) {
            
            NSLog(@"Long press ended");
            
            //return cell to initial location
            [self repositionCellToOriginalLocation];
        }
    }
}

#pragma mark - private methods

- (void)resetDraggedCell {

    [self.draggedCell removeFromSuperview];
    self.draggedCell = nil;
}

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

- (void)getCellOnLongPress:(UILongPressGestureRecognizer *)sender
          pointPositionPressed:(CGPoint)pointPositionPressed
         withCompletionHandler:(DLCellOnLongPressCompletionBlock)completionBlock {

    // get selected Index
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
        self.draggedCell = [[UIImageView alloc] initWithFrame:cell.frame];
        
        UIGraphicsBeginImageContext(cell.bounds.size);
        [cell.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *imageCell = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIImageView *imageViewCell = [[UIImageView alloc] initWithImage:imageCell];
        
        [self.draggedCell addSubview:imageViewCell];
        
        // get point in draggedCell to set the origin point to move the copied cell
        self.pointPositionInCell = [sender locationInView:cell];

        self.pointPositionOriginPressed = CGPointMake(pointPositionPressed.x - self.pointPositionInCell.x, pointPositionPressed.y - self.pointPositionInCell.y);
        
        self.draggedCell.frame = CGRectMake(self.pointPositionOriginPressed.x, self.pointPositionOriginPressed.y, self.draggedCell.frame.size.width, self.draggedCell.frame.size.height);
        
        completionBlock(self.draggedCell, indexPath);
        
    } else {
        
        // The user didn´t touch a cell
        self.draggedCell = nil;
        completionBlock(nil, nil);
    }
}

- (void)repositionCellToOriginalLocation {

    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.draggedCell.frame = CGRectMake(self.pointPositionOriginPressed.x, self.pointPositionOriginPressed.y, self.draggedCell.frame.size.width, self.draggedCell.frame.size.height);
        
    } completion:^(BOOL finished) {
        
        NSLog(@"BACK IN POSITION");
        
        [self resetDraggedCell];
        // update datasource and UI of selected table
        [self insertRowAt:nil withItem:self.currentDraggedItem];
        
        //                [self.draggedCell removeFromSuperview];
        //                self.inDrag = NO;
        //                hasBlankCell = NO;
        //                self.intersectedCell = nil;
        //                isDraggedCellIntersectedWithDetailCalendar = NO;
        
    }];
}

#pragma mark - tableView Updates

- (void)deleteRowAt:(NSIndexPath *)indexPath {
    
    UITableView *selectedTableView = [self getSelectedTableView];
    id <DragNDropDelegate> delegate = [self getSelectedDelegate];
    
    if([delegate respondsToSelector:@selector(didDragOutside:updatedDatasource:)]) {
    
        NSMutableArray *updatedDataSource = [NSMutableArray arrayWithArray:[self getSelectedDataSource]];
        
        // save the original item in case the cell gets back to it´s place
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

- (void)insertRowAt:(NSIndexPath *)indexPath withItem:(id)item {

    UITableView *selectedTableView = [self getSelectedTableView];
    id <DragNDropDelegate> delegate = [self getSelectedDelegate];
    
    if([delegate respondsToSelector:@selector(didMoveCellToOriginalPosition:updatedDatasource:)]) {
    
        NSMutableArray *updatedDataSource = [NSMutableArray arrayWithArray:[self getSelectedDataSource]];
        
        // insert item to updated datasource array and notify delegate of of new data source
        [updatedDataSource insertObject:self.currentDraggedItem atIndex:7];
        [delegate didMoveCellToOriginalPosition:selectedTableView updatedDatasource:updatedDataSource];
        
        // update local dataSourceArray
        self.dataSourceArray[self.selectedListIndexPathRow] = updatedDataSource;

        [selectedTableView beginUpdates];
        [selectedTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:7 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [selectedTableView endUpdates];
    }
}

@end
