//
//  DLTableData.h
//  DragNDropExample
//
//  Created by Duarte Lopes on 28/07/15.
//  Copyright (c) 2015 Duarte Lopes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DragNDrop.h"

@interface DLTableData : NSObject

@property (nonatomic, strong, readonly) UITableView *tableView;
@property (nonatomic, strong, readwrite) NSMutableArray *datasource;
@property (nonatomic, strong, readonly) id <DragNDropDelegate> delegate;
@property (nonatomic, copy, readonly) NSString *tableName;
@property (nonatomic, copy, readonly) NSArray *intersectTables;

- (instancetype)initTable:(UITableView *)tableView
               dataSource:(NSArray *)datasource
                 delegate:(id)delegate
                tableName:(NSString *)tableName
       canIntersectTables:(NSArray *)intersectTables;

@end
