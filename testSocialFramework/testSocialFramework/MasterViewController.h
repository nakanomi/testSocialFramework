//
//  MasterViewController.h
//  testSocialFramework
//
//  Created by nakano_michiharu on 2013/02/08.
//  Copyright (c) 2013年 nakano_michiharu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;

@end
