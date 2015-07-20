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
@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;
@property (nonatomic, strong) UITableView *selectedTableView;
//@property (nonatomic, strong) UITableViewCell *selectedCell;
@property (nonatomic, strong) UIImageView *selectedCell;
@property (nonatomic) CGPoint pointPositionInCell;

@end

@implementation DragNDrop

- (instancetype)init {

    self = [super init];
    
    if (self) {
        
        _tablesArray = [NSMutableArray array];
        _dataSourceArray = [NSMutableArray array];
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

- (void)addTable:(UITableView *)tableView withDatasSource:(NSArray *)datasource {

    [self.tablesArray addObject:tableView];
    
    //change NSarray to NSMutableArray
    [self.dataSourceArray addObject:datasource];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    longPress.minimumPressDuration = 0.2f;
    [tableView addGestureRecognizer:longPress];
}

#pragma mark - private methods

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
    for (UITableView *tableView in self.tablesArray) {
        
        if (sender.view == tableView) {
            
            self.selectedTableView = tableView;
        }
    }
    
    // get point in tableView to find the indexPath of selected cell
    CGPoint pointPositionInTableView = [sender locationInView:self.selectedTableView];
    NSIndexPath *indexPath = [self.selectedTableView indexPathForRowAtPoint:pointPositionInTableView];
    
    if (indexPath) {
        
        // create image representation of cell
        UITableViewCell *cell = [self.selectedTableView cellForRowAtIndexPath:indexPath];
        self.selectedCell = [[UIImageView alloc] initWithFrame:cell.frame];
        
//        self.selectedCell = [self.selectedTableView cellForRowAtIndexPath:indexPath];
        
        UIGraphicsBeginImageContext(cell.bounds.size);
        [cell.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *imageCell = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
//        [self.selectedCell.contentView addSubview:[[UIImageView alloc] initWithImage:imageCell]];
        
        UIImageView *testImage = [[UIImageView alloc] initWithImage:imageCell];
        
//        self.selectedCell = [[UIImageView alloc] initWithImage:imageCell];
        
        [self.selectedCell addSubview:testImage];
        self.selectedCell.layer.borderColor = [UIColor redColor].CGColor;
        self.selectedCell.layer.borderWidth = 2.0;
        
        
        
//        [self.selectedTableView addSubview:testImage];

        
        
        // antigo
//        self.selectedCell = [self.selectedTableView cellForRowAtIndexPath:indexPath];
        
        // get point in selectedCell to reposition the copied cell to the correct place
//        self.pointPositionInCell = [sender locationInView:self.selectedCell];
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
    
    NSMutableArray *dataSource = [NSMutableArray arrayWithArray:self.dataSourceArray[1]];
    [dataSource removeObjectAtIndex:indexPath.row];
    
    [self.delegate didDragOutside:dataSource];
    
//    NSArray *dataSourceReordered = [NSArray arrayWithArray:dataSource];
    
    // save the original dataSource in case the cell gets back to it´s place?
    self.dataSourceArray[1] = dataSource;
    
    [self.selectedTableView beginUpdates];
    [self.selectedTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.selectedTableView endUpdates];
    
//    if ([self getCurrentCalendarType] == RBCalendarDetailDay) {
//        [[self getDayTableView] beginUpdates];
//        [[self getDayTableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//        [[self getDayTableView] endUpdates];
//        
//        [self setCorrectOrderForDayCells];
//    }
//    else if ([self getCurrentCalendarType] == RBCalendarDetailWeek) {
//        UITableView *selectedWeekTable = [self getWeekTableViews][sourceIndex];
//        
//        [selectedWeekTable beginUpdates];
//        [selectedWeekTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//        [selectedWeekTable endUpdates];
//        
//        [self setCorrectCellsStylesForWeekCellsAtSourceIndex:sourceIndex];
//    }
}





// TODO: should be the cell copied or do I use the right one directly??
//        UIImage *aCellImage;
//        [selectedTable cellForRowAtIndexPath:indexPath];
//        NSIndexPath *indexPath = [selectedTable indexPathForRowAtPoint:[sender locationInView:selectedTable]];
//        if (!indexPath) {
//            return;
//        }

//        aCellImage = copyCell.fkit_imageRepresentation;

//        UIGraphicsBeginImageContext(view.bounds.size);
//        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
//        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();

@end
