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

@end


/* TODOs:

 1) Add a flag inDrag to not select another cell while animating
 2) optional: Make placeholder empty or with data ?
 3) Add system to know what tables are able to intersect anothers
 4) optional: configuration of draggedCell ?
 5) scroll when drag in top or bottom
 
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
canMoveInsideTable:(BOOL)canMoveInsideTable
       tableName:(NSString *)tableName {
    
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
                                         canMoveInsideTable:canMoveInsideTable
                                                  tableName:tableName];
    
    [self.tableDataArray addObject:tableData];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(longPress:)];
    longPress.minimumPressDuration = 0.2f;
    [tableView addGestureRecognizer:longPress];
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

- (void)checkIntersectionWhileStateChanged:(UILongPressGestureRecognizer *)sender pointPress:(CGPoint)pointPositionPressed {

    UIView *windowView = [self getWindowView];
    
    // check intersections
    [self.tableDataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        DLTableData *tableData = (DLTableData *)obj;
        UITableView *tableView = tableData.tableView;
        
        // validate if it can move inside table
        if (!tableData.canMoveInsideTable && tableView == [self getTableView:self.draggedCellData.selectedIndexOfList]) {
            
            return;
        }
        
        CGRect selectedTableViewRect = [windowView convertRect:tableView.frame fromView:tableView.superview];
        
        // check if the point pressed is inside a tableView
        if (CGRectContainsPoint(selectedTableViewRect, pointPositionPressed)) {

            // check if entered in a new tableView directly from another
            // if it does it should delete the previous placeholder cell
            if(self.placeHolderCellData && idx != self.placeHolderCellData.selectedIndexOfList) {
                
                [self deleteRowAt:self.placeHolderCellData.selectedIndexPathInsideList
                       tableIndex:self.placeHolderCellData.selectedIndexOfList];
                
                [self clearPlaceholderCell];
            }

            // get point in tableView where dragged cell is on top to find the indexPath
            CGPoint pointPositionInTableView = [sender locationInView:tableView];
            NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:pointPositionInTableView];
            
            if(indexPath) {
                
                if (!self.placeHolderCellData) {
                    
                    self.placeHolderCellData = [[DLPlaceholderCellData alloc] initWithSelectedIndexOfList:idx
                                                                              selectedIndexPathInsideList:indexPath
                                                                                                     item:[NSNull null]];
                    
                    [self insertRowAt:indexPath
                           tableIndex:idx
                                 item:[NSNull null]];
                    
                    // TODO: insert blank row TODO: make it an optionBlankCell or with value ??
                    //                        [self insertRowAt:indexPath
                    //                               tableIndex:idx
                    //                                     item:self.draggedCellData.draggedItem];
                    
                } else if ([self.placeHolderCellData.selectedIndexPathInsideList compare:indexPath] != NSOrderedSame) {
                    
                    //move blank row
                    [self moveRowFromIndex:self.placeHolderCellData.selectedIndexPathInsideList
                                   toIndex:indexPath
                                tableIndex:idx];
                    
                    self.placeHolderCellData.selectedIndexPathInsideList = indexPath;
                }
            }
            *stop = YES;
            
        } else if (self.placeHolderCellData && self.placeHolderCellData.selectedIndexOfList == idx) {

            [self deleteRowAt:self.placeHolderCellData.selectedIndexPathInsideList
                   tableIndex:idx];
            
            [self clearPlaceholderCell];
            
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
    
    [UIView animateWithDuration:self.configuration.animationDurationInSeconds delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
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
    [UIView animateWithDuration:self.configuration.animationDurationInSeconds delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{

        self.draggedCellData.draggedCell.frame = CGRectMake(cellViewRect.origin.x, cellViewRect.origin.y, cellViewRect.size.width, cellViewRect.size.height);
        
    } completion:^(BOOL finished) {
        
        // update datasource and UI of selected table
        [updatedDatasource replaceObjectAtIndex:self.placeHolderCellData.selectedIndexPathInsideList.row
                                     withObject:self.draggedCellData.draggedItem];
        
        [delegate didInsertCellIn:tableView
                updatedDatasource:updatedDatasource];
        
        // update local dataSourceArray
        DLTableData *tableData = self.tableDataArray[self.placeHolderCellData.selectedIndexOfList];
        tableData.datasource = updatedDatasource;
        
        [tableView reloadData];
        
        [self clearDraggedCell];
        
        [self clearPlaceholderCell];
    }];
}

#pragma mark - TableView UI and datasource updates

- (void)deleteRowAt:(NSIndexPath *)indexPath
         tableIndex:(NSInteger)tableIndex {
    
    UITableView *tableView = [self getTableView:tableIndex];
    id <DragNDropDelegate> delegate = [self getDelegate:tableIndex];
    
    if ([delegate respondsToSelector:@selector(didDragOutside:updatedDatasource:)]) {
    
        NSMutableArray *updatedDataSource = [NSMutableArray arrayWithArray:[self getDataSource:tableIndex]];

        // remove from data source array and notify delegate of of new data source
        [updatedDataSource removeObjectAtIndex:indexPath.row];
        
        [delegate didDragOutside:tableView
               updatedDatasource:updatedDataSource];
        
        // update local dataSourceArray
        DLTableData *tableData = self.tableDataArray[tableIndex];
        tableData.datasource = updatedDataSource;
        
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
    
    if ([delegate respondsToSelector:@selector(didInsertCellIn:updatedDatasource:)]) {
        
        NSMutableArray *updatedDataSource = [NSMutableArray arrayWithArray:[self getDataSource:tableIndex]];
        
        // insert item to updated datasource array and notify delegate of of new data source
        [updatedDataSource insertObject:item
                                atIndex:indexPath.row];
        
        [delegate didInsertCellIn:tableView
                updatedDatasource:updatedDataSource];
        
        // update local dataSourceArray
        DLTableData *tableData = self.tableDataArray[tableIndex];
        tableData.datasource = updatedDataSource;

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

    // update datasource but notify the delegate just in the state end
    NSMutableArray *datasourceToUpdate = [NSMutableArray arrayWithArray:[self getDataSource:tableIndex]];
    
    [datasourceToUpdate moveObjectAtIndex:fromIndexPath.row toIndex:toIndexPath.row];
    
    // update local dataSourceArray
    DLTableData *tableData = self.tableDataArray[tableIndex];
    tableData.datasource = datasourceToUpdate;
    
    [tableView moveRowAtIndexPath:fromIndexPath
                      toIndexPath:toIndexPath];
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
