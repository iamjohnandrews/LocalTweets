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
@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.locatinManager.delegate = self;
    self.locatinManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locatinManager startUpdatingLocation];
    
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.title = @"Local Tweets";
    if (!self.localTweets) {
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

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
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
        [self getLocalTweetsFrom:newLocation];
    }
}

#pragma mark Networking Methods
- (void)getLocalTweetsFrom:(CLLocation *)location {
    NSURL* url = [NSURL URLWithString:twitterBaseAPIURL];
    NSString *coordinates = [NSString stringWithFormat:@"%f, %f, 5mi", location.coordinate.latitude, location.coordinate.longitude ];
    NSDictionary* params = @{@"q" : self.searchBar.text, @"geocode" : coordinates};
    
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                            requestMethod:SLRequestMethodGET
                                                      URL:url
                                               parameters:params];
    ViewController *__weak weakSelf = self;

    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        
        if (error) {
            NSLog(@"There was an error reading your Twitter feed. %@", error.localizedDescription);
            return;
        }
        
        NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:responseData
                                                                     options:NSJSONReadingMutableLeaves
                                                                       error:nil];
        if (responseJSON) {
            [self parseResponse:responseJSON];
            [weakSelf.spinner stopAnimating];
        }
    }];
}

- (void)parseResponse:(NSDictionary *)responseObject {
    
}

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
