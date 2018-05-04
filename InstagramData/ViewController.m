//
//  ViewController.m
//  InstagramData
//
//  Created by Timmy Strom on 3/1/18.
//  Copyright © 2018 Tim Strom. All rights reserved.
//

#import "ViewController.h"


#import <UIKit/UIKit.h>


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    // Optional: Place the button in the center of your view.
    loginButton.center = self.view.center;
    [self.view addSubview:loginButton];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
