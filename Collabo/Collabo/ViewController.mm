//
//  ViewController.m
//  Collabo
//
//  Created by milo kock on 9/6/13.
//  Copyright (c) 2013 441. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UITextViewDelegate, CollabrifyClientDelegate, CollabrifyClientDataSource>
    
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
        
}
- (void)client:(CollabrifyClient *)client encounteredError:(CollabrifyError *)error{
    NSLog(@"Error received: %@", error);
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
    //make new timer, after 0.5sec user has stopped typing
    //register change
    
    eventDelay = [NSTimer scheduledTimerWithTimeInterval:20000
                                                  target:self
                                                selector:@selector(broadcastEvent:)
                                                userInfo:nil
                                                 repeats:NO];
    
    NSLog(@"Cursor Position before action: %d", cursorPosition);
    NSLog(@"range.length before action: %d", range.length);
    if ([text isEqualToString:@""]){
        if (cursorPosition == 0 && range.length == 0) {
            return NO;
        }
        if (currentEvent->event->eventtype() == INSERT) {
            [self broadcastEvent:eventDelay];
        }
        currentEvent->event->set_eventtype(REMOVE);
        //Shouldn't this set event as REMOVE as well?
        char deletedChar = [[_textView text] characterAtIndex:cursorPosition-1];
        [currentEventString appendFormat:@"%c", deletedChar];
        
        //deletion
        NSLog(@"deleted");
        NSLog(currentEventString);
    }
    else {
        //if you were deleting, you aren't anymore, so make discrete event
        if (currentEvent->event->eventtype() == REMOVE) {
            [self broadcastEvent:eventDelay];
        }
        currentEvent->event->set_eventtype(INSERT);
        char appendedChar = [text characterAtIndex:0];
        [currentEventString appendFormat:@"%c", appendedChar];
    }

 


    
    return YES;
}

- (void)client:(CollabrifyClient *)client receivedEventWithOrderID:(int64_t)orderID submissionRegistrationID:(int32_t)submissionRegistrationID eventType:(NSString *)eventType data:(NSData *)data{
    NSLog(@"Received Event");

    NSString * string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (string) {
        NSLog(@"String received %@", string);
        dispatch_async(dispatch_get_main_queue(), ^(void){
            //do stuff with string
        });
    }
}

//broadcast event, add to appropriate stack
-(void)broadcastEvent:(NSTimer *)t{
    assert(t == eventDelay);
    NSLog(@"Event Fired");
    [currentEvent initWithType:currentEvent->event->eventtype() CursorLocation:cursorLocation Length:[currentEventString length] Text:currentEventString id:participationID];
    int32_t success = [client broadcast:[currentEvent serializeEvent] eventType:@"INSERT"];
    NSLog([NSString stringWithFormat:@"Error Code: %d", success]);
    NSLog(@"Current Event String: %@", currentEventString);
    currentEventString = [[NSMutableString alloc] init];
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
    [client setDelegate:self];

    
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
                            int64_t session_ID = [client currentSessionID];
                            NSLog([NSString stringWithFormat:@"Session ID: %lld", session_ID]);
                            participationID = [client participantID]; // setting participation ID
                            NSLog([NSString stringWithFormat:@"Participation ID: %lld", participationID]);
                            
                            
                        }
                        else {
                            NSLog(@"is not in sessoin");
                            NSLog([error localizedDescription]);
                            
                        }
                    }
                    else{
                        NSLog(@"%@", error);
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
    
    
    [client setDelegate:self];

    
    //JOIN SESSION;
    NSString * password_test = @"hello";
    bool startpause_test = TRUE;
    int64_t sessionID_test = 2402002;
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
