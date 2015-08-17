//
//  DragNDrop.m
//  DragNDropExample
//
//  Created by Duarte Lopes on 03/06/15.
//  Copyright (c) 2015 Duarte Lopes. All rights reserved.
//

#import "DragNDrop.h"
#import "DLDraggedCellData.h"
#import "DLPlaceholderCellData.h"
#import "NSMutableArray+Actions.h"
#import "DLTableData.h"

#define kDLScrollSpeed      10.f

typedef void(^DLCellOnLongPressCompletionBlock)(DLDraggedCellData *draggedCellData);

@interface DragNDrop ()

@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;

@property (nonatomic, strong) NSMutableArray *tableDataArray;

// point positions
@property (nonatomic) CGPoint pointPositionOriginPressed;
@property (nonatomic) CGPoint pointPositionInCell;

// dragged cell data
@property (nonatomic, strong) DLDraggedCellData *draggedCellData;
@property (nonatomic, strong) DLPlaceholderCellData *placeHolderCellData;

//@property (nonatomic, assign) BOOL inDrag;

// timer used to scroll down or up
@property (nonatomic, strong) NSTimer *timer;

@end


/* TODOs:

 1) Add a flag inDrag to not select another cell while animating                    -
 2) optional: Make placeholder empty or with data ?                                 -   done
 3) Add system to know what tables are able to intersect anothers                   -   done
 4) optional: configuration of draggedCell ?                                        -
 5) scroll when drag in top or bottom                                               -   done
 6) optional: allow to delete cell instead of get reposition to original location   -
 7) check intersection when table is empty                                          -   done
 
 */

@implementation DragNDrop

#pragma mark - Lifecycle

- (instancetype)init {

    self = [super init];
    
    if (self) {
        
        _tableDataArray = [NSMutableArray array];
        _configuration = [[DLConfiguration alloc] init];
        
        // set observer in case of orientation change. In this case the dragNDrop is canceled
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:[UIDevice currentDevice]];
    }
    
    return self;
}

+ (instancetype)sharedManager {

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
        delegate:(id)delegate
       tableName:(NSString *)tableName
canIntersectTables:(NSArray *)intersectTables {
    
    // check if table is already added
    for (DLTableData *tableData in self.tableDataArray) {
        
        if (tableData.tableView == tableView) {
            
            NSLog(@"DragNDrop: tableView was already added.");
            return;
        }
    }
    
    DLTableData *tableData = [[DLTableData alloc] initTable:tableView
                                                 dataSource:datasource
                                                   delegate:delegate
                                                  tableName:tableName
                                         canIntersectTables:intersectTables];
    
    [self.tableDataArray addObject:tableData];
    
    if (intersectTables.count > 0) {
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                action:@selector(longPress:)];
        longPress.minimumPressDuration = 0.2f;
        [tableView addGestureRecognizer:longPress];
    }
}

#pragma mark - GestureRecognizer methods

- (IBAction)longPress:(UILongPressGestureRecognizer *)sender {
    
    // TODO: use boolean to validade if if it can longPress again _inDrag ??
    
    UIView *windowView = [self getWindowView];
    CGPoint pointPositionPressed = [sender locationInView:windowView];
    
    if (sender.state == UIGestureRecognizerStateBegan) {

        [self getCellOnLongPress:sender
            pointPositionPressed:pointPositionPressed
           withCompletionHandler:^(DLDraggedCellData *draggedCellData) {
               
               if (draggedCellData) {
                   
                   self.draggedCellData = draggedCellData;
                   [windowView addSubview:self.draggedCellData.draggedCell];
                   [self deleteRowAt:self.draggedCellData.selectedIndexPathInsideList
                          tableIndex:self.draggedCellData.selectedIndexOfList];
               }
           }];
        
    } else if(sender.state == UIGestureRecognizerStateChanged) {

        // check if there is a draggedCell
        if (self.draggedCellData.draggedCell) {
            
            [self updateCellPosition:pointPositionPressed];
            
            [self checkIntersectionWhileStateChanged:sender
                                          pointPress:pointPositionPressed];
        }
        
    } else if ((sender.state == UIGestureRecognizerStateEnded ||
               sender.state == UIGestureRecognizerStateCancelled ||
               sender.state == UIGestureRecognizerStateFailed)) {
        
        [self resetTimer];
        
        [self checkIntersectionWhenStateEnded:sender];
    }
}

