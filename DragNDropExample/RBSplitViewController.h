//
//  RBSplitViewController.h
//  RedBull_Drive3
//
//  Created by Duarte Lopes on 03/06/13.
//  Copyright (c) 2013 NOUS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RBSplitViewControllerDelegate <NSObject>

-(void)enableSegmentedControl:(BOOL)enabled;

@end

@interface RBSplitViewController : UISplitViewController <UITableViewDelegate>

@property (nonatomic, readonly) NSUInteger indexOfSelectedCell;

@property (nonatomic, readonly) UITableView *selectedDayTableViewOfWeekCalendar;

@property (nonatomic, readonly) UICollectionView *monthCollectionView;

@property (nonatomic, readonly) UIView *intersectedCell;

@property (nonatomic, assign) id<RBSplitViewControllerDelegate> splitDelegate;

@property (nonatomic, readonly) NSInteger originalCopyWeekCellTableTagSaved;

@property (nonatomic, readonly) BOOL inDrag;

- (void)toggleLongPressGestureRecognizer:(BOOL)toggle;
- (void)toggleDragWeekCellWithinWeekCalendar:(BOOL)toggle;

// UI change methods
- (void)moveRowFrom:(NSIndexPath*)fromRow toRow:(NSIndexPath*)toRow inSourceIndex:(NSInteger)index;
- (void)addNewRowTo:(NSIndexPath*)toIndexPath inSourceIndex:(NSInteger)index;
- (void)removeRowIn:(NSIndexPath*)indexPath inSourceIndex:(NSInteger)index;

@end
