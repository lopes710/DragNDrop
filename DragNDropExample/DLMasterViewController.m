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

@interface DLMasterViewController () <UITableViewDelegate, UITableViewDataSource, DragNDropDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tablePlayers;
@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation DLMasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.tablePlayers registerNib:[UINib nibWithNibName:NSStringFromClass([DLMasterTableViewCell class]) bundle:nil]
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
                                    @"Player AA",
                                    @"Player BB",
                                    @"Player CC",
                                    @"Player DD",
                                    @"Player EE",
                                    @"Player FF",
                                    @"Player GG",
                                    @"Player HH",
                                    @"Player II",
                                    @"Player JJ",
                                    @"Player KK",
                                    @"Player LL"
                                    ];
    
    self.tablePlayers.dataSource = self;
    self.tablePlayers.delegate = self;
    
    [[DragNDrop sharedManager] addTable:self.tablePlayers
                             dataSource:self.dataSource
                               delegate:self
                              tableName:@"tablePlayers"
                     canIntersectTables:@[
                                          @"tablePlay"
                                          ]];
    
//    [DragNDrop sharedManager].configuration.showEmptyCellOnHovering = NO;
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
    
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [[DragNDrop sharedManager] configureSelectionOfCell:cell];

    // TODO: how to force this validation in the side of the user ??
    if (self.dataSource[indexPath.row] == (id)[NSNull null]) {
        
        // TODO: reset CELL how to for this in the user side ??
        cell.playerLabel.text = @"aaaa";
        
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
