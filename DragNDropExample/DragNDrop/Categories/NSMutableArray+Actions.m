//
//  NSMutableArray+Actions.m
//  DragNDropExample
//
//  Created by Duarte Lopes on 26/07/15.
//  Copyright (c) 2015 Duarte Lopes. All rights reserved.
//

#import "NSMutableArray+Actions.h"

@implementation NSMutableArray (Actions)

- (void)moveObjectAtIndex:(NSUInteger)fromIndex
                  toIndex:(NSUInteger)toIndex {

    id object = [self objectAtIndex:fromIndex];
    [self removeObjectAtIndex:fromIndex];
    [self insertObject:object atIndex:toIndex];
}

@end