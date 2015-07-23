//
//  DragNDrop.h
//  DragNDropExample
//
//  Created by Duarte Lopes on 03/06/15.
//  Copyright (c) 2015 Duarte Lopes. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DragNDropDelegate <NSObject>

- (void)didDragOutside:(UITableView *)tableView updatedDatasource:(NSMutableArray *)datasource;

@end

@interface DragNDrop : NSObject <UITableViewDelegate>

+ (id)sharedManager;

- (void)addTable:(UITableView *)tableView datasSource:(NSArray *)datasource delegate:(id)delegate;

@end
