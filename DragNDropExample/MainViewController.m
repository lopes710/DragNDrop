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
    
    [[DragNDrop sharedManager] addTable:self.tableLetters withDatasSource:self.tableLettersDataSource];
    [[DragNDrop sharedManager] addTable:self.tableNumbers withDatasSource:self.tableNumbersDataSource];
    DragNDrop *dragNdrop = [DragNDrop sharedManager];
    
    dragNdrop.delegate = self;
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

        cell.textLabel.text = self.tableLettersDataSource[indexPath.row];
        
    } else {
        
        cell = [self.tableNumbers dequeueReusableCellWithIdentifier:@"CellNumbers"];
        
        if (cell == nil) {
            
            //create new cell
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:@"CellNumbers"];
        }
        
        cell.textLabel.text = self.tableNumbersDataSource[indexPath.row];
        
    }
    
    return cell;
}

#pragma mark - DragNDropDelegate

- (void)didDragOutside:(NSMutableArray *)datasource {

    self.tableNumbersDataSource = datasource;
}

@end
