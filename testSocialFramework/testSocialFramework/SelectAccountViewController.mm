//
//  SelectAccountViewController.m
//  smarRoom001
//
//  Created by nakano_michiharu on 12/05/13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SelectAccountViewController.h"
#import "TweetViewController.h"

@interface SelectAccountViewController ()
- (void)onGetAccounts;

@end

enum {
	//OSVER_MAJOR_TWITTER_ENABLE = 5,	//Twitterを利用可能なOSのバージョン
	OSVER_MAJOR_SOCIALFRAMEWORK_ENABLE = 6,	//Social.frameworkを利用可能なOSのバージョン
};


@implementation SelectAccountViewController


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
		arrayName = nil;
		dictAccount = nil;
		activityView = nil;
		strAccountType = nil;
    }
    return self;
}

- (void)dealloc
{
	[arrayName release];
	[dictAccount release];
	//[activityView release];
	[super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[activityView stopAnimating];
	[activityView hidesWhenStopped];
	
	UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:activityView];
	self.navigationItem.rightBarButtonItem = barButton;
	[self.navigationController setNavigationBarHidden:NO];
	[barButton release];
	NSLog(@"rc:%d", [activityView retainCount]);
	[activityView release];
	isSearchedAccount = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	if (!isSearchedAccount) {
		isSearchedAccount = YES;
		ACAccountStore *accountStore = [[ACAccountStore alloc] init];
		
		// Create an account type that ensures Twitter accounts are retrieved.
		ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:strAccountType];
		
		[activityView startAnimating];
		self.title = @"Getting Accounts";
		
		// Request access from the user to use their Twitter accounts.
		[accountStore requestAccessToAccountsWithType:accountType
								withCompletionHandler:^(BOOL granted, NSError *error) {
									if (granted) {
										NSArray *tmpArray = [accountStore accountsWithAccountType:accountType];
										//Get the list of Twitter account
										if (tmpArray.count > 0) {
											dictAccount = [[NSMutableDictionary alloc] init];
											arrayName = [[NSMutableArray alloc] init];
											NSLog(@"%s  %d accounts", __PRETTY_FUNCTION__, tmpArray.count);
											int i;
											for (i =0; i < tmpArray.count; i++) {
												ACAccount *account = [tmpArray objectAtIndex:i];
												NSString *strUserName = [NSString stringWithString:account.username];
												NSString *strID = [NSString stringWithString:account.identifier];
												[dictAccount setObject:strID forKey:strUserName];
												[arrayName addObject:strUserName];
											}
											[self performSelectorOnMainThread:@selector(onGetAccounts)
																   withObject:self
																waitUntilDone:NO];
										}
										else {
											NSString *strAlert = @"アカウントを取得できません";
											NSString *strOk = @"Ok";
											UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@" "
																							message:strAlert
																						   delegate:self
																				  cancelButtonTitle:strOk
																				  otherButtonTitles:nil,
																  nil];
											[alert show];
											[activityView stopAnimating];
										}
										
										
									}
								}
		 ];
	}
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setAccountTypeString:(NSString*)str
{
	strAccountType = [NSString stringWithString:str];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
    // Return the number of rows in the section.
	if (arrayName == nil) {
		return 0;
	}
	else {
		return arrayName.count;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];

    }
    
    // Configure the cell...
    NSString *strUserName = [arrayName objectAtIndex:indexPath.row];
	cell.textLabel.text = [NSString stringWithString:strUserName];
    return cell;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	[self.navigationController popViewControllerAnimated:YES];
}

+ (int)getOSVerOfMajor:(BOOL)major
{
	int result = -1;
	NSArray *aOsVersions = [[[UIDevice currentDevice]systemVersion] componentsSeparatedByString:@"."];
	int index = (major)? 0:1;
	result = [[aOsVersions objectAtIndex:index] intValue];
	return result;
}


+ (BOOL)isAbleToTrySNS:(NSString*)strServiceType;
{
	BOOL result = NO;
	@try {
		int osVer = [SelectAccountViewController getOSVerOfMajor:YES];
		if (osVer >= OSVER_MAJOR_SOCIALFRAMEWORK_ENABLE) {
			SLComposeViewController *slComposerSheet = [SLComposeViewController composeViewControllerForServiceType:strServiceType];
			//中国語キーボードが無いと、設定画面にWeiboの項目があってもnilが返ってくる？
			if (slComposerSheet != nil) {
				result = YES;
			}
		}
	}
	@catch (NSException *exception) {
		NSLog(@"name:%@ \n, reason:%@ \n, info:%@\n",
			  exception.name,
			  exception.reason,
			  exception.userInfo);
	}
	@finally {
	}
	return result;
}
#pragma mark -my Method
- (void)onGetAccounts
{
	[self.tableView reloadData];
	[activityView stopAnimating];
	self.title = @"Select Account";
}


#pragma mark -get SNS type string

+ (NSString*)getServiceTypeStringOf:(int)indexSNS;
{
	switch (indexSNS) {
		case SELSNS_TWITTER:
			return SLServiceTypeTwitter;
			break;
		case SELSNS_WEIBO:
			return SLServiceTypeSinaWeibo;
	}
	NSAssert(false, nil);
	return nil;
}

+ (NSString*)getAccountTypeStringOf:(int)indexSNS;
{
	switch (indexSNS) {
		case SELSNS_TWITTER:
			return ACAccountTypeIdentifierTwitter;
			break;
		case SELSNS_WEIBO:
			return ACAccountTypeIdentifierSinaWeibo;
	}
	NSAssert(false, nil);
	return nil;
	
}

+ (NSString*)getSNSNameStringOf:(int)indexSNS;
{
	switch (indexSNS) {
		case SELSNS_TWITTER:
			return @"Twitter";
			break;
		case SELSNS_WEIBO:
			return @"Weibo";
	}
	NSAssert(false, nil);
	return nil;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSLog(@"%s, %d", __PRETTY_FUNCTION__, indexPath.row);
	NSString *strName = [arrayName objectAtIndex:indexPath.row];
	NSLog(@"name:%@", strName);
	NSString *strId = [dictAccount objectForKey:strName];
	NSLog(@"%@", strId);
	
	{
		TweetViewController *controller = [[TweetViewController alloc] init];
		controller.strID = strId;
		[controller setAccountTypeString:strAccountType];
		[self.navigationController pushViewController:controller animated:YES];
		//[self.navigationController setNavigationBarHidden:YES];
		[controller release];
	}
}

@end
