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
    undoStack = [[NSMutableArray alloc] initWithCapacity:30];
    redoStack = [[NSMutableArray alloc] initWithCapacity:30];
    cursorStart = 0;
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
    
    // get cursor
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
    
    //NSLog(@"Cursor Position before action: %d", cursorPosition);
    //NSLog(@"range.length before action: %d", range.length);
    //delete event
    if ([text isEqualToString:@""]){
        if (cursorPosition == 0 && range.length == 0) {
            return NO;
        }
        if (currentEvent->event->eventtype() == INSERT && [currentEventString length] > 0) {
            [self broadcastEvent:eventDelay];
        }
        currentEvent->event->set_eventtype(REMOVE);
        currentEventType = REMOVE;
        //Shouldn't this set event as REMOVE as well?
        //char deletedChar = [[_textView text] characterAtIndex:cursorPosition-1];
        
        
        //[currentEventString appendFormat:@"%c", deletedChar];
        unichar deletedChar = [[_textView text] characterAtIndex:cursorPosition-1];
        currentEventString = [[NSMutableString stringWithCharacters:&deletedChar length:1] stringByAppendingString:currentEventString];
        //[currentEventString appendFormat:@"%c", deletedChar];
        
        //deletion
        //NSLog(@"deleted");
        //NSLog(currentEventString);
    }
    else {
        //if you were deleting, you aren't anymore, so make discrete event
        if (currentEvent->event->eventtype() == REMOVE && [currentEventString length] > 0) {
            [self broadcastEvent:eventDelay];
        }
        currentEvent->event->set_eventtype(INSERT);
        currentEventType = INSERT;
        char appendedChar = [text characterAtIndex:0];
        [currentEventString appendFormat:@"%c", appendedChar];
    }
    
    return YES;
}

- (void)client:(CollabrifyClient *)client receivedEventWithOrderID:(int64_t)orderID submissionRegistrationID:(int32_t)submissionRegistrationID eventType:(NSString *)eventType data:(NSData *)data{
    EventMessage * received = [[EventMessage alloc] init];
    parseDelimitedEventFromData(*(received->event), data);
    if (received) {
        if (received->event->userid() != participationID) {
            NSLog(@"Data received %@", received);
            NSLog(@"Received text: %s", received->event->textadded().c_str());
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [self applyEvent:received];
            });
        }
    }
}

//broadcast event, add to appropriate stack
- (void)broadcastEvent:(NSTimer *)t{
    assert(t == eventDelay);
    NSLog(@"Event Fired");
    NSError *error;
    
    [currentEvent initWithType:currentEvent->event->eventtype()
         initialCursorLocation:cursorStart
             newCursorLocation:_textView.selectedRange.location
                        Length:[currentEventString length]
                          Text:currentEventString id:participationID];
    

    
    
    //reset cursor location
    cursorStart = _textView.selectedRange.location;
    //[self applyEvent:currentEvent];
    //add currentEvent to undo stack
    EventMessage * eventToBroadcast = currentEvent;
    if (eventToBroadcast->event->userid() == participationID) {
        [undoStack addObject:eventToBroadcast];
    }
    
    //broadcast event to other clients
    int32_t submissionID = [client broadcast:(dataForEvent(*(currentEvent->event))) eventType:@"INSERT"];
    
    //NSLog([NSString stringWithFormat:@"submissionID: %d", submissionID]);
    NSLog(@"Current Event String: %@", currentEventString);
    NSLog(@"Current Event Start Cursor Locaiton: %d", eventToBroadcast->event->initialcursorlocation());
    NSLog(@"Current Event Ending Cursor Locaiton: %d", eventToBroadcast->event->newcursorlocation());
    NSLog(@"Current Event Type: %d", eventToBroadcast->event->eventtype());
    
    //reset currentEventString
    currentEventString = [[NSMutableString alloc] init];
    currentEvent = [[EventMessage alloc] init];
    NSLog(@"Error message: %@", error);
    //NSLog(@"Number of Pending Events: %d", [client numberOfPendingEvents]);
}

