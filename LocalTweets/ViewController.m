//
//  ViewController.m
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
#import "ViewController.h"

static NSString *TWITTER_CONSUMER_KEY = @"fx95oKhMHYgytSBmiAqQ";
static NSString *TWITTER_CONSUMER_SEC = @"0zfaijLMWMYTwVosdqFTL3k58JhRjZNxd2q0i9cltls";
static NSString *OAUTH_TOKEN = @"2305278770-GGw8dQQg3o5Vqfx9xHpUgJ0CDUe3BoNmUNeWZBg";
static NSString *OAUTH_SECRET = @"iEzxeJjEPnyODVcoDYt5MVvrg90Jx2TOetGdNeol6PeYp";

static NSString *twitterBaseAPIURL = @"https://api.twitter.com/1.1/search/tweets.json";

@interface ViewController ()
@property (strong, nonatomic) NSMutableArray *localTweets;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

#pragma mark Networking Methods


#pragma mark TableView DataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.localTweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tweet"];
    cell.tweet = self.localTweets[indexPath.row];
    
    return cell;
}

@end
