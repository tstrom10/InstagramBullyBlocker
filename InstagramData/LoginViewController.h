//
//  Login.h
//  InstagramData
//
//  Created by Timmy Strom on 3/5/18.
//  Copyright © 2018 Tim Strom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface LoginViewController : UIViewController<FBSDKLoginButtonDelegate>

@property (nonatomic, strong) IBOutlet FBSDKLoginButton *loginButton;

@end
