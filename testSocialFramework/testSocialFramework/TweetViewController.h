//
//  TweetViewController.h
//  smarRoom001
//
//  Created by nakano_michiharu on 12/05/13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TWEET_ACTIVITY	0

@interface TweetViewController : UIViewController<UITextViewDelegate, UIAlertViewDelegate>
{
	NSString *_strID;
	NSString *strTweet;
	//UIActivityIndicatorView *activity;
	UIActivityIndicatorView *activityView;
	
	NSString *strAccountType;
}

@property (retain, nonatomic) NSString *strID;
@property (retain, nonatomic) IBOutlet UITextView *textFieldEdit;
@property (retain, nonatomic) IBOutlet UIButton *btnTweet;
@property (retain, nonatomic) IBOutlet UILabel *lblCountOfText;
@property (retain, nonatomic) IBOutlet UITextView *textFix;

- (void)setAccountTypeString:(NSString*)str;
- (IBAction)onPushButton:(id)sender;
@end
