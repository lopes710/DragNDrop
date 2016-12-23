//
//  DLDetailViewController.m
//  DragNDropExample
//
//  Created by Duarte Lopes on 31/07/15.
//  Copyright (c) 2015 Duarte Lopes. All rights reserved.
//

#import "DLDetailViewController.h"
#import "DragNDrop.h"

static NSString * const DLTablePlay = @"tablePlay";
static NSString * const DLTablePlayers = @"tablePlayers";
static NSString * const DLCellGame = @"CellGame";

@interface DLDetailViewController () <UITableViewDelegate, UITableViewDataSource, DragNDropDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tablePlay;
@property (nonatomic, copy) NSArray *dataSource;

@end

@implementation DLDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.dataSource = @[
                        @"Game 1",
                        @"Game 2",
                        @"Game 3",
                        @"Game 4",
                        @"Game 5",
                        @"Game 6",
                        @"Game 7",
                        @"Game 8",
                        @"Game 9",
                        @"Game 10",
                        @"Game 11",
                        @"Game 12",
                        @"Game 13",
                        @"Game 14",
                        @"Game 15",
                        @"Game 16",
                        @"Game 17",
                        @"Game 18",
                        @"Game 19",
                        @"Game 20"
                        ];
    
    self.tablePlay.dataSource = self;
    self.tablePlay.delegate = self;
    
    [[DragNDrop sharedManager] addTable:self.tablePlay
                             dataSource:self.dataSource
                               delegate:self
                              tableName:DLTablePlay
                     canIntersectTables:@[
                                          DLTablePlayers,
                                          DLTablePlay
                                          ]];
    
    [DragNDrop sharedManager].configuration.showEmptyCellOnHovering = NO;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    
    return self.dataSource.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    cell = [self.tablePlay dequeueReusableCellWithIdentifier:DLCellGame];
    
    if (cell == nil) {
        
        //create new cell
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:DLCellGame];
    }
    
    [[DragNDrop sharedManager] configureSelectionOfCell:cell];
    
    if (self.dataSource[indexPath.row] == (id)[NSNull null]) {
        
        // Reset CELL
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