#pragma mark - Private methods: helpers

- (UIView *)getWindowView {

    UIView *windowView = [[[UIApplication sharedApplication] windows] lastObject];
    
    return windowView;
}

- (UITableView *)getTableView:(NSInteger)index {

    DLTableData *tableData = self.tableDataArray[index];
    
    return tableData.tableView;
}

- (NSArray *)getDataSource:(NSInteger)index {
    
    DLTableData *tableData = self.tableDataArray[index];
    
    return tableData.datasource;
}

- (id)getDelegate:(NSInteger)index {
    
    DLTableData *tableData = self.tableDataArray[index];
    
    return tableData.delegate;
}

- (UIImage *)createImageFromCell:(UITableViewCell *)cell {
    
    UIGraphicsBeginImageContext(cell.bounds.size);
    [cell.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *imageCell = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCell;
}

- (void)clearDraggedCell {
    
    self.draggedCellData = nil;
}

- (void)clearPlaceholderCell {
    
    self.placeHolderCellData = nil;
}

- (void)scrollDown:(NSTimer *)sender {
    
    NSDictionary *userDictionary = (NSDictionary *)sender.userInfo;
    
    UITableView *tableView = userDictionary[@"tableView"];
    UILongPressGestureRecognizer *longGesture = userDictionary[@"sender"];
    CGPoint pointPositionPressed = [userDictionary[@"pointPositionPressed"] CGPointValue];
    
    CGFloat tableViewHeight = tableView.contentSize.height - tableView.frame.size.height;
    
    if (tableView.contentOffset.y < tableViewHeight) {
        
        CGPoint currentOff = tableView.contentOffset;
        currentOff.y += kDLScrollSpeed;
        
        if (currentOff.y > tableViewHeight) {
        
            currentOff.y = tableViewHeight;
        }
        
        [tableView setContentOffset:currentOff animated:NO];
        
        
        [self checkIntersectionWhileStateChanged:longGesture
                                      pointPress:pointPositionPressed];
        
    } else {
        
        [self resetTimer];
    }
}

- (void)scrollUp:(NSTimer *)sender {

    NSDictionary *userDictionary = (NSDictionary *)sender.userInfo;
    
    UITableView *tableView = userDictionary[@"tableView"];
    UILongPressGestureRecognizer *longGesture = userDictionary[@"sender"];
    CGPoint pointPositionPressed = [userDictionary[@"pointPositionPressed"] CGPointValue];

    if (tableView.contentOffset.y > 0.f) {
        
        CGPoint currentOff = tableView.contentOffset;
        currentOff.y -= kDLScrollSpeed;
        
        if (currentOff.y < 0) {
            
            currentOff.y = 0;
        }
        
        [tableView setContentOffset:currentOff animated:NO];
 
        [self checkIntersectionWhileStateChanged:longGesture
                                      pointPress:pointPositionPressed];
        
    } else {
        
        
        [self resetTimer];
    }
}

- (void)resetTimer {
    
    if (self.timer) {

        [self.timer invalidate];
        self.timer = nil;
    }
}

#pragma mark - Private methods: Cell calculations

- (void)getCellOnLongPress:(UILongPressGestureRecognizer *)sender
          pointPositionPressed:(CGPoint)pointPositionPressed
         withCompletionHandler:(DLCellOnLongPressCompletionBlock)completionBlock {

    // get selected Index
    __block NSInteger selectedListIndexPathRow;
    
    [self.tableDataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    
        DLTableData *tableData = (DLTableData *)obj;
        UITableView *tableView = tableData.tableView;
        
        if (sender.view == tableView) {
        
            selectedListIndexPathRow = idx;
        }
    }];
    
    DLTableData *tableData = self.tableDataArray[selectedListIndexPathRow];
    UITableView *selectedTableView = tableData.tableView;
    
    // get point in tableView to find the indexPath of selected cell
    CGPoint pointPositionInTableView = [sender locationInView:selectedTableView];
    NSIndexPath *indexPath = [selectedTableView indexPathForRowAtPoint:pointPositionInTableView];
    
    if (indexPath) {
        
        NSArray *selectedDatasource = tableData.datasource;
        
        // save the original item in case the cell gets back to it´s place or is inserted in a new list
        id currentDraggedItem = selectedDatasource[indexPath.row];
        
        // create image representation of cell
        UITableViewCell *cell = [selectedTableView cellForRowAtIndexPath:indexPath];
        UIImageView *draggedCell = [[UIImageView alloc] initWithFrame:cell.frame];
        
        UIImage *imageCell = [self createImageFromCell:cell];
        
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

- (void)updateCellPosition:(CGPoint)pointPositionPressed {

    CGPoint newPointPositionPressed = CGPointMake(pointPositionPressed.x - self.pointPositionInCell.x, pointPositionPressed.y - self.pointPositionInCell.y);
    
    self.draggedCellData.draggedCell.frame = CGRectMake(newPointPositionPressed.x, newPointPositionPressed.y, self.draggedCellData.draggedCell.frame.size.width, self.draggedCellData.draggedCell.frame.size.height);
}

- (void)checkIntersectionWhileStateChanged:(UILongPressGestureRecognizer *)sender
                                pointPress:(CGPoint)pointPositionPressed {

    UIView *windowView = [self getWindowView];
    
    // check intersections
    [self.tableDataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        DLTableData *tableData = (DLTableData *)obj;
        UITableView *tableView = tableData.tableView;

        // before checking intersection validate if it can intersect with this table
        DLTableData *tableDataOrigin = self.tableDataArray[self.draggedCellData.selectedIndexOfList];
        
        // if intersectTables doesn´t contain the tableName don´t intersect
        if (![tableDataOrigin.intersectTables containsObject:tableData.tableName]) {
            
            return;
        }

        CGRect selectedTableViewRect = [windowView convertRect:tableView.frame
                                                      fromView:tableView.superview];
        
        // check if the point pressed is inside a tableView
        if (CGRectContainsPoint(selectedTableViewRect, pointPositionPressed)) {

            // check if entered in a new tableView directly from another tableView
            // if it does it should delete the previous placeholder cell
            if(self.placeHolderCellData
               && idx != self.placeHolderCellData.selectedIndexOfList) {
                
                [self deleteRowAt:self.placeHolderCellData.selectedIndexPathInsideList
                       tableIndex:self.placeHolderCellData.selectedIndexOfList];
                
                [self clearPlaceholderCell];
            }

            // get point in tableView where dragged cell is on top to find the indexPath
            CGPoint pointPositionInTableView = [sender locationInView:tableView];
            NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:pointPositionInTableView];
            
            // in case of datasource empty make first indexPath to zero
//            if (tableData.datasource.count == 0) {
//                
//                indexPath = [NSIndexPath indexPathForRow:0
//                                               inSection:0];
//            }
            
            if(!indexPath && !self.placeHolderCellData) {
             
                indexPath = [NSIndexPath indexPathForRow:tableData.datasource.count
                                               inSection:0];
            }

            if(indexPath) {
                
                if (!self.placeHolderCellData) {
                    
                    self.placeHolderCellData = [[DLPlaceholderCellData alloc] initWithSelectedIndexOfList:idx
                                                                              selectedIndexPathInsideList:indexPath
                                                                                                     item:[NSNull null]];
                    
                    [self insertRowAt:indexPath
                           tableIndex:idx
                                 item:self.configuration.showEmptyCellOnDrag ? [NSNull null] : self.draggedCellData.draggedItem];
                    
                } else if ([self.placeHolderCellData.selectedIndexPathInsideList compare:indexPath] != NSOrderedSame) {
                    
                    //move placeholder row
                    [self moveRowFromIndex:self.placeHolderCellData.selectedIndexPathInsideList
                                   toIndex:indexPath
                                tableIndex:idx];
                    
                    self.placeHolderCellData.selectedIndexPathInsideList = indexPath;
                }
            }
            
            // Check if cell is near the bottom of table to scroll
            CGRect cellFrame = [tableView rectForRowAtIndexPath:indexPath];
            if (pointPositionPressed.y > (selectedTableViewRect.origin.y + selectedTableViewRect.size.height - cellFrame.size.height) ) {

                if (!self.timer) {
                    
                    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.configuration.scrollDurationInSeconds
                                                                  target:self
                                                                selector:@selector(scrollDown:)
                                                                userInfo:@{
                                                                           @"tableView"           : tableView,
                                                                           @"sender"              : sender,
                                                                           @"pointPositionPressed": [NSValue valueWithCGPoint:pointPositionPressed]
                                                                           }
                                                                 repeats:YES];
                }
                
            } else if (pointPositionPressed.y < (selectedTableViewRect.origin.y + cellFrame.size.height)) {

                if (!self.timer) {

                    if (tableView.contentOffset.y != 0) {
                        
                        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.configuration.scrollDurationInSeconds
                                                                      target:self
                                                                    selector:@selector(scrollUp:)
                                                                    userInfo:@{
                                                                               @"tableView"           : tableView,
                                                                               @"sender"              : sender,
                                                                               @"pointPositionPressed": [NSValue valueWithCGPoint:pointPositionPressed]
                                                                               }
                                                                     repeats:YES];
                    }
                }
            
            } else {
               
                [self resetTimer];
            }
            
            *stop = YES;
            
        } else if (self.placeHolderCellData
                   && self.placeHolderCellData.selectedIndexOfList == idx) {

            [self deleteRowAt:self.placeHolderCellData.selectedIndexPathInsideList
                   tableIndex:idx];
            
            [self clearPlaceholderCell];
            
            [self resetTimer];
            
            *stop = YES;
        }
    }];
}

