//
//  DLMasterViewController.m
//  DragNDropExample
//
//  Created by Duarte Lopes on 31/07/15.
//  Copyright (c) 2015 Duarte Lopes. All rights reserved.
//

#import "DLMasterViewController.h"
#import "DragNDrop.h"

@interface DLMasterViewController () <UITableViewDelegate, UITableViewDataSource, DragNDropDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableStores;
@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation DLMasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.dataSource = @[
                                    @"Store A",
                                    @"Store B",
                                    @"Store C",
                                    @"Store D",
                                    @"Store E",
                                    @"Store F",
                                    @"Store G",
                                    @"Store H",
                                    @"Store I",
                                    @"Store J",
                                    @"Store K",
                                    @"Store L",
                                    @"Store M",
                                    @"Store N",
                                    @"Store O",
                                    @"Store P",
                                    @"Store Q",
                                    @"Store R",
                                    @"Store S",
                                    @"Store T",
                                    @"Store U",
                                    @"Store V",
                                    @"Store X",
                                    @"Store Z",
                                    @"Store AA",
                                    @"Store BB",
                                    @"Store CC",
                                    @"Store DD",
                                    @"Store EE",
                                    @"Store FF",
                                    @"Store GG",
                                    @"Store HH",
                                    @"Store II",
                                    @"Store JJ",
                                    @"Store KK",
                                    @"Store LL"
                                    ];
    
    self.tableStores.dataSource = self;
    self.tableStores.delegate = self;
    
    [[DragNDrop sharedManager] addTable:self.tableStores
                             dataSource:self.dataSource
                               delegate:self
                              tableName:@"tableStores"
                     canIntersectTables:@[
                                          ]];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    
    return self.dataSource.count;

}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    cell = [self.tableStores dequeueReusableCellWithIdentifier:@"CellStore"];
    
    if (cell == nil) {
        
        //create new cell
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"CellStore"];
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

- (void)didUpdateDatasource:(NSMutableArray *)datasource tableView:(UITableView *)tableView {
    
    self.dataSource = datasource;
}

@end
