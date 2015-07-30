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
    
    self.edgesForExtendedLayout=UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars=NO;
    self.automaticallyAdjustsScrollViewInsets=NO;
    
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
                                @"15",
                                @"16",
                                @"17",
                                @"18",
                                @"19",
                                @"20",
                                @"21",
                                @"22",
                                @"23",
                                @"24",
                                @"25",
                                @"26",
                                @"27",
                                @"28",
                                @"29",
                                @"30",
                                @"31",
                                @"32",
                                @"33",
                                @"34",
                                @"35",
                                @"36",
                                @"37",
                                @"38",
                                @"39",
                                @"40"
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
                                       @"PT2",
                                       @"GB2",
                                       @"ES2",
                                       @"FR2",
                                       @"DE2",
                                       @"IT2",
                                       @"CZ2",
                                       @"RS2",
                                       @"HU2",
                                       @"LT2",
                                       @"ET2",
                                       @"SE2",
                                       @"GR2",
                                       @"TK2",
                                       @"PT3",
                                       @"GB3",
                                       @"ES3",
                                       @"FR3",
                                       @"DE3",
                                       @"IT3",
                                       @"CZ3",
                                       @"RS3",
                                       @"HU3",
                                       @"LT3",
                                       @"ET3",
                                       @"SE3",
                                       @"GR3",
                                       @"TK3"
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
                     canIntersectTables:@[@"tableNumbers"]];
    
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
//    [DragNDrop sharedManager].configuration.scrollDurationInSeconds = 0.03;
    
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

- (void)didUpdateDatasource:(NSMutableArray *)datasource tableView:(UITableView *)tableView {

    if(tableView == self.tableLetters) {
        
        self.tableLettersDataSource = datasource;
        
    } else if(tableView == self.tableNumbers) {
        
        self.tableNumbersDataSource = datasource;
        
    } else {
        
        self.tableCharactersDataSource = datasource;
    }
}
@end
