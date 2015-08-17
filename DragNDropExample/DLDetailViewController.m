//
//  DLDetailViewController.m
//  DragNDropExample
//
//  Created by Duarte Lopes on 31/07/15.
//  Copyright (c) 2015 Duarte Lopes. All rights reserved.
//

#import "DLDetailViewController.h"
#import "DragNDrop.h"

@interface DLDetailViewController () <UITableViewDelegate, UITableViewDataSource, DragNDropDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tablePlay;
@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation DLDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.dataSource = @[
                        /*@"Game A",
                        @"Game B",
                        @"Game C",
                        @"Game D",
                        @"Game E",
                        @"Game F",
                        @"Game G",
                        @"Game H",
                        @"Game I",
                        @"Game J",
                        @"Game K",
                        @"Game L",
                        @"Game M",
                        @"Game N",
                        @"Game O",
                        @"Game P",
                        @"Game Q",
                        @"Game R",
                        @"Game S",
                        @"Game T",
                        @"Game U",
                        @"Game V",
                        @"Game X",
                        @"Game Z",
                        @"Game AA",
                        @"Game BB",
                        @"Game CC",
                        @"Game DD",
                        @"Game EE",
                        @"Game FF",
                        @"Game GG",
                        @"Game HH",
                        @"Game II",
                        @"Game JJ",
                        @"Game KK",
                        @"Game LL"*/
                        ];
    
    self.tablePlay.dataSource = self;
    self.tablePlay.delegate = self;
    
    [[DragNDrop sharedManager] addTable:self.tablePlay
                             dataSource:self.dataSource
                               delegate:self
                              tableName:@"tablePlay"
                     canIntersectTables:@[]];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    
    return self.dataSource.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    cell = [self.tablePlay dequeueReusableCellWithIdentifier:@"CellGame"];
    
    if (cell == nil) {
        
        //create new cell
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"CellGame"];
    }
    
    // TODO: how to force this validation in the side of the user ??
    if (self.dataSource[indexPath.row] == (id)[NSNull null]) {
        
        // TODO: reset CELL how to for this in the user side ??
        cell.textLabel.text = @"";
        
    } else {
        
        cell.textLabel.text = self.dataSource[indexPath.row];
    }
    
    return cell;
}

#pragma mark - DragNDropDelegate

- (void)didUpdateDatasource:(NSMutableArray *)datasource
                  tableView:(UITableView *)tableView {
    
    self.dataSource = datasource;
}

@end