- (void)checkIntersectionWhenStateEnded:(UILongPressGestureRecognizer *)sender {
    
    // check if there is a draggedCell
    if (self.draggedCellData.draggedCell) {
        
        if (self.placeHolderCellData) {
            
            // reposition cell to new location
            [self repositionCellToNewLocation];

        } else {
            
            // return cell to initial location
            [self repositionCellToOriginalLocation];
        }
    }
}

- (void)repositionCellToOriginalLocation {
    
    [UIView animateWithDuration:self.configuration.repositionDurationInSeconds
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
        
        self.draggedCellData.draggedCell.frame = CGRectMake(self.pointPositionOriginPressed.x, self.pointPositionOriginPressed.y, self.draggedCellData.draggedCell.frame.size.width, self.draggedCellData.draggedCell.frame.size.height);
        
    } completion:^(BOOL finished) {
        
        // update datasource and UI of selected table
        [self insertRowAt:self.draggedCellData.selectedIndexPathInsideList
               tableIndex:self.draggedCellData.selectedIndexOfList
                     item:self.draggedCellData.draggedItem];
        
        //clear draggedCellData
        [self clearDraggedCell];
    }];
}

- (void)repositionCellToNewLocation {
    
    NSInteger indexOfList = self.placeHolderCellData.selectedIndexOfList;
    
    UITableView *tableView = [self getTableView:indexOfList];
    NSMutableArray *updatedDatasource = [NSMutableArray arrayWithArray:[self getDataSource:indexOfList]];
    id <DragNDropDelegate> delegate = [self getDelegate:indexOfList];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:self.placeHolderCellData.selectedIndexPathInsideList];
    CGRect cellViewRect = [[self getWindowView] convertRect:cell.frame fromView:cell.superview];
    
    // animation
    [UIView animateWithDuration:self.configuration.repositionDurationInSeconds
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{

        self.draggedCellData.draggedCell.frame = CGRectMake(cellViewRect.origin.x, cellViewRect.origin.y, cellViewRect.size.width, cellViewRect.size.height);
        
    } completion:^(BOOL finished) {
        
        if ([delegate respondsToSelector:@selector(didUpdateDatasource:tableView:)]) {
            
            // update datasource and UI of selected table
            [updatedDatasource replaceObjectAtIndex:self.placeHolderCellData.selectedIndexPathInsideList.row
                                         withObject:self.draggedCellData.draggedItem];

            [delegate didUpdateDatasource:updatedDatasource
                                tableView:tableView];
            
            // update local dataSourceArray
            DLTableData *tableData = self.tableDataArray[self.placeHolderCellData.selectedIndexOfList];
            tableData.datasource = updatedDatasource;
            
            [tableView reloadData];
            
            [self clearDraggedCell];
            
            [self clearPlaceholderCell];
        }
    }];
}

