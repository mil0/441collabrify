//
//  MainMenu.m
//  Collabo
//
//  Created by Joshua Yu on 9/20/13.
//  Copyright (c) 2013 441. All rights reserved.
//

#import "MainMenu.h"

@interface MainMenu ()

@end

@implementation MainMenu

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    

    NSString *test_name = @"CREATOR";
    NSError *error;
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        client = [[CollabrifyClient alloc] initWithGmail:test_name
                                             displayName:test_name
                                            accountGmail:@"441fall2013@umich.edu"
                                             accessToken:@"XY3721425NoScOpE"
                                          getLatestEvent:NO
                                                   error:&error];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
}

@end
