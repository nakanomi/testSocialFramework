//
//  ViewController.m
//  testWeibo
//
//  Created by nakano_michiharu on 2013/02/02.
//  Copyright (c) 2013年 nakano_michiharu. All rights reserved.
//

#import "ViewController.h"
#import "SelectAccountViewController.h"

@interface ViewController ()
- (BOOL)isAccountRegistered;
- (BOOL)tryRegistID;
- (void)applicationDidBecomeActive;
- (void)sendBySLComposeViewControllerWithText:(NSString*)text andUrl:(NSString*)strUrl;

@end

@implementation ViewController

const float alphaOfDisable = 0.3f;
const float alphaOfEnable = 1.0f;

//短縮URLだと投稿に失敗する？らしい
#define TWITTER_URL_ENG	@"https://itunes.apple.com/us/app/smart-room/id534881295"

#pragma mark -viewcontroller
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive)
                                                 name:@"applicationDidBecomeActive"
                                               object:nil];
	giveUp = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self isAccountRegistered];
	//self.btnIdEnableCustom.hidden = YES;
}


- (void)dealloc {
	[_btnIdEnable release];
	[_btnIdDisable release];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"applicationDidBecomeActive" object:nil];
	[_btnIdEnableCustom release];
	[_segSelectSNS release];
	[super dealloc];
}
- (void)viewDidUnload {
	[self setBtnIdEnable:nil];
	[self setBtnIdDisable:nil];
	[self setBtnIdEnableCustom:nil];
	[self setSegSelectSNS:nil];
	[super viewDidUnload];
}

#pragma mark -Action
- (IBAction)onPushBtn:(id)sender
{
	if (!giveUp) {
		if ([sender isEqual:self.btnIdEnable]) {
			[self sendBySLComposeViewControllerWithText:@"投稿テスト + URL" andUrl:TWITTER_URL_ENG];
		}
		else if ([sender isEqual:self.btnIdEnableCustom]) {
			SelectAccountViewController *controller = [[SelectAccountViewController alloc] init];
			[controller setAccountTypeString:[SelectAccountViewController getAccountTypeStringOf:
											  self.segSelectSNS.selectedSegmentIndex]];
			[self.navigationController pushViewController:controller animated:YES];
			[controller release];
		}
		else if ([sender isEqual:self.btnIdDisable]) {
			BOOL resultOfTry = [self tryRegistID];
			NSLog(@"result is %d", resultOfTry);
			if (giveUp) {
				self.btnIdEnable.enabled = NO;
				self.btnIdEnableCustom.enabled = NO;
				self.btnIdDisable.enabled = NO;
				self.btnIdEnable.alpha = alphaOfDisable;
				self.btnIdEnableCustom.alpha = alphaOfDisable;
				self.btnIdDisable.alpha = alphaOfDisable;
			}
		}
	}
	if ([sender isEqual:self.segSelectSNS]) {
		giveUp = NO;
		[self isAccountRegistered];
	}
}



#pragma mark -myMethod

- (BOOL)isAccountRegistered
{
	BOOL result = NO;
	if (self.segSelectSNS.selectedSegmentIndex == SELSNS_NO_SELECT) {
		self.btnIdDisable.hidden = YES;
		self.btnIdEnable.hidden = YES;
		self.btnIdEnableCustom.hidden = YES;
	}
	else {
		self.btnIdDisable.hidden = NO;
		self.btnIdEnable.hidden = NO;
		self.btnIdEnableCustom.hidden = NO;
		giveUp = !([SelectAccountViewController isAbleToTrySNS:
					[SelectAccountViewController getServiceTypeStringOf:
					 self.segSelectSNS.selectedSegmentIndex]]);
		if (!giveUp) {
			result = [SLComposeViewController isAvailableForServiceType:
					  [SelectAccountViewController getServiceTypeStringOf:
					   self.segSelectSNS.selectedSegmentIndex]];
			
			self.btnIdEnable.enabled = result;
			self.btnIdDisable.enabled = !result;
			if (result) {
				self.btnIdEnable.alpha = alphaOfEnable;
				self.btnIdEnableCustom.alpha = alphaOfEnable;
				self.btnIdDisable.alpha = alphaOfDisable;
			}
			else {
				self.btnIdEnable.alpha = alphaOfDisable;
				self.btnIdEnableCustom.alpha = alphaOfDisable;
				self.btnIdDisable.alpha = alphaOfEnable;
			}
		}
		else {
			self.btnIdEnable.alpha = alphaOfDisable;
			self.btnIdEnableCustom.alpha = alphaOfDisable;
			self.btnIdDisable.alpha = alphaOfDisable;
		}
	}
	
	return result;
}



- (BOOL)tryRegistID
{
	BOOL result = NO;
	if (!giveUp) {
		@try {
			SLComposeViewController *slComposerSheet = [SLComposeViewController composeViewControllerForServiceType:
														[SelectAccountViewController getServiceTypeStringOf:
														 self.segSelectSNS.selectedSegmentIndex]];
			//デバイスの言語環境が中国語でなく、中国語キーボードが追加されていないと、設定画面にWeiboの項目があってもnilが返ってくる？
			if (slComposerSheet == nil) {
				//諦める
				giveUp = YES;
				//あるいは中国語キーボードの追加を促してみる
				[NSException raise:@"nil" format:@"slComposerSheet is nil"];
			}
			NSString *strError = [NSString stringWithFormat:
								  @"このデバイスには%@アカウントが登録されていません", [SelectAccountViewController getSNSNameStringOf:
																						   self.segSelectSNS.selectedSegmentIndex]];
			[slComposerSheet setInitialText:strError];
			[self presentViewController:slComposerSheet animated:YES completion:nil];
			result = YES;
		}
		@catch (NSException *exception) {
			NSLog(@"name:%@ \n, reason:%@ \n, info:%@\n",
				  exception.name,
				  exception.reason,
				  exception.userInfo);
		}
	}
	return result;
}

- (void)sendBySLComposeViewControllerWithText:(NSString*)text andUrl:(NSString*)strUrl
{
	if (!giveUp) {
		@try {
			SLComposeViewController *slComposerSheet = [SLComposeViewController composeViewControllerForServiceType:
														[SelectAccountViewController getServiceTypeStringOf:
														 self.segSelectSNS.selectedSegmentIndex]];
			if (text != nil) {
				[slComposerSheet setInitialText:text];
			}
			if (strUrl != nil) {
				NSURL *url = [NSURL URLWithString:strUrl];
				[slComposerSheet addURL:url];
			}
			[slComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
				if (result == SLComposeViewControllerResultDone) {
					NSLog(@"投稿完了");
				}
			}];
			[self presentViewController:slComposerSheet animated:YES completion:nil];
			
		}
		@catch (NSException *exception) {
			NSLog(@"name:%@ \n, reason:%@ \n, info:%@\n",
				  exception.name,
				  exception.reason,
				  exception.userInfo);
		}
	}
}



#pragma mark -observer


- (void)applicationDidBecomeActive
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	[self isAccountRegistered];
}

@end
