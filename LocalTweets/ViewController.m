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
#import "FHSTwitterEngine.h"
#import "UIImageView+AFNetworking.h"

static NSString *TWITTER_CONSUMER_KEY = @"fx95oKhMHYgytSBmiAqQ";
static NSString *TWITTER_CONSUMER_SEC = @"0zfaijLMWMYTwVosdqFTL3k58JhRjZNxd2q0i9cltls";
static NSString *OAUTH_TOKEN = @"2305278770-GGw8dQQg3o5Vqfx9xHpUgJ0CDUe3BoNmUNeWZBg";
static NSString *OAUTH_SECRET = @"iEzxeJjEPnyODVcoDYt5MVvrg90Jx2TOetGdNeol6PeYp";

static NSString *twitterBaseAPIURL = @"https://api.twitter.com/1.1/search/tweets.json";

static NSString *screenName = @"screen_name";
static NSString *tweetPic = @"media_url";
static NSString *avatar = @"profile_image_url";
static NSString *createdAt = @"created_at";


@interface ViewController () <FHSTwitterEngineAccessTokenDelegate>
@property (strong, nonatomic) NSMutableArray *localTweets;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) NSOperationQueue *imageOperationQueue;
@property (nonatomic, strong) NSCache *imageCache;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpLocationManager];

    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.imageOperationQueue = [[NSOperationQueue alloc]init];
    self.imageCache = [[NSCache alloc] init];
    self.localTweets = [NSMutableArray new];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.title = @"Local Tweets";
    if (!self.localTweets.count) {
        [self displaySpinner];
    }
}

- (void)displaySpinner {
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.center = self.view.center;
    [self.tableView addSubview: self.spinner];
    [self.tableView bringSubviewToFront:self.spinner];
    self.spinner.hidesWhenStopped = YES;
    self.spinner.hidden = NO;
    [self.spinner startAnimating];
}

#pragma mark - CLLocation Manager Delegate Methods

- (void)setUpLocationManager {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    //assumes, for this demo app, that user always accepts so no delegate method didChangeAuthorizationStatus:
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways ||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager startUpdatingLocation];
    } else {
        [self.locationManager requestWhenInUseAuthorization];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"ERROR %@", error.description);
    [self.spinner stopAnimating];
    UIAlertController *alert=   [UIAlertController alertControllerWithTitle:@"Error"
                                                                     message:@"Failed to Get Your Location"
                                                              preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   [alert dismissViewControllerAnimated:YES completion:nil];
                                               }];
    
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    if (newLocation) {
        [self setUpTwitterToken];
        [self getLocalTweetsFrom:newLocation forSubject:@"trending"];
        [self.locationManager stopUpdatingLocation];
    }
}

#pragma mark FHSTwitterEngine Delegate Methods

- (void)storeAccessToken:(NSString *)accessToken {
    [[NSUserDefaults standardUserDefaults]setObject:accessToken forKey:@"SavedAccessHTTPBody"];
}

- (NSString *)loadAccessToken {
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"SavedAccessHTTPBody"];
}

- (void)setUpTwitterToken {
    [[FHSTwitterEngine sharedEngine] setDelegate:self];
    FHSToken *token = [[FHSToken alloc] init];
    token.key = OAUTH_TOKEN;
    token.secret = OAUTH_SECRET;
    [FHSTwitterEngine sharedEngine].accessToken = token;
    
    [[FHSTwitterEngine sharedEngine] permanentlySetConsumerKey:TWITTER_CONSUMER_KEY andSecret:TWITTER_CONSUMER_SEC];
}

#pragma mark Networking Methods

- (void)getLocalTweetsFrom:(CLLocation *)location forSubject:(NSString *)topic {
  
    NSString *coordinates = [NSString stringWithFormat:@"%f,%f,5mi", location.coordinate.latitude, location.coordinate.longitude ];
    
    [self.imageOperationQueue addOperationWithBlock:^{
        NSArray *tweets = [[FHSTwitterEngine sharedEngine] searchForTweetsWithQuery:topic andLocation:coordinates];
        // searchForTweetsWithQuery is a synchronous NSURLRequest call
        
        if (tweets) {
            [self parseResponse:tweets];
            
            ViewController *__weak weakSelf = self;
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [weakSelf.spinner stopAnimating];
                [weakSelf.tableView reloadData];
            }];
        }
    }];
}

- (void)parseResponse:(NSArray *)responseObject {

    for (NSDictionary *pulledTweets in responseObject) {
        Tweet *tweet = [[Tweet alloc] init];
        tweet.timestamp = [self convertToDateFrom:pulledTweets[createdAt]];
        tweet.avatar = pulledTweets[avatar];
        tweet.screenName = pulledTweets[screenName];
        
        NSDictionary *status = pulledTweets[@"status"];
        tweet.text = status[@"text"];
        tweet.tweetPic = [self parseTweetPicURL:status];
        
        [self.localTweets addObject:tweet];
    }
    [self.tableView reloadData];
}

- (NSDate *)convertToDateFrom:(NSString *)string {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale currentLocale];
    [dateFormatter setDateFormat:@"EEE MMM dd HH:mm:ss ZZZ yyyy"];
    
    return [dateFormatter dateFromString:string];
}

- (NSString *)parseTweetPicURL:(NSDictionary *)dict {
    NSArray *media = [dict[@"extended_entities"] objectForKey:@"media"];
    NSString *picURL = [media.firstObject objectForKey:tweetPic];
    
    return picURL;
}

#pragma mark - Textfield Delegate Methods



#pragma mark TableView DataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.localTweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tweet"];
    Tweet *tweet = self.localTweets[indexPath.row];
    cell.tweet = tweet;
    
    __weak TweetTableViewCell *weakCell = cell;
    [cell.avatar setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:tweet.avatar]]
                          placeholderImage:nil
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                       weakCell.avatar.image = image;
                                       [weakCell setNeedsLayout];
                                   } failure:nil];
    if (tweet.tweetPic) {
        [cell.tweetPic setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:tweet.tweetPic]]
                           placeholderImage:nil
                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                        weakCell.tweetPic.image = image;
                                        [weakCell setNeedsLayout];
                                    } failure:nil];
    } else {
        cell.tweetPicHieghtConstraint.constant = 0;
    }
    
    return cell;
}

@end
