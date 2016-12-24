# DragNDrop

[![CI Status](http://img.shields.io/travis/Duarte Lopes/DragNDrop.svg?style=flat)](https://travis-ci.org/Duarte Lopes/DragNDrop)
[![Version](https://img.shields.io/cocoapods/v/DragNDrop.svg?style=flat)](http://cocoapods.org/pods/DragNDrop)
[![License](https://img.shields.io/cocoapods/l/DragNDrop.svg?style=flat)](http://cocoapods.org/pods/DragNDrop)
[![Platform](https://img.shields.io/cocoapods/p/DragNDrop.svg?style=flat)](http://cocoapods.org/pods/DragNDrop)

## Purpose

This pod enables an easy and fast way to move around items between tableViews. One can select a cell, drag it on top of another tableView and
drop it.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

Valid for iOS 8 or higher.
To try the test demo run in a iPad or iPad simulator.

## Installation

DragNDrop is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

## How to use it

Simply add the table information in the DragNDrop framework. Example:

    [[DragNDrop sharedManager] addTable:self.table
                             dataSource:self.dataSource
                               delegate:self
                              tableName:@"table A"
                     canIntersectTables:@[
                                            @"Table A",
                                            @"Table B"
                                        ]];

The data source must be an array. One should set a name for each table view and enumerate the other table names that can interact with.
To drag and drop in the same table also add the table name to the canIntersectTables parameter.

To configure some properties of the DragNDrop simply access the configuration property. Example:

    [DragNDrop sharedManager].configuration.showEmptyCellOnHovering = YES;

There are three properties you can configure.
* showEmptyCellOnHovering 
    A boolean to show a standard empty cell when hovering the dragged cell.
* scrollDurationInSeconds 
    The speed of scroll when dragging a cell on top or bottom of a tableView.
* repositionDurationInSeconds 
    The speed of the cell when moving to the new position in the tableView or back to its original position if not dropped in the right position or if the app changed orientation.

  ### Note

  When dropping a cell in a tableView, the data source array for that table is updated with a new item. This means that if this item type is different from the original 
  items in the data source one needs to check this in the delegate method:

    - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

Example:

    if (self.dataSource[indexPath.row] == [ExampleItemTypeClass class]) {
    
        // Pass and set the info needed to the new cell
        ExampleItemTypeClass *exampleItem = self.dataSource[indexPath.row];
        cell.textLabel.text = exampleItem.exampleText;
    }

If the property showEmptyCellOnHovering is set to YES, it´s needed to also recognize an empty cell. This means another conditional.
Example:

    if (self.dataSource[indexPath.row] == (id)[NSNull null]) {

        // Reset CELL as you want, this is for the case when an empty space cell is hovering a tableView. But one can set anything you want.
        cell.textLabel.text = @"";
    }

Any questions please contact me.
Have fun :)

```ruby
pod "DragNDrop"
```

## Author

Duarte Lopes, duarte.lopes85@gmail.com

## License

DragNDrop is available under the MIT license. See the LICENSE file for more info.
