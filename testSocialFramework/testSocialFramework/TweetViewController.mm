//
//  TweetViewController.m
//  smarRoom001
//
//  Created by nakano_michiharu on 12/05/13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TweetViewController.h"
#import "SelectAccountViewController.h"

#define _MAX_LENGTH	139
#define _FIX_MESSAGE	@"固定メッセージ"
#define _EDITABLE_MESSAGE	@"編集可能メッセージ"

@interface TweetViewController ()
- (void)tweet;
- (void)popReturn;
- (void)confirmTweet;
- (void)updateCountLabel;

@end

@implementation TweetViewController
@synthesize strID = _strID;
@synthesize textFieldEdit = _textFieldEdit;
@synthesize btnTweet = _btnTweet;
@synthesize lblCountOfText = _lblCountOfText;
@synthesize textFix = _textFix;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		_strID = nil;
		strTweet = nil;
		activityView = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	

	NSString *strDefault = _EDITABLE_MESSAGE;
	NSString *strFixHead = _FIX_MESSAGE;

    // Do any additional setup after loading the view from its nib.
	self.textFix.text = [NSString stringWithFormat:@"%@", strFixHead];
	self.textFieldEdit.text = strDefault;
	self.textFieldEdit.returnKeyType = UIReturnKeyDone;
	self.textFieldEdit.delegate  = self;
	[self updateCountLabel];
	
	activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[activityView stopAnimating];
	[activityView hidesWhenStopped];
	UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:activityView];
	self.navigationItem.rightBarButtonItem = barButton;
	[self.navigationController setNavigationBarHidden:NO];
	[barButton release];
	[activityView release];
}

- (void)viewDidUnload
{
	[self setTextFieldEdit:nil];
	[self setBtnTweet:nil];
    [self setLblCountOfText:nil];
	activityView = nil;
    [self setTextFix:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
	[_strID release];
	[_textFieldEdit release];
	[_btnTweet release];
    [_lblCountOfText release];
    [_textFix release];
	[strTweet release];
	[super dealloc];
}
#pragma mark -event
- (IBAction)onPushButton:(id)sender
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	if (sender == self.btnTweet) {
		[self confirmTweet];
	}
}

#pragma mark -Tweet

- (void)confirmTweet
{
	strTweet = [[NSString alloc] initWithFormat:@"%@%@", self.textFieldEdit.text, self.textFix.text];
	//strTweet = [NSString stringWithFormat:@"%@%@", self.textFieldEdit.text, self.textFix.text];
	if (strTweet.length > _MAX_LENGTH) {
		int maxEdit = _MAX_LENGTH - self.textFix.text.length;
		strTweet = [NSString stringWithFormat:@"%@%@",
					[self.textFieldEdit.text substringToIndex:maxEdit],
					self.textFix.text];
	}
	NSLog(@"%@", strTweet);
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm Tweet"
													message:strTweet
												   delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Tweet", nil];
	[alert show];
	[alert release];
}

- (void)tweet
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	if (strAccountType == nil) {
		NSLog(@"error:アカウントタイプ未設定");
		return;
	}
	ACAccountStore *accountStore = [[[ACAccountStore alloc] init] autorelease];
	ACAccount *accountTwitter = [accountStore accountWithIdentifier:self.strID];
	NSLog(@"%@", strTweet);
	
	NSURL *url = nil;
	NSDictionary *params = nil;
	NSString *strServiceType = nil;
	
	if ([strAccountType isEqualToString:ACAccountTypeIdentifierTwitter]) {
		url = [NSURL URLWithString:@"http://api.twitter.com/1/statuses/update.json"];
		params = [NSDictionary dictionaryWithObject:strTweet forKey:@"status"];
		strServiceType = SLServiceTypeTwitter;
	}
	else if ([strAccountType isEqualToString:ACAccountTypeIdentifierSinaWeibo]) {
		url = [NSURL URLWithString:@"https://api.weibo.com/2/statuses/update.json"];
		params = [NSDictionary dictionaryWithObject:strTweet forKey:@"status"];
		strServiceType = SLServiceTypeSinaWeibo;
	}
	SLRequest *request = [SLRequest requestForServiceType:strServiceType
											requestMethod:SLRequestMethodPOST
													  URL:url
											   parameters:params];
	[request setAccount:accountTwitter];
	
	self.btnTweet.hidden = YES;
	
	[request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
		NSString *strReason = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
		NSLog(@"responseData=%@", strReason);
		[strReason release];
		[self performSelectorOnMainThread:@selector(popReturn) withObject:self waitUntilDone:NO];
	}];
}

- (void)popReturn
{
	NSLog(@"pop %s", __PRETTY_FUNCTION__);

	int countOfControllers = self.navigationController.viewControllers.count;
	NSLog(@"count of controller:%d", countOfControllers);
	[self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)setAccountTypeString:(NSString*)str
{
	strAccountType = [NSString stringWithString:str];
}



#pragma mark -TextView delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	NSLog(@"%s:%@", __PRETTY_FUNCTION__, text);
	if ([text isEqualToString:@"\n"]) {
		
		[self confirmTweet];
		return NO;
	}
	else {
		NSLog(@"%@ : %d", textView.text, textView.text.length + text.length);
	}
	return YES;
}

- (void)textViewDidChangeSelection:(UITextView *)textView
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)textViewDidChange:(UITextView *)textView
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	NSLog(@"text count is : %d", textView.text.length);
	[self updateCountLabel];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	NSLog(@"%@ : %d", textView.text, textView.text.length);
}

#pragma mark -Disp information
- (void)updateCountLabel
{
	int countMax = _MAX_LENGTH;
	countMax -= self.textFix.text.length + self.textFieldEdit.text.length;
	
	self.lblCountOfText.text = [NSString stringWithFormat:@"%d", countMax];
	if (countMax < 0) {
		self.lblCountOfText.textColor = UIColor.redColor;
	}
	else {
		self.lblCountOfText.textColor = UIColor.blackColor;
	}
}


#pragma mark -Alert delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	NSLog(@"%s index is %d", __PRETTY_FUNCTION__, buttonIndex);
	if (buttonIndex != 0) {
		[self.textFieldEdit resignFirstResponder];
		[self tweet];
	}
}


@end
