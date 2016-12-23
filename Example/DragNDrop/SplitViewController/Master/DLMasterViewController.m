//
//  DLMasterViewController.m
//  DragNDropExample
//
//  Created by Duarte Lopes on 31/07/15.
//  Copyright (c) 2015 Duarte Lopes. All rights reserved.
//

#import "DLMasterViewController.h"
#import "DragNDrop.h"
#import "DLMasterTableViewCell.h"

static NSString * const DLTablePlay = @"tablePlay";
static NSString * const DLTablePlayers = @"tablePlayers";

@interface DLMasterViewController () <UITableViewDelegate, UITableViewDataSource, DragNDropDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tablePlayers;
@property (nonatomic, copy) NSArray *dataSource;

@end

@implementation DLMasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.tablePlayers registerNib:[UINib nibWithNibName:NSStringFromClass([DLMasterTableViewCell class])
                                                  bundle:nil]
            forCellReuseIdentifier:NSStringFromClass([DLMasterTableViewCell class])];
    
    self.dataSource = @[
                        @"Player A",
                        @"Player B",
                        @"Player C",
                        @"Player D",
                        @"Player E",
                        @"Player F",
                        @"Player G",
                        @"Player H",
                        @"Player I",
                        @"Player J",
                        @"Player K",
                        @"Player L",
                        @"Player M",
                        @"Player N",
                        @"Player O",
                        @"Player P",
                        @"Player Q",
                        @"Player R",
                        @"Player S",
                        @"Player T",
                        @"Player U",
                        @"Player V",
                        @"Player X",
                        @"Player Z",
                        ];
    
    self.tablePlayers.dataSource = self;
    self.tablePlayers.delegate = self;
    
    [[DragNDrop sharedManager] addTable:self.tablePlayers
                             dataSource:self.dataSource
                               delegate:self
                              tableName:DLTablePlayers
                     canIntersectTables:@[
                                          DLTablePlay,
                                          ]];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    
    return self.dataSource.count;

}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DLMasterTableViewCell *cell;
    
    cell = [self.tablePlayers dequeueReusableCellWithIdentifier:NSStringFromClass([DLMasterTableViewCell class])];
    
    if (cell == nil) {
        
        //create new cell
        cell = [[DLMasterTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:NSStringFromClass([DLMasterTableViewCell class])];
    }
    
    [[DragNDrop sharedManager] configureSelectionOfCell:cell];

    if (self.dataSource[indexPath.row] == (id)[NSNull null]) {
        
        // Reset CELL
        cell.playerLabel.text = @"";
        
    } else {
        
        cell.playerLabel.text = self.dataSource[indexPath.row];
    }
    
    return cell;
}

#pragma mark - DragNDropDelegate

- (void)didUpdateDatasource:(NSMutableArray *)datasource
                  tableView:(UITableView *)tableView {
    
    self.dataSource = datasource;
}

@end
