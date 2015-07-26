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

typedef void(^DLCellOnLongPressCompletionBlock)(DLDraggedCellData *draggedCellData);

@interface DragNDrop ()

@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;

@property (nonatomic, strong) NSMutableArray *tablesArray;
@property (nonatomic, strong) NSMutableArray *dataSourceArray;
@property (nonatomic, strong) NSMutableArray *delegatesArray;

// point positions
@property (nonatomic) CGPoint pointPositionOriginPressed;
@property (nonatomic) CGPoint pointPositionInCell;

// dragged cell data
@property (nonatomic, strong) DLDraggedCellData *draggedCellData;
@property (nonatomic, strong) DLPlaceholderCellData *placeHolderCellData;

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
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(longPress:)];
    longPress.minimumPressDuration = 0.2f;
    [tableView addGestureRecognizer:longPress];
}

#pragma mark - GestureRecognizer methods

- (IBAction)longPress:(UILongPressGestureRecognizer *)sender {
    
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
        
    } else if (sender.state == UIGestureRecognizerStateEnded ||
               sender.state == UIGestureRecognizerStateCancelled ||
               sender.state == UIGestureRecognizerStateFailed) {
        
        [self checkIntersectionWhenStateEnded];
    }
}

#pragma mark - Private methods

- (UIView *)getWindowView {

    UIView *windowView = [[[UIApplication sharedApplication] windows] lastObject];
    
    return windowView;
}

- (UITableView *)getTableView:(NSInteger)index {

    return self.tablesArray[index];
}

- (NSArray *)getDataSource:(NSInteger)index {
    
    return self.dataSourceArray[index];
}

- (id)getDelegate:(NSInteger)index {
    
    return self.delegatesArray[index];
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

- (void)updateCellPosition:(CGPoint)pointPositionPressed {

    CGPoint newPointPositionPressed = CGPointMake(pointPositionPressed.x - self.pointPositionInCell.x, pointPositionPressed.y - self.pointPositionInCell.y);
    
    self.draggedCellData.draggedCell.frame = CGRectMake(newPointPositionPressed.x, newPointPositionPressed.y, self.draggedCellData.draggedCell.frame.size.width, self.draggedCellData.draggedCell.frame.size.height);
}

- (void)checkIntersectionWhileStateChanged:(UILongPressGestureRecognizer *)sender pointPress:(CGPoint)pointPositionPressed {

    UIView *windowView = [self getWindowView];
    
    //  check intersections
    [self.tablesArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        UITableView *tableView = (UITableView *)obj;
        
        if(tableView != [self getTableView:self.draggedCellData.selectedIndexOfList]) {
            
            CGRect selectedTableViewRect = [windowView convertRect:tableView.frame fromView:tableView.superview];
            
            if (CGRectContainsPoint(selectedTableViewRect, pointPositionPressed)) {
                
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
                
            } else if (self.placeHolderCellData) {
                
                [self deleteRowAt:self.placeHolderCellData.selectedIndexPathInsideList
                       tableIndex:idx];
                self.placeHolderCellData = nil;
            }
            
        } else {
            
            // TODO: it´s the same table - enable move
        }
    }];
}

- (void)checkIntersectionWhenStateEnded {
    
    // check if there is a draggedCell
    if (self.draggedCellData.draggedCell) {
        
        if (self.placeHolderCellData) {
            
            NSInteger indexOfList = self.placeHolderCellData.selectedIndexOfList;
            
            UITableView *tableView = [self getTableView:indexOfList];
            NSMutableArray *updatedDatasource = [NSMutableArray arrayWithArray:[self getDataSource:indexOfList]];
            id <DragNDropDelegate> delegate = [self getDelegate:indexOfList];
            
            [updatedDatasource replaceObjectAtIndex:self.placeHolderCellData.selectedIndexPathInsideList.row
                                          withObject:self.draggedCellData.draggedItem];
            
            [delegate didInsertCellIn:tableView
                    updatedDatasource:updatedDatasource];
            
            // update local dataSourceArray
            self.dataSourceArray[ self.placeHolderCellData.selectedIndexOfList] = updatedDatasource;
            [tableView reloadData];

            //clear draggedCellData
            self.draggedCellData = nil;
            
            //clear placeHolderCellData
            self.placeHolderCellData = nil;
            
        } else {
            
            //return cell to initial location
            [self repositionCellToOriginalLocation];
        }
    }
}

- (void)repositionCellToOriginalLocation {

    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.draggedCellData.draggedCell.frame = CGRectMake(self.pointPositionOriginPressed.x, self.pointPositionOriginPressed.y, self.draggedCellData.draggedCell.frame.size.width, self.draggedCellData.draggedCell.frame.size.height);
        
    } completion:^(BOOL finished) {
        
        // update datasource and UI of selected table
        [self insertRowAt:self.draggedCellData.selectedIndexPathInsideList
               tableIndex:self.draggedCellData.selectedIndexOfList
                     item:self.draggedCellData.draggedItem];
        
        //clear draggedCellData
        self.draggedCellData = nil;
        
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
        self.dataSourceArray[tableIndex] = updatedDataSource;
        
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
        self.dataSourceArray[tableIndex] = updatedDataSource;

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
    
    // TODO: Make it a category ??
    id object = datasourceToUpdate[fromIndexPath.row];
    [datasourceToUpdate removeObjectAtIndex:fromIndexPath.row];
    [datasourceToUpdate insertObject:object atIndex:toIndexPath.row];
    
    // update local dataSourceArray
    self.dataSourceArray[tableIndex] = datasourceToUpdate;
    
    [tableView moveRowAtIndexPath:fromIndexPath
                      toIndexPath:toIndexPath];
}

@end
