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
    
    self.userName.text = tweet.screenName;
    self.tweetBody.text = tweet.text;
    self.timeFromNow.text = [self formateTimestamp:tweet.timestamp];
    self.location.text = @"within 5 miles";
}

- (NSString *)formateTimestamp:(NSDate *)time {
    NSCalendarUnit units = NSCalendarUnitSecond | NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:units
                                                                   fromDate:time
                                                                     toDate:[NSDate date]
                                                                    options:0];
    if (components.year >=1) {
        return [NSString stringWithFormat:@"%ldy", (long)components.year];
    } else if (components.month >= 1) {
        return [NSString stringWithFormat:@"%ldm", (long)components.month];
    } else if (components.day >= 1) {
        return [NSString stringWithFormat:@"%ldd", (long)components.day];
    } else if (components.hour >= 1) {
        return [NSString stringWithFormat:@"%ldh", (long)components.hour];
    } else if (components.minute >= 1) {
        return [NSString stringWithFormat:@"%ldmm", (long)components.minute];
    } else {
        return [NSString stringWithFormat:@"%lds", (long)components.second];
    }
}

- (IBAction)replyTapped:(UIButton *)sender {
    NSLog(@"reply tapped");
}
@end
