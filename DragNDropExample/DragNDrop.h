//
//  DragNDrop.h
//  DragNDropExample
//
//  Created by Duarte Lopes on 03/06/15.
//  Copyright (c) 2015 Duarte Lopes. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DragNDropDelegate <NSObject>

- (void)didDragOutside:(NSMutableArray *)datasource;

@end

@interface DragNDrop : NSObject <UITableViewDelegate>

@property (nonatomic, strong) id <DragNDropDelegate> delegate;

+ (id)sharedManager;

- (void)addTable:(UITableView *)tableView withDatasSource:(NSArray *)datasource;

@end
