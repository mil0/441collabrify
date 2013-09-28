//
//  MainMenu.m
//  Collabo
//
//  Created by Joshua Yu on 9/20/13.
//  Copyright (c) 2013 441. All rights reserved.
//

#import "MainMenu.h"
#import "ViewController.h"
#import "SessionViewController.h"

@interface MainMenu () <UITextViewDelegate, CollabrifyClientDelegate, CollabrifyClientDataSource>

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
    createSessionAlert = [[UIAlertView alloc] initWithTitle:@"Create Session" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create", nil];
    
    createSessionAlert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    createSessionAlert.tag = 0;
    
    UITextField * sessionNameField = [createSessionAlert textFieldAtIndex:0];
    UITextField * sessionTagField = [createSessionAlert textFieldAtIndex:1];
    
    [sessionNameField setPlaceholder:@"Enter Session Name"];
    [sessionTagField setPlaceholder:@"Enter Session Tag(s)"];
    
    sessionTagField.secureTextEntry = NO;
    
    
    //Join Session Alert View
    
    joinSessionAlert = [[UIAlertView alloc] initWithTitle:@"Join Session" message:@"Please Enter Session Tag(s) separated by commas" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Join", nil];
    
    joinSessionAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    joinSessionAlert.tag = 1;
    
    sessionName = [[NSMutableString alloc] init];
    int64_t participationID;
    
    
    //turn off navigation toolbar on screen
    [self.navigationController setNavigationBarHidden:YES];
    
    
    //Hides the status bar
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];

    //[[self client] setDelegate:self];
    //[[self client] setDataSource:self];
    
    // Do any additional setup after loading the view.
    
    //Init Collab Client
    
    NSError *error;
    NSString *test_name = @"test_name";
    client = [[CollabrifyClient alloc] initWithGmail:test_name
                                         displayName:test_name
                                        accountGmail:@"441fall2013@umich.edu"
                                         accessToken:@"XY3721425NoScOpE"
                                      getLatestEvent:NO
                                               error:&error];
    // combination of tag/name needs to be unique
    [client setDelegate:self];
}
- (IBAction)create:(id)sender {
    [createSessionAlert show];
}
- (IBAction)join:(id)sender {
    [joinSessionAlert show];
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 0){ // Create Button
        if (buttonIndex == 1) {
            UITextField * textField = [alertView textFieldAtIndex:0];
            UITextField * textField2 = [alertView textFieldAtIndex:1];
            
            NSArray * tags = [textField2.text componentsSeparatedByString:@","];
            
            NSLog(@"%@", textField.text);
            //sessionName = [NSMutableString stringWithString:textField.text];
            [client createSessionWithName:textField.text
                                     tags:tags
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
    
    if (alertView.tag == 1) {
        if (buttonIndex == 1) {
            UITextField * textField = [alertView textFieldAtIndex:0];
            NSLog(@"%@", textField.text);
            NSString * sessionTags = textField.text;
            NSMutableArray *myTags = [sessionTags componentsSeparatedByString:@","];
            [client listSessionsWithTags:myTags completionHandler:^(NSArray * sessionList, CollabrifyError * error){
               //give sessionList to SessionViewController to display unless there is an error
                if (!error) {
                    joinSessionList = sessionList;
                    [self performSegueWithIdentifier:@"segue.join" sender:self];
                }
                else{
                    NSLog([error localizedDescription]);
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
    
    if([[segue identifier] isEqualToString:@"segue.push.alert"]){
        //UIViewController * destView = (ViewController *)[segue destinationViewController];
        [segue.destinationViewController setClient:client];
    }
    else if([[segue identifier] isEqualToString:@"segue.join"]){
        [segue.destinationViewController setSessionList:joinSessionList];
        [segue.destinationViewController setClient:client];

    }
}

@end
