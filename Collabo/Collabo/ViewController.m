//
//  ViewController.m
//  Collabo
//
//  Created by milo kock on 9/6/13.
//  Copyright (c) 2013 441. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <CollabrifyClientDelegate, CollabrifyClientDataSource>
    
@end

@implementation ViewController

@synthesize initialText;
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.


}
-(void)viewWillAppear:(BOOL)animated{
    
    [client setDelegate:self];
    
}
- (void)client:(CollabrifyClient *)client encounteredError:(CollabrifyError *)error{
    NSLog(@"%", error);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    [eventDelay invalidate]; eventDelay = nil;
    //make new timer, after 1.5sec user has stopped typing
    //register change
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    [dict setObject:text forKey:@"text"];
    [dict setObject:NSStringFromRange(range) forKey:@"range"];
    
    eventDelay = [NSTimer scheduledTimerWithTimeInterval:1.5
                                                  target:self
                                                selector:@selector(eventDelayFire:)
                                                userInfo:dict
                                                 repeats:NO];
    return YES;
}


// called when text view changes
// sets up timer to wait until user has stopped typing for 1.5 seconds,
// then calles eventDelayFire to fire event
- (void)textViewDidChange:(UITextView *)textView
{
}

//detect change from previous document content
-(void)eventDelayFire:(NSTimer *)t{
    assert(t == eventDelay);
    NSDictionary * dict = [eventDelay userInfo];
    
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesBegan:withEvent:");
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (IBAction)undo:(id)sender {
    [self.textView.undoManager undo];
    NSLog(@"undo");
}

// Redoing
- (IBAction)redo:(id)sender {
    [self.textView.undoManager redo];
    NSLog(@"redo");
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:


    (NSURLResponse *)response{
    /*
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    int code = [httpResponse statusCode];
    NSString *str;
    NSMutableString *myString = [NSMutableString string];
    str = [NSString stringWithFormat:@"%d", code];
    [myString appendString:str];
    NSLog(myString);
        */
}

- (IBAction)create:(id)sender {
    // Do any additional setup after loading the view, typically from a nib.
    /*
    NSURL *url = [NSURL URLWithString:@"http:\\collabrify-cloud.appspot.com/request"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:3.0];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"text/html" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:nil];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
    if (connection) {
        NSLog(@"done");
    }
    
    */
    NSString * name_tag = @"hello5";
    NSString * password_test = @"hello";
    
    NSString *test_name = @"CREATOR";
    NSError *error;
    NSArray *tags = [[NSArray alloc] initWithObjects:@"Some Tags", nil];

    client = [[CollabrifyClient alloc] initWithGmail:test_name
                       displayName:test_name
                      accountGmail:@"441fall2013@umich.edu"
                       accessToken:@"XY3721425NoScOpE"
                    getLatestEvent:NO
                             error:&error];
    // combination of tag/name needs to be unique
    
    
    [client createSessionWithName:name_tag
                             tags:tags
                         password:password_test
                      startPaused:NO
                completionHandler:^(int64_t sessionID, CollabrifyError * error)
                {
                    
                    if(!error){
                        NSLog(@"Session Successfully Created");
                        //[self performSegueWithIdentifier:@"createTheSession"sender:self];
                        bool test2 = [client isInSession];
                        
                        
                        if (test2) {
                            NSLog(@"is in session, and SESSION ID IS:");
                            int64_t session_ID = [client currentSessionID];
                            NSLog([NSString stringWithFormat:@"%lld", session_ID]);
                            int64_t participationID = [client participantID];
                            NSLog([NSString stringWithFormat:@"%lld", participationID]);
                            
                        }
                        else {
                            NSLog(@"is not in sessoin");
                            NSLog([error localizedDescription]);
                            
                        }
                    }
                    else{
                        NSLog(@"%@", error);
                        //[wholeScreen setHidden:YES];
                        //[visableObj setHidden:YES];
                        //[spinner stopAnimating];
                    }
                }];



    


}

- (IBAction)join:(id)sender {

    NSString *test = @"JOINER";
    NSError *error;
    
    client = [[CollabrifyClient alloc] initWithGmail:test
                                         displayName:test
                                        accountGmail:@"441fall2013@umich.edu"
                                         accessToken:@"XY3721425NoScOpE"
                                      getLatestEvent:NO
                                               error:&error];
    
    
    //JOIN SESSION;
    NSString * password_test = @"hello";
    bool startpause_test = TRUE;
    int64_t sessionID_test = 2291098;
    
    [client joinSessionWithID:sessionID_test
                      password:password_test
                   startPaused:startpause_test
             completionHandler:^(int64_t code, int32_t code2, CollabrifyError *error) {
                 
                 if (!error) {
                     NSLog(@"join completed");
                     
                     bool test2 = [client isInSession];
                     
                     
                     if (test2) {
                         NSLog(@"is in session, and SESSION ID IS:");
                         int64_t session_ID = [client currentSessionID];
                         NSLog([NSString stringWithFormat:@"%lld", session_ID]);
                     }
                     else {
                         NSLog(@"NOT IN SESSION");
                     }
                     
                 }
                 else {
                     NSLog(@"join not completed");
                 }
             }];
    
    
    
}

- (IBAction)exit:(id)sender {
    [client leaveAndDeleteSession:YES completionHandler:
     ^(BOOL success, CollabrifyError *error){
         if (success) {
             NSLog(@"logout completed");
         }
         else {
             NSLog(@"logout not completed");
         }
         
     }];
}


@end
