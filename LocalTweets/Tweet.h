//
//  Tweet.h
//  LocalTweets
//
//  Created by John Andrews on 2/2/16.
//  Copyright © 2016 John Andrews. All rights reserved.
//
/*
 search for tweets containing a keyword or keyword phrase that are within a 5 mile radius of the user’s current location
 Avatar image of author
 Screen name of author
 Tweet text
 User location
 Inline photo, if applicable (see below for details)
 Relative timestamp (e.g. 5 minutes ago, 2 hours ago, 1 week ago)
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface Tweet : NSObject
@property (nonatomic, strong) NSString *tweet;
@property (nonatomic, strong) NSString *screenName;
@property (nonatomic, strong) UIImage *avatar;
@property (nonatomic, strong) NSDate *timestamp;

@end
