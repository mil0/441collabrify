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
    
    //UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"collabo.png"]];
    //UIImage * myImage = [UIImage imageNamed: @"collabo.png"];
    //UIImageView * myImageView = [[UIImageView alloc] initWithImage: myImage];
    //[sendSubviewToBack:myImageView];
    //myImageView.contentMode = UIViewContentModeScaleAspectFit;
    //[[self view] addSubview:myImageView];
    //UIImageView * new;
    //new.contentMode = UIViewContentModeScaleAspectFill;
    //UIColor *color = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"collabo.png"]];
    
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"collabo.png"]];
    
    
    //Create Session Alert View
    createSessionAlert = [[UIAlertView alloc] initWithTitle:@"Create Session" message:@"Please Enter Session Tag" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create", nil];
    
    createSessionAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    createSessionAlert.tag = 0;
    
    
    
    sessionName = [[NSMutableString alloc] init];
    int64_t participationID;
    
    
    //turn off navigation toolbar on screen
    [self.navigationController setNavigationBarHidden:YES];

	// Do any additional setup after loading the view.
}
- (IBAction)create:(id)sender {
    [createSessionAlert show];
    
    NSError *error;

    NSString *test_name = @"CREATOR";
    client = [[CollabrifyClient alloc] initWithGmail:test_name
                                         displayName:test_name
                                        accountGmail:@"441fall2013@umich.edu"
                                         accessToken:@"XY3721425NoScOpE"
                                      getLatestEvent:NO
                                               error:&error];
    // combination of tag/name needs to be unique
    [client setDelegate:self];
}
- (IBAction)join:(id)sender {
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 0){
        if (buttonIndex == 1) {
            UITextField * textField = [alertView textFieldAtIndex:0];
            NSLog(@"%@", textField.text);
            sessionName = [NSMutableString stringWithString:@"Session"];
            [client createSessionWithName:sessionName
                                     tags:[NSArray arrayWithObject:textField.text]
                                 password:nil
                              startPaused:NO
                        completionHandler:^(int64_t sessionID, CollabrifyError * error)
             {
                 
                 if(!error){
                     NSLog(@"Session Successfully Created");
                     //[self performSegueWithIdentifier:@"createTheSession"sender:self];
                     bool test2 = [client isInSession];
                     
                     
                     if (test2) {
                         int64_t session_ID = [client currentSessionID];
                         NSLog([NSString stringWithFormat:@"Session ID: %lld", session_ID]);
                         participationID = [client participantID]; // setting participation ID
                         NSLog([NSString stringWithFormat:@"Participation ID: %lld", participationID]);
                         
                        
                         
                        //changing the BACK button Title
                         UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: @"Exit" style: UIBarButtonItemStyleBordered target: nil action: nil];
                         [[self navigationItem] setBackBarButtonItem: newBackButton];

                         
                         //Manual trigger segue that initiates after Session Login Completed
                         [self performSegueWithIdentifier:@"segue.push.alert" sender:self];
                         
                         
                     }
                     else {
                         NSLog(@"is not in sessoin");
                         NSLog([error localizedDescription]);
                         
                     }
                 }
                 else{
                     NSLog(@"Error Recieved: %@", error);
                     //[ErrorOccurred show];
                 }
             }];
        }
    }
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
}

@end
