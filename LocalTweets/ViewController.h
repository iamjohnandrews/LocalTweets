//
//  ViewController.h
//  LocalTweets
//
//  Created by John Andrews on 2/2/16.
//  Copyright © 2016 John Andrews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"
#import "TweetTableViewCell.h"
#import <CoreLocation/CoreLocation.h>
#import <Social/Social.h>

@interface ViewController : UIViewController <UITableViewDataSource, CLLocationManagerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *searchBar;
@property (strong, nonatomic) CLLocationManager *locationManager;
@end

