//
//  NSMutableArray+Actions.h
//  DragNDropExample
//
//  Created by Duarte Lopes on 26/07/15.
//  Copyright (c) 2015 Duarte Lopes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (Actions)

- (void)moveObjectAtIndex:(NSUInteger)fromIndex
                  toIndex:(NSUInteger)toIndex;

@end

