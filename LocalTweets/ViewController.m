//
//  ViewController.m
//  LocalTweets
//
//  Created by John Andrews on 2/2/16.
//  Copyright © 2016 John Andrews. All rights reserved.
//

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
static NSString *location = @"location";


@interface ViewController () <FHSTwitterEngineAccessTokenDelegate>
@property (strong, nonatomic) NSMutableArray *localTweets;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (strong, nonatomic) NSOperationQueue *imageOperationQueue;
@property (strong, nonatomic) NSCache *imageCache;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpLocationManager];

    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 300.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.imageOperationQueue = [[NSOperationQueue alloc]init];
    self.imageCache = [[NSCache alloc] init];
    
    self.searchBar.delegate = self;
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

- (void)displayAlertType:(NSString *)alertType withMessage:(NSString *)message {
    [self.spinner stopAnimating];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertType
                                                                    message:message
                                                             preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   [alert dismissViewControllerAnimated:YES completion:nil];
                                               }];
    
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
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
    [self displayAlertType:@"Location Error" withMessage:@"Failed to Get Your Location"];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    if (newLocation) {
        [self setUpTwitterToken];
        [self getLocalTweetsFrom:newLocation forSubject:@"trending"];
        [self.locationManager stopUpdatingLocation];
        self.currentLocation = newLocation;
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
        if (tweets.count > 0) {
            [self parseResponse:tweets];
        } else {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self displayAlertType:@"Twitter Error" withMessage:@"Failed to Get Your Tweets"];
            }];
        }
    }];
}

- (void)parseResponse:(NSArray *)responseObject {
    self.localTweets = [NSMutableArray new];

    for (NSDictionary *pulledTweets in responseObject) {
        Tweet *tweet = [[Tweet alloc] init];
        tweet.timestamp = [self convertToDateFrom:pulledTweets[createdAt]];
        tweet.avatar = pulledTweets[avatar];
        tweet.screenName = pulledTweets[screenName];
        tweet.location = pulledTweets[location];

        NSDictionary *status = pulledTweets[@"status"];
        tweet.text = status[@"text"];
        tweet.tweetPic = [self parseTweetPicURL:status];
        
        [self.localTweets addObject:tweet];
    }
    
    [self sortTweetsByDate];
}

- (void)sortTweetsByDate {
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:FALSE];
    [self.localTweets sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.spinner stopAnimating];
        [self.tableView reloadData];
    }];
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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    textField.text = @"";
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self getLocalTweetsFrom:self.currentLocation forSubject:textField.text];
    [textField resignFirstResponder];
    [self.tableView setContentOffset:CGPointZero animated:YES];
    return YES;
}

#pragma mark TableView DataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.localTweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tweet"];
    Tweet *tweet = self.localTweets[indexPath.row];
    cell.tweet = tweet;
    
    UIImage *avatarFromCache = [self.imageCache objectForKey:tweet.avatar];
    UIImage *tweetPicFromCache = [self.imageCache objectForKey:tweet.tweetPic];
    
    if (avatarFromCache) {
        cell.avatar.image = avatarFromCache;
    } else {
        [self getImageURL:tweet.avatar forCell:cell forImage:cell.avatar andIsAvatar:YES];
    }
    
    if (tweetPicFromCache) {
        cell.tweetPic.image = tweetPicFromCache;
    } else {
        cell.tweetPicHieghtConstraint.constant = 0;
        [self getImageURL:tweet.tweetPic forCell:cell forImage:cell.tweetPic andIsAvatar:NO];
    }
    
    return cell;
}

- (void)getImageURL:(NSString *)imageURL forCell:(TweetTableViewCell *)cell forImage:(UIImageView *)imageView andIsAvatar:(BOOL)isAvatar{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]];
    [imageView setImageWithURLRequest:request
                       placeholderImage:nil
                                success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                    [self.imageCache setObject:image forKey:imageURL];
                                    
                                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                        if (isAvatar) {
                                            cell.avatar.image = image;
                                        } else {
                                            cell.tweetPicHieghtConstraint.constant = 156;
                                            cell.tweetPic.image = image;
                                        }
                                        [cell setNeedsLayout];
                                    }];
                                } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                                    NSLog(@"%@ ERROR: %@", cell.userName, error.description);
                                }];
}


@end
