//
//  Login.m
//  InstagramData
//
//  Created by Timmy Strom on 3/5/18.
//  Copyright © 2018 Tim Strom. All rights reserved.
//

#import "LoginViewController.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>


@interface LoginViewController()


@end

NSDictionary *badWordsDictionary;
int timeInterval = 90;      //number of days since today included in the comment search
NSDateFormatter *dateFormatter;

@implementation LoginViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Add a custom login button to your app
    UIButton *myLoginButton=[UIButton buttonWithType:UIButtonTypeCustom];
    myLoginButton.backgroundColor=[UIColor darkGrayColor];
    myLoginButton.frame=CGRectMake(0,0,180,40);
    myLoginButton.center = self.view.center;
    [myLoginButton setTitle: @"My Login Button" forState: UIControlStateNormal];
    
    // Handle clicks on the button
    [myLoginButton
     addTarget:self
     action:@selector(loginButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    // Add the button to the view
    [self.view addSubview:myLoginButton];
}

// Once the button is clicked, show the login dialog
-(void)loginButtonClicked
{
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login
     logInWithReadPermissions: @[@"public_profile", @"email", @"instagram_basic", @"instagram_manage_comments"]
     fromViewController:self
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error) {
             NSLog(@"\n Process error");
         } else if (result.isCancelled) {
             NSLog(@"\n Cancelled");
         } else {
             NSLog(@"\n Logged in");
             
             NSString *firstToken = [FBSDKAccessToken currentAccessToken].tokenString;
             
             //first request with facebook token
             FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me/accounts" parameters:@{@"fields": @"connected_instagram_account",} tokenString:firstToken version:@"v2.12" HTTPMethod:@"GET"];
             [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id newresult, NSError *error) {
                 if (newresult){
                     
                     NSString *idValue = [[[[newresult valueForKey:@"data"] valueForKey:@"connected_instagram_account"] valueForKey:@"id"] objectAtIndex:0];
                     
                     //second request
                     FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                                   initWithGraphPath: idValue
                                                   parameters:@{ @"fields": @"media{comments.limit(200){text,timestamp,user}}",}
                                                   tokenString:firstToken version:@"v2.12"
                                                   HTTPMethod:@"GET"];
                     [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                         if (result){
                             //comment arrays have latest comment at index zero
                             NSArray *allPosts = [[[[result valueForKey:@"media"] valueForKey:@"data"] valueForKey:@"comments"] valueForKey:@"data"];
                             
                             //creates the dictionary of bad words
                             NSDictionary *badWords = [self getBadWordsDictionary];
                             int badWordCounter = 0;
                             
                             NSString *commenterID;
                             NSDate *commentDate;
                             NSDate *currentDate = [NSDate date];
                             
                             //The time window is from today until the target date
                             int secondsInDay = 86400;  // 24(hours) * 60(minutes) * 60(seconds)
                             NSDate *targetDate = [currentDate dateByAddingTimeInterval:-timeInterval * secondsInDay];
                             
                             int counter = 0;
                             //iterates through each post
                             for(NSArray *post in allPosts){
                                 //iterates through each comment in one post
                                 for(NSArray *comment in post){
                                     counter ++;
                                     NSLog(@"\n comment: %@           comment number: %i", [comment valueForKey:@"text"], counter);
                                     
                                     commenterID = [comment valueForKey:@"id"];
                                     NSString *commentTimeStamp = [comment valueForKey:@"timestamp"];
                                     
                                     //converts the comment timestamp to an NSDate object to compare with the target date
                                     dateFormatter = [[NSDateFormatter alloc] init];
                                     [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
                                     commentDate = [dateFormatter dateFromString:commentTimeStamp];
                                     
                                     NSComparisonResult result = [targetDate compare:commentDate];
                                     
                                     if(result==NSOrderedAscending){         //commentDate is in the time window
                                         if(![commenterID isEqualToString:idValue]){
                                             NSString *commentText = [comment valueForKey:@"text"];
                                             NSArray *allwords = [commentText componentsSeparatedByString:@" "];
                                             //iterates through each word of the non-victim comment
                                             for (NSString *word in allwords){
                                                 NSString *wordWithoutPunctuation = [
                                                                                     [word componentsSeparatedByCharactersInSet:[
                                                                                                                                 [NSCharacterSet letterCharacterSet]
                                                                                                                                 invertedSet]]componentsJoinedByString:@""];
                                                 
                                                 NSString *lowercaseWord = [wordWithoutPunctuation lowercaseString];
                                                 if(badWords[lowercaseWord]){
                                                     badWordCounter += 1;
                                                     //NSLog(@"\n %@", lowercaseWord);
                                                     //NSLog(@"\n commentDate: %@ \n targetDate: %@", commentDate, targetDate);
                                                 }
                                             }
                                         }
                                     }
                                     else if(result==NSOrderedDescending){      //commentDate is before the time window
                                         NSLog(@"\n Comment is out of time window");
                                         //NSLog(@"\n commentDate: %@ \n targetDate: %@", commentDate, targetDate);
                                     }
                                     else{                                   //both dates are the same
                                         NSLog(@"\n Both dates are same");
                                         NSLog(@"\n commentDate: %@ \n targetDate: %@", commentDate, targetDate);
                                     }
                                     
                                 }
                             }
                             
                             //NSLog(@"\n Number of comments: %d", counter);
                             
                             //NSLog(@"\n number of bad words: %i", badWordCounter);
                             
                             //NSLog(@"\n latest comment: %@", [[postComments objectAtIndex:0] objectAtIndex:0]);
                             //NSLog(@"\n other comment: %@", [[postComments objectAtIndex:1] objectAtIndex:1]);
                         }
                         if (error){
                             NSLog(@"\n Error in second graph request");
                         }
                     }];
                     
                     
                 }
                 if (error){
                     NSLog(@"\n There was an error with the first graph request");
                 }
             }];
             
             
         }
     }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (NSDictionary *)getBadWordsDictionary
{
    /*
     Retrieve the bad words dictionary from file
     */
    NSLog(@"\n Retreiving bad words dictionary from file");
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"naughtyWords" ofType:@"plist"];
    badWordsDictionary = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    
    return badWordsDictionary;
}

@end

