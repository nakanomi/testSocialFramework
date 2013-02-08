//
//  SelectAccountViewController.h
//  smarRoom001
//
//  Created by nakano_michiharu on 12/05/13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>

enum {
	SELSNS_NO_SELECT = 0,
	SELSNS_TWITTER,
	SELSNS_WEIBO,
};



@interface SelectAccountViewController : UITableViewController<UIAlertViewDelegate>
{
	NSMutableArray *arrayName;
	NSMutableDictionary *dictAccount;
	UIActivityIndicatorView *activityView;
	
	NSString *strAccountType;
}

- (void)setAccountTypeString:(NSString*)str;
+ (int)getOSVerOfMajor:(BOOL)major;
+ (BOOL)isAbleToTrySNS:(NSString*)strServiceType;
+ (NSString*)getServiceTypeStringOf:(int)indexSNS;
+ (NSString*)getAccountTypeStringOf:(int)indexSNS;
+ (NSString*)getSNSNameStringOf:(int)indexSNS;


@end
