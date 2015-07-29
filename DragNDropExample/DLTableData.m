//
//  DLTableData.m
//  DragNDropExample
//
//  Created by Duarte Lopes on 28/07/15.
//  Copyright (c) 2015 Duarte Lopes. All rights reserved.
//

#import "DLTableData.h"

//@property (nonatomic, strong) NSMutableArray *tablesArray;
//@property (nonatomic, strong) NSMutableArray *dataSourceArray;
//@property (nonatomic, strong) NSMutableArray *delegatesArray;

@interface DLTableData ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) id <DragNDropDelegate> delegate;
@property (nonatomic, strong) NSString *tableName;

@end

@implementation DLTableData

#pragma mark - Lifecycle

- (instancetype)initTable:(UITableView *)tableView
               dataSource:(NSArray *)datasource
                 delegate:(id)delegate
       canMoveInsideTable:(BOOL)canMoveInsideTable
                tableName:(NSString *)tableName {
    
    self = [super init];
    
    if (self) {
        
        _tableView = tableView;
        _datasource = [NSMutableArray arrayWithArray:datasource];
        _delegate = delegate;
        _canMoveInsideTable = canMoveInsideTable;
        _tableName = tableName;
    }
    
    return self;
}

@end
