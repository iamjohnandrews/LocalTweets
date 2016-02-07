//
//  TweetTableViewCell.m
//  LocalTweets
//
//  Created by John Andrews on 2/2/16.
//  Copyright © 2016 John Andrews. All rights reserved.
//

#import "TweetTableViewCell.h"

@implementation TweetTableViewCell

- (void)setTweet:(Tweet *)tweet {
    if (tweet.tweetPic) {
        self.tweetPic.image = [self loadImagefrom:[NSURL URLWithString:tweet.tweetPic]];
    } else {
        self.tweetPicHieghtConstraint = 0;
    }
    self.userName.text = tweet.screenName;
    self.avatar.image = [self loadImagefrom:[NSURL URLWithString:tweet.avatar]];
    self.tweetBody.text = tweet.text;
    self.timeFromNow.text = [self formateTimestamp:tweet.timestamp];
    self.location.text = @"within 5 miles";
}

- (NSString *)formateTimestamp:(NSDate *)time {
    NSString *timefromNow;
    
    return timefromNow;
}

- (UIImage *)loadImagefrom:(NSURL *)url {
    __block UIImage *returnImage;
    NSOperationQueue *loadQueue = [[NSOperationQueue alloc] init];
    [loadQueue addOperationWithBlock:^{
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *img = [[UIImage alloc] initWithData:data];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            returnImage = img;
        }];
    }];
    return returnImage;
}

- (IBAction)replyTapped:(UIButton *)sender {
    NSLog(@"reply tapped");
}
@end
