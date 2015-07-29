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
@property (nonatomic, weak) IBOutlet UITableView *tableCharacters;

@property (nonatomic, strong) NSArray *tableLettersDataSource;
@property (nonatomic, strong) NSArray *tableNumbersDataSource;
@property (nonatomic, strong) NSArray *tableCharactersDataSource;

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
    
    self.tableCharactersDataSource = @[
                                       @"PT",
                                       @"GB",
                                       @"ES",
                                       @"FR",
                                       @"DE",
                                       @"IT",
                                       @"CZ",
                                       @"RS",
                                       @"HU",
                                       @"LT",
                                       @"ET",
                                       @"SE",
                                       @"GR",
                                       @"TK",
                                    ];
    
    self.tableCharacters.dataSource = self;
    self.tableCharacters.delegate = self;
    
    [[DragNDrop sharedManager] addTable:self.tableLetters
                             dataSource:self.tableLettersDataSource
                               delegate:self
                              tableName:@"tableLetters"
                     canIntersectTables:@[
                                          @"tableLetters",
                                          @"tableNumbers",
                                          @"tableCharacters"
                                        ]];
    
    [[DragNDrop sharedManager] addTable:self.tableNumbers
                             dataSource:self.tableNumbersDataSource
                               delegate:self
                              tableName:@"tableNumbers"
                     canIntersectTables:@[]];
    
    [[DragNDrop sharedManager] addTable:self.tableCharacters
                             dataSource:self.tableCharactersDataSource
                               delegate:self
                              tableName:@"tableCharacters"
                     canIntersectTables:@[
                                          @"tableLetters",
                                          @"tableCharacters"
                                          ]];
    
    
    self.tableLetters.layer.borderColor = [UIColor redColor].CGColor;
    self.tableLetters.layer.borderWidth = 2.0;
    
    self.tableNumbers.layer.borderColor = [UIColor greenColor].CGColor;
    self.tableNumbers.layer.borderWidth = 2.0;
    
    self.tableCharacters.layer.borderColor = [UIColor blueColor].CGColor;
    self.tableCharacters.layer.borderWidth = 2.0;
    
    //    [DragNDrop sharedManager].configuration.animationDurationInSeconds = 1.0;
    //    [DragNDrop sharedManager].configuration.canMoveCellWithinTable = NO;
    
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {

    if(tableView == self.tableLetters) {
        
        return self.tableLettersDataSource.count;
        
    } else if(tableView == self.tableNumbers) {
        
        return self.tableNumbersDataSource.count;
    
    } else {
    
        return self.tableCharactersDataSource.count;
        
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
        
    } else if(tableView == self.tableNumbers) {
        
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
        
    } else {
    
        cell = [self.tableCharacters dequeueReusableCellWithIdentifier:@"CellCharacters"];
        
        if (cell == nil) {
            
            //create new cell
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:@"CellCharacters"];
        }
        
        // TODO: how to force this validation in the side of the user ??
        if (self.tableCharactersDataSource[indexPath.row] == (id)[NSNull null]) {
            
            // TODO: reset CELL how to for this in the user side ??
            cell.textLabel.text = @"";
            
        } else {
            
            cell.textLabel.text = self.tableCharactersDataSource[indexPath.row];
        }
    }
    
    return cell;
}

#pragma mark - DragNDropDelegate

- (void)didDragOutside:(UITableView *)tableView
     updatedDatasource:(NSMutableArray *)datasource {

    if(tableView == self.tableLetters) {
        
        self.tableLettersDataSource = datasource;
        
    } else if(tableView == self.tableNumbers) {
        
        self.tableNumbersDataSource = datasource;
        
    } else {
    
        self.tableCharactersDataSource = datasource;
    }
}

- (void)didInsertCellIn:(UITableView *)tableView
      updatedDatasource:(NSMutableArray *)datasource {

    if(tableView == self.tableLetters) {
        
        self.tableLettersDataSource = datasource;
        
    } else if(tableView == self.tableNumbers) {
        
        self.tableNumbersDataSource = datasource;
        
    } else {
    
        self.tableCharactersDataSource = datasource;
    }
}

@end