- (void)applyEvent:(EventMessage *)eventToApply{
    //get event type, location, and string
    EventType type = eventToApply->event->eventtype();
    int32_t initial_location = eventToApply->event->initialcursorlocation();
    int32_t final_location = eventToApply->event->newcursorlocation();
    NSMutableString * text = [NSString stringWithCString:eventToApply->event->textadded().c_str() encoding:[NSString defaultCStringEncoding]];
    
    //get text before event
    NSString * textViewContent = [_textView text];
    NSRange range;
    range.location = initial_location;
    range.length = [text length];
    switch (type) {
        case INSERT:
        {
            NSString * before = [textViewContent substringToIndex:initial_location];
            NSString * after = [textViewContent substringFromIndex:initial_location];
            before = [before stringByAppendingString:text];
            before = [before stringByAppendingString:after];
            
            //insert the text in the appropriate spot
            NSString * newTextViewContent = before;
            _textView.text = newTextViewContent;
            
        }
            break;
        case REMOVE:
        {
            NSString * before = [textViewContent substringToIndex:final_location];
            NSString * after = [textViewContent substringFromIndex:initial_location];
            NSString * newTextViewContent = [before stringByAppendingString:after];
            _textView.text = newTextViewContent;
        }
            break;
        default:
            break;
    }
    cursorStart = _textView.selectedRange.location;

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesBegan:withEvent:");
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (EventMessage *)reverseEvent:(EventMessage *)event{
    EventMessage * reversed = [[EventMessage alloc] init];
    if (event->event->eventtype() == INSERT)
        reversed->event->set_eventtype(REMOVE);
    else if(event->event->eventtype() == REMOVE)
        reversed->event->set_eventtype(INSERT);

    reversed->event->set_initialcursorlocation(event->event->newcursorlocation());
    reversed->event->set_newcursorlocation(event->event->initialcursorlocation());
    reversed->event->set_changelength(event->event->changelength());
    reversed->event->set_userid(event->event->userid());
    reversed->event->set_textadded(event->event->textadded());
    
    return reversed;
    
}

- (IBAction)undo:(id)sender {
    
    //[self.textView.undoManager undo];
    NSLog(@"undo");
    if ([undoStack count] == 0) 
        return;
    
    
    EventMessage * reversed = [self reverseEvent:[undoStack lastObject]];
    [undoStack removeLastObject];
    [redoStack addObject:reversed];
    [self applyEvent:reversed];
}

// Redoing
- (IBAction)redo:(id)sender {
    //[self.textView.undoManager redo];
    NSLog(@"redo");
    if ([redoStack count] == 0) 
        return;
    EventMessage * reversed = [self reverseEvent:[redoStack lastObject]];
    [redoStack removeLastObject];
    [undoStack addObject:reversed];
    [self applyEvent:reversed];
    
}

- (IBAction)create:(id)sender {
    // Do any additional setup after loading the view, typically from a nib.

    NSString * name_tag = @"hello";
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
    bool startpause_test = FALSE;
    int64_t sessionID_test = 2433047;
    [client joinSessionWithID:sessionID_test
                      password:password_test
                   startPaused:startpause_test
             completionHandler:^(int64_t code, int32_t code2, CollabrifyError *error) {
                 
                 if (!error) {
                     NSLog(@"join completed");
                     NSLog(@"Delegate: %@", [client delegate]);
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

NSData *dataForEvent(::google::protobuf::Message &message)
{
    const int bufferLength = message.ByteSize() + ::google::protobuf::io::CodedOutputStream::VarintSize32(message.ByteSize());
    std::vector<char> buffer(bufferLength);
    
    ::google::protobuf::io::ArrayOutputStream arrayOutput(&buffer[0], bufferLength);
    ::google::protobuf::io::CodedOutputStream codedOutput(&arrayOutput);
    
    codedOutput.WriteVarint32(message.ByteSize());
    message.SerializeToCodedStream(&codedOutput);
    
    return [NSData dataWithBytes:&buffer[0] length:bufferLength];
}

NSData *parseDelimitedEventFromData(::google::protobuf::Message &message, NSData *data)
{
    ::google::protobuf::io::ArrayInputStream arrayInputStream([data bytes], [data length]);
    ::google::protobuf::io::CodedInputStream codedInputStream(&arrayInputStream);
    
    uint32_t messageSize;
    codedInputStream.ReadVarint32(&messageSize);
    
    //lets not consume all the data
    codedInputStream.PushLimit(messageSize);
    message.ParseFromCodedStream(&codedInputStream);
    codedInputStream.PopLimit(messageSize);
    
    if ([data length] - codedInputStream.CurrentPosition() > 0)
    {
        return [NSData dataWithBytes:((char *)[data bytes] + codedInputStream.CurrentPosition()) length:[data length] - codedInputStream.CurrentPosition()];
    }
    
    return nil;
}


@end
