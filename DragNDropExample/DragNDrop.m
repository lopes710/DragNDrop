//
//  DragNDrop.m
//  DragNDropExample
//
//  Created by Duarte Lopes on 03/06/15.
//  Copyright (c) 2015 Duarte Lopes. All rights reserved.
//

#import "DragNDrop.h"
#import "DLDraggedCellData.h"

typedef void(^DLCellOnLongPressCompletionBlock)(DLDraggedCellData *draggedCellData);

@interface DragNDrop ()

@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;

@property (nonatomic, strong) NSMutableArray *tablesArray;
@property (nonatomic, strong) NSMutableArray *dataSourceArray;
@property (nonatomic, strong) NSMutableArray *delegatesArray;

// point positions
@property (nonatomic) CGPoint pointPositionOriginPressed;
@property (nonatomic) CGPoint pointPositionInCell;

// selected cell data
@property (nonatomic, strong) DLDraggedCellData *draggedCellData;

@end

@implementation DragNDrop

#pragma mark - Lifecycle

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

#pragma mark - Public methods

- (void)addTable:(UITableView *)tableView
      dataSource:(NSArray *)datasource
        delegate:(id)delegate {

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
           withCompletionHandler:^(DLDraggedCellData *draggedCellData) {
               
               if (draggedCellData) {
                   
                   self.draggedCellData = draggedCellData;
                   [windowView addSubview:self.draggedCellData.draggedCell];
                   [self deleteRowAt:self.draggedCellData.selectedIndexPathInsideList];
               }
           }];
        
    } else if(sender.state == UIGestureRecognizerStateChanged) {
        
        // check if there is a draggedCell
        if (self.draggedCellData.draggedCell) {
            
            NSLog(@"Long press changed");
            
            CGPoint newPointPositionPressed = CGPointMake(pointPositionPressed.x - self.pointPositionInCell.x, pointPositionPressed.y - self.pointPositionInCell.y);
            
            self.draggedCellData.draggedCell.frame = CGRectMake(newPointPositionPressed.x, newPointPositionPressed.y, self.draggedCellData.draggedCell.frame.size.width, self.draggedCellData.draggedCell.frame.size.height);
        }
        
    } else if (sender.state == UIGestureRecognizerStateEnded ||
               sender.state == UIGestureRecognizerStateCancelled ||
               sender.state == UIGestureRecognizerStateFailed) {
        
        // check if there is a draggedCell
        if (self.draggedCellData.draggedCell) {
            
            NSLog(@"Long press ended");
            
            //return cell to initial location
            [self repositionCellToOriginalLocation];
        }
    }
}

#pragma mark - Private methods

- (UITableView *)getSelectedTableView {

    return self.tablesArray[self.draggedCellData.selectedIndexOfList];
}

- (NSArray *)getSelectedDataSource {
    
    return self.dataSourceArray[self.draggedCellData.selectedIndexOfList];
}

- (id)getSelectedDelegate {
    
    return self.delegatesArray[self.draggedCellData.selectedIndexOfList];
}

//- (Class)classOfElement:(id)element {
//
//    
//}