#pragma mark - TableView UI and datasource updates

- (void)deleteRowAt:(NSIndexPath *)indexPath
         tableIndex:(NSInteger)tableIndex {
    
    UITableView *tableView = [self getTableView:tableIndex];
    id <DragNDropDelegate> delegate = [self getDelegate:tableIndex];
    
    if ([delegate respondsToSelector:@selector(didUpdateDatasource:tableView:)]) {
    
        NSMutableArray *updatedDatasource = [NSMutableArray arrayWithArray:[self getDataSource:tableIndex]];

        // remove from data source array and notify delegate of new data source
        if (indexPath.row < updatedDatasource.count) {
            
            [updatedDatasource removeObjectAtIndex:indexPath.row];
        }

        [delegate didUpdateDatasource:updatedDatasource
                            tableView:tableView];
        
        // update local dataSourceArray
        DLTableData *tableData = self.tableDataArray[tableIndex];
        tableData.datasource = updatedDatasource;
        
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath]
                                 withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView endUpdates];
    }
}

- (void)insertRowAt:(NSIndexPath *)indexPath
         tableIndex:(NSInteger)tableIndex
               item:(id)item {

    UITableView *tableView = [self getTableView:tableIndex];
    id <DragNDropDelegate> delegate = [self getDelegate:tableIndex];
    
    if ([delegate respondsToSelector:@selector(didUpdateDatasource:tableView:)]) {
        
        NSMutableArray *updatedDatasource = [NSMutableArray arrayWithArray:[self getDataSource:tableIndex]];
        
        // insert item to updated datasource array and notify delegate of of new data source
        [updatedDatasource insertObject:item
                                atIndex:indexPath.row];

        [delegate didUpdateDatasource:updatedDatasource
                            tableView:tableView];
        
        // update local dataSourceArray
        DLTableData *tableData = self.tableDataArray[tableIndex];
        tableData.datasource = updatedDatasource;

        [tableView beginUpdates];
        [tableView insertRowsAtIndexPaths:@[indexPath]
                         withRowAnimation:UITableViewRowAnimationNone];
        [tableView endUpdates];
    }
}

