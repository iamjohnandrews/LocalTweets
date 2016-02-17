//
//  TweetTableViewCell.m
//  LocalTweets
//
//  Created by John Andrews on 2/2/16.
//  Copyright © 2016 John Andrews. All rights reserved.
//

#import "TweetTableViewCell.h"

const float imageCorner = 10.0f;

@implementation TweetTableViewCell

- (void)setTweet:(Tweet *)tweet {
    
    self.userName.text = tweet.screenName;
    self.timeFromNow.text = [self formateTimestamp:tweet.timestamp];
    self.location.text = tweet.location;
    if (tweet.text) {
        self.tweetBody.text = tweet.text;
    } else {
        self.tweetBodyHieghtContraint = 0;
    }
}

- (NSString *)formateTimestamp:(NSDate *)time {
    NSCalendarUnit units = NSCalendarUnitSecond | NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:units
                                                                   fromDate:time
                                                                     toDate:[NSDate date]
                                                                    options:0];
    if (components.year >=1) {
        return [NSString stringWithFormat:@"%ldy", (long)components.year];
    } else
        if (components.month >= 1) {
        return [NSString stringWithFormat:@"%ldm", (long)components.month];
    } else
        if (components.day >= 1) {
        return [NSString stringWithFormat:@"%ldd", (long)components.day];
    } else if (components.hour >= 1) {
        return [NSString stringWithFormat:@"%ldh", (long)components.hour];
    } else if (components.minute >= 1) {
        return [NSString stringWithFormat:@"%ldmm", (long)components.minute];
    } else {
        return [NSString stringWithFormat:@"%lds", (long)components.second];
    }
}

- (void)awakeFromNib {
    [self formatReplyButton];
    [self roundImageEdges];
}

- (void)formatReplyButton {
    self.replyButton.backgroundColor = [UIColor lightGrayColor];
    self.replyButton.layer.cornerRadius = imageCorner - 2;
}

- (void)roundImageEdges {
    self.avatar.layer.cornerRadius = imageCorner;
    self.tweetPic.layer.cornerRadius = imageCorner;
}

- (IBAction)replyTapped:(UIButton *)sender {
    NSLog(@"reply tapped");
}
@end
