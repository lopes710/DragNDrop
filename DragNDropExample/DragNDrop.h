//
//  DragNDrop.h
//  DragNDropExample
//
//  Created by Duarte Lopes on 03/06/15.
//  Copyright (c) 2015 Duarte Lopes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DLConfiguration.h"

@protocol DragNDropDelegate <NSObject>

- (void)didUpdateDatasource:(NSMutableArray *)datasource tableView:(UITableView *)tableView;

@end

@interface DragNDrop : NSObject <UITableViewDelegate>

@property (nonatomic, strong, readonly) DLConfiguration *configuration;

+ (instancetype)sharedManager;

- (void)addTable:(UITableView *)tableView dataSource:(NSArray *)datasource delegate:(id)delegate tableName:(NSString *)tableName canIntersectTables:(NSArray *)intersectTables;

- (void)configureSelectionOfCell:(UITableViewCell *)cell;

@end