- (void)moveRowFromIndex:(NSIndexPath *)fromIndexPath
                 toIndex:(NSIndexPath *)toIndexPath
              tableIndex:(NSInteger)tableIndex {
    
    UITableView *tableView = [self getTableView:tableIndex];
    id <DragNDropDelegate> delegate = [self getDelegate:tableIndex];
    
    if ([delegate respondsToSelector:@selector(didUpdateDatasource:tableView:)]) {
        
        NSMutableArray *updatedDatasource = [NSMutableArray arrayWithArray:[self getDataSource:tableIndex]];
        
        [updatedDatasource moveObjectAtIndex:fromIndexPath.row toIndex:toIndexPath.row];
        
        [delegate didUpdateDatasource:updatedDatasource
                            tableView:tableView];
        
        // update local dataSourceArray
        DLTableData *tableData = self.tableDataArray[tableIndex];
        tableData.datasource = updatedDatasource;
        
        [tableView moveRowAtIndexPath:fromIndexPath
                          toIndexPath:toIndexPath];
    }
}

#pragma mark - Device orientation notifications

- (void)orientationChanged:(NSNotification *)note {

    // Cancel dradNDrop on orientation change
    if (self.draggedCellData.draggedCell) {
        
        [self insertRowAt:self.draggedCellData.selectedIndexPathInsideList
               tableIndex:self.draggedCellData.selectedIndexOfList
                     item:self.draggedCellData.draggedItem];
        [self clearDraggedCell];
        
        if (self.placeHolderCellData) {
            
            [self deleteRowAt:self.placeHolderCellData.selectedIndexPathInsideList
                   tableIndex:self.placeHolderCellData.selectedIndexOfList];
            
            [self clearPlaceholderCell];
        }
    }
}

@end