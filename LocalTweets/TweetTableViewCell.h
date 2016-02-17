//
//  TweetTableViewCell.h
//  LocalTweets
//
//  Created by John Andrews on 2/2/16.
//  Copyright © 2016 John Andrews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

@interface TweetTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UITextView *tweetBody;
@property (weak, nonatomic) IBOutlet UIImageView *tweetPic;
@property (weak, nonatomic) IBOutlet UILabel *location;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *timeFromNow;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tweetPicHieghtConstraint;
@property (strong, nonatomic) Tweet *tweet;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tweetBodyHieghtContraint;

@property (weak, nonatomic) IBOutlet UIButton *replyButton;

- (IBAction)replyTapped:(UIButton *)sender;
@end
