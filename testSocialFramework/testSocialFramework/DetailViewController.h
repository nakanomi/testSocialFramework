//
//  DetailViewController.h
//  testSocialFramework
//
//  Created by nakano_michiharu on 2013/02/08.
//  Copyright (c) 2013年 nakano_michiharu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end
