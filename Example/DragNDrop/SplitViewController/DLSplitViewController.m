//
//  DLSplitViewController.m
//  DragNDropExample
//
//  Created by Duarte Lopes on 31/07/15.
//  Copyright (c) 2015 Duarte Lopes. All rights reserved.
//

#import "DLSplitViewController.h"
#import "DLMasterViewController.h"
#import "DLDetailViewController.h"

@implementation DLSplitViewController

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
        DLMasterViewController *masterViewController = [[DLMasterViewController alloc] initWithNibName:@"DLMasterViewController"
                                                                                                bundle:nil];
        UINavigationController *masterNavigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
        
        DLDetailViewController *detailViewController = [[DLDetailViewController alloc] initWithNibName:@"DLDetailViewController"
                                                                                                bundle:nil];
        UINavigationController *detailNavigationController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
        
        self.viewControllers = @[masterNavigationController, detailNavigationController];
        
        self.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
    }
    
    return self;
}

//- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
//
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    
//    if (self) {
//        
//        DLMasterViewController *masterViewController = [[DLMasterViewController alloc] initWithNibName:@"DLMasterViewController"
//                                                                                                bundle:nil];
//        UINavigationController *masterNavigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
//        
//        DLDetailViewController *detailViewController = [[DLDetailViewController alloc] initWithNibName:@"DLDetailViewController"
//                                                                                                bundle:nil];
//        UINavigationController *detailNavigationController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
//
//        self.viewControllers = @[masterNavigationController, detailNavigationController];
//        
//        self.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
//    }
//    
//    return self;
//}

@end
