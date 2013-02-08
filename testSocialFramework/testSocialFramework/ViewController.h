//
//  ViewController.h
//  testWeibo
//
//  Created by nakano_michiharu on 2013/02/02.
//  Copyright (c) 2013年 nakano_michiharu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>

@interface ViewController : UIViewController
{
	//手の施しようが無くなったフラグ
	BOOL giveUp;
}
@property (retain, nonatomic) IBOutlet UIButton *btnIdEnable;

@property (retain, nonatomic) IBOutlet UIButton *btnIdDisable;

@property (retain, nonatomic) IBOutlet UIButton *btnIdEnableCustom;
@property (retain, nonatomic) IBOutlet UISegmentedControl *segSelectSNS;

- (IBAction)onPushBtn:(id)sender;

@end