- (void)getCellOnLongPress:(UILongPressGestureRecognizer *)sender
          pointPositionPressed:(CGPoint)pointPositionPressed
         withCompletionHandler:(DLCellOnLongPressCompletionBlock)completionBlock {

    // get selected Index
    __block NSInteger selectedListIndexPathRow;
    [self.tablesArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if (sender.view == obj) {
        
            selectedListIndexPathRow = idx;
        }
    }];
    
    UITableView *selectedTableView = self.tablesArray[selectedListIndexPathRow];
    
    // get point in tableView to find the indexPath of selected cell
    CGPoint pointPositionInTableView = [sender locationInView:selectedTableView];
    NSIndexPath *indexPath = [selectedTableView indexPathForRowAtPoint:pointPositionInTableView];
    
    if (indexPath) {
        
        NSArray *selectedDatasource = self.dataSourceArray[selectedListIndexPathRow];
        
        // save the original item in case the cell gets back to it´s place or is inserted in a new list
        id currentDraggedItem = selectedDatasource[indexPath.row];
        
        // create image representation of cell
        UITableViewCell *cell = [selectedTableView cellForRowAtIndexPath:indexPath];
        UIImageView *draggedCell = [[UIImageView alloc] initWithFrame:cell.frame];
        
        UIGraphicsBeginImageContext(cell.bounds.size);
        [cell.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *imageCell = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIImageView *imageViewCell = [[UIImageView alloc] initWithImage:imageCell];
        
        [draggedCell addSubview:imageViewCell];
        
        // get point in draggedCell to set the origin point to move the copied cell
        self.pointPositionInCell = [sender locationInView:cell];

        self.pointPositionOriginPressed = CGPointMake(pointPositionPressed.x - self.pointPositionInCell.x, pointPositionPressed.y - self.pointPositionInCell.y);
        
        draggedCell.frame = CGRectMake(self.pointPositionOriginPressed.x, self.pointPositionOriginPressed.y, self.draggedCellData.draggedCell.frame.size.width, self.draggedCellData.draggedCell.frame.size.height);

        DLDraggedCellData *draggedCellData = [[DLDraggedCellData alloc] initWithCell:draggedCell selectedIndexOfList:selectedListIndexPathRow selectedIndexPathInsideList:indexPath item:currentDraggedItem];
        
        completionBlock(draggedCellData);
        
    } else {
        
        // The user didn´t touch a cell
        completionBlock(nil);
    }
}

- (void)repositionCellToOriginalLocation {

    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.draggedCellData.draggedCell.frame = CGRectMake(self.pointPositionOriginPressed.x, self.pointPositionOriginPressed.y, self.draggedCellData.draggedCell.frame.size.width, self.draggedCellData.draggedCell.frame.size.height);
        
    } completion:^(BOOL finished) {
        
        // update datasource and UI of selected table
        [self insertRowAt:self.draggedCellData.selectedIndexPathInsideList withItem:self.draggedCellData.draggedItem];
        
        //clear draggedCellData
        self.draggedCellData = nil;
        
    }];
}

#pragma mark - TableView UI and datasource updates

- (void)deleteRowAt:(NSIndexPath *)indexPath {
    
    UITableView *selectedTableView = [self getSelectedTableView];
    id <DragNDropDelegate> delegate = [self getSelectedDelegate];
    
    if([delegate respondsToSelector:@selector(didDragOutside:updatedDatasource:)]) {
    
        NSMutableArray *updatedDataSource = [NSMutableArray arrayWithArray:[self getSelectedDataSource]];

        // remove from data source array and notify delegate of of new data source
        [updatedDataSource removeObjectAtIndex:indexPath.row];
        [delegate didDragOutside:selectedTableView updatedDatasource:updatedDataSource];
        
        // update local dataSourceArray
        self.dataSourceArray[self.draggedCellData.selectedIndexOfList] = updatedDataSource;
        
        [selectedTableView beginUpdates];
        [selectedTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [selectedTableView endUpdates];
    }
}

- (void)insertRowAt:(NSIndexPath *)indexPath
           withItem:(id)item {

    UITableView *selectedTableView = [self getSelectedTableView];
    id <DragNDropDelegate> delegate = [self getSelectedDelegate];
    
    if([delegate respondsToSelector:@selector(didMoveCellToOriginalPosition:updatedDatasource:)]) {
    
        NSMutableArray *updatedDataSource = [NSMutableArray arrayWithArray:[self getSelectedDataSource]];
        
        // insert item to updated datasource array and notify delegate of of new data source
        [updatedDataSource insertObject:self.draggedCellData.draggedItem atIndex:indexPath.row];
        
        [delegate didMoveCellToOriginalPosition:selectedTableView updatedDatasource:updatedDataSource];
        
        // update local dataSourceArray
        self.dataSourceArray[self.draggedCellData.selectedIndexOfList] = updatedDataSource;

        [selectedTableView beginUpdates];
        [selectedTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [selectedTableView endUpdates];
    }
}

@end
