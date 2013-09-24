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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    currentEventString = [[NSMutableString alloc] init];
    currentEvent = [[EventMessage alloc] init];
    //turning autocorrection / auto-cap off
    _textView.autocorrectionType = UITextAutocorrectionTypeNo;
    _textView.autocapitalizationType = UITextAutocapitalizationTypeNone;


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

- (void)textViewDidChangeSelection:(UITextView *)textView {
    //unichar prevChar = [textView.text characterAtIndex:(location - 1)];
    //NSString *prevCharStr = [NSString stringWithFormat:@"%C", prevChar];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if(range.length > 1){
        return NO;
    }
    
    //get cursor
    NSUInteger cursorPosition = textView.selectedRange.location;
    // NSLog([NSString stringWithFormat:@"Cursor Position: %d", cursorPosition]);
    
    [eventDelay invalidate]; eventDelay = nil;
    //make new timer, after 1.5sec user has stopped typing
    //register change
    
    eventDelay = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                  target:self
                                                selector:@selector(broadcastEvent:)
                                                userInfo:nil
                                                 repeats:NO];
    
    
    if (range.length == 0) {
        //if you were deleting, you aren't anymore, so make discrete event
        if (currentEvent->event->eventtype() == REMOVE) {
            [self broadcastEvent:<#(NSTimer *)#>]
        }
        char appendedChar = [text characterAtIndex:0];
        [currentEventString appendFormat:@"%c", appendedChar];
    }
    else if (range.length == 1){
        //deletion
        NSLog(@"delete");
        char deletedChar = [[_textView text] characterAtIndex:cursorPosition-2];
        
    }
    else if(cursorPosition == 0){
        return NO;
    }
    
    return YES;
}

- (void)client:(CollabrifyClient *)client receivedEventWithOrderID:(int64_t)orderID submissionRegistrationID:(int32_t)submissionRegistrationID eventType:(NSString *)eventType data:(NSData *)data{
    
    NSString * string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (string) {
        NSLog(string);
        dispatch_async(dispatch_get_main_queue(), ^(void){
            //do stuff with string
        });
    }
}

// called when text view changes
// sets up timer to wait until user has stopped typing for 1.5 seconds,
// then calles eventDelayFire to fire event
- (void)textViewDidChange:(UITextView *)textView
{
    
}



//detect change from previous document content
-(void)broadcastEvent:(NSTimer *)t{
    assert(t == eventDelay);
    NSLog(@"Event Fired due to delay");
    [client broadcast:[currentEvent serializeEvent] eventType:@"INSERT"];

    NSLog(@"%@", currentEventString);
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

- (IBAction)create:(id)sender {
    // Do any additional setup after loading the view, typically from a nib.

    NSString * name_tag = @"hello6";
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
                            participationID = [client participantID]; // setting participation ID
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

    //tags are a whole string.
    //list session with tags - this is what is used for join session 
    
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
                         participationID = [client participantID]; // setting participationID
                     }
                     else {
                         NSLog(@"NOT IN SESSION");
                         NSLog(@"%@", error);
                     }
                     
                 }
                 else {
                     NSLog(@"join not completed");
                     NSLog(@"%@", error);
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
