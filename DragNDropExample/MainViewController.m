//
//  MainViewController.m
//  DragNDropExample
//
//  Created by Duarte Lopes on 02/06/15.
//  Copyright (c) 2015 Duarte Lopes. All rights reserved.
//

#import "MainViewController.h"
#import "DragNDrop.h"

@interface MainViewController () <UITableViewDelegate, UITableViewDataSource, DragNDropDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableLetters;
@property (nonatomic, weak) IBOutlet UITableView *tableNumbers;

@property (nonatomic, strong) NSArray *tableLettersDataSource;
@property (nonatomic, strong) NSArray *tableNumbersDataSource;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.tableLettersDataSource = @[
                                @"A",
                                @"B",
                                @"C",
                                @"D",
                                @"E",
                                @"F",
                                @"G",
                                @"H",
                                @"I",
                                @"J",
                                @"K",
                                @"L",
                                ];
    
    self.tableLetters.dataSource = self;
    self.tableLetters.delegate = self;
    
    self.tableNumbersDataSource = @[
                                @"1",
                                @"2",
                                @"3",
                                @"4",
                                @"5",
                                @"6",
                                @"7",
                                @"8",
                                @"9",
                                @"10",
                                @"11",
                                @"12",
                                @"13",
                                @"14",
                                ];
    
    self.tableNumbers.dataSource = self;
    self.tableNumbers.delegate = self;
    
    [[DragNDrop sharedManager] addTable:self.tableLetters
                             dataSource:self.tableLettersDataSource
                               delegate:self
                     canMoveInsideTable:YES];
    
    [[DragNDrop sharedManager] addTable:self.tableNumbers
                             dataSource:self.tableNumbersDataSource
                               delegate:self
                     canMoveInsideTable:NO];
    
    //    [DragNDrop sharedManager].configuration.animationDurationInSeconds = 1.0;
    //    [DragNDrop sharedManager].configuration.canMoveCellWithinTable = NO;
    
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {

    if(tableView == self.tableLetters) {
        
        return self.tableLettersDataSource.count;
        
    } else {
    
        return self.tableNumbersDataSource.count;
        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    if(tableView == self.tableLetters) {
        
        cell = [self.tableLetters dequeueReusableCellWithIdentifier:@"CellLetters"];
        
        
        if (cell == nil) {
            
            //create new cell
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:@"CellLetters"];
        }

        // TODO: how to force this validation in the side of the user ??
        if (self.tableLettersDataSource[indexPath.row] == (id)[NSNull null]) {
            
            // TODO: reset CELL how to for this in the user side ??
            cell.textLabel.text = @"";
            
        } else {

            cell.textLabel.text = self.tableLettersDataSource[indexPath.row];
        }
        
    } else {
        
        cell = [self.tableNumbers dequeueReusableCellWithIdentifier:@"CellNumbers"];
        
        if (cell == nil) {
            
            //create new cell
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:@"CellNumbers"];
        }
        
        // TODO: how to force this validation in the side of the user ??
        if (self.tableNumbersDataSource[indexPath.row] == (id)[NSNull null]) {
            
            // TODO: reset CELL how to for this in the user side ??
            cell.textLabel.text = @"";
            
        } else {
            
            cell.textLabel.text = self.tableNumbersDataSource[indexPath.row];
        }
    }
    
    return cell;
}

#pragma mark - DragNDropDelegate

- (void)didDragOutside:(UITableView *)tableView
     updatedDatasource:(NSMutableArray *)datasource {

    if(tableView == self.tableLetters) {
        
        self.tableLettersDataSource = datasource;
        
    } else {
        
        self.tableNumbersDataSource = datasource;
        
    }
}

- (void)didInsertCellIn:(UITableView *)tableView
      updatedDatasource:(NSMutableArray *)datasource {

    if(tableView == self.tableLetters) {
        
        self.tableLettersDataSource = datasource;
        
    } else {
        
        self.tableNumbersDataSource = datasource;
        
    }
}

@end
