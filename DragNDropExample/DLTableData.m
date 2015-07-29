//
//  DLTableData.m
//  DragNDropExample
//
//  Created by Duarte Lopes on 28/07/15.
//  Copyright (c) 2015 Duarte Lopes. All rights reserved.
//

#import "DLTableData.h"

@interface DLTableData ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) id <DragNDropDelegate> delegate;
@property (nonatomic, strong) NSString *tableName;
@property (nonatomic, strong) NSArray *intersectTables;

@end

@implementation DLTableData

#pragma mark - Lifecycle

- (instancetype)initTable:(UITableView *)tableView
               dataSource:(NSArray *)datasource
                 delegate:(id)delegate
                tableName:(NSString *)tableName
       canIntersectTables:(NSArray *)intersectTables {
    
    self = [super init];
    
    if (self) {
        
        _tableView = tableView;
        _datasource = [NSMutableArray arrayWithArray:datasource];
        _delegate = delegate;
        _tableName = tableName;
        _intersectTables = intersectTables;
    }
    
    return self;
}

@end
