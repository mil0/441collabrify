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
    sessionName = [[NSMutableString alloc] init];
    currentEvent = [[EventMessage alloc] init];
    undoStack = [[NSMutableArray alloc] initWithCapacity:30];
    redoStack = [[NSMutableArray alloc] initWithCapacity:30];
    globalStack = [[NSMutableArray alloc] initWithCapacity:60];
    myEvents = [[NSMutableDictionary alloc] init];
    cursorLocations = [[NSMutableDictionary alloc] init];
    //Alrt Views
    
    //Create Session Alert View
    createSessionAlert = [[UIAlertView alloc] initWithTitle:@"Create Session" message:@"Enter your session tag here." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create", nil];
    
    createSessionAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    createSessionAlert.tag = 0;
    
    //Error Occurred Alert View
    ErrorOccurred = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Unable to Create Session" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil , nil];
    ErrorOccurred.alertViewStyle = UIAlertViewStyleDefault;
    ErrorOccurred.tag = 1;
    
    
    participantJoined = [[UIAlertView alloc] initWithTitle:@"Participant Joined" message:@"" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil , nil];
    participantJoined.alertViewStyle = UIAlertViewStyleDefault;
    
    
    cursorStart = 0;
    //turning autocorrection / auto-cap off
    _textView.autocorrectionType = UITextAutocorrectionTypeNo;
    _textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    latest_orderID = 0;
    
    undo_trigger = false;
    redo_trigger = false;
    cursorMoveDistance = 0;
    
    //SET navigation controller TOOLBAR
    [self.navigationController setNavigationBarHidden:YES];
    
    //two buttons on rightside of navigation controller
    //self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: _undo2, _redo2, nil];

    
    //setting participationID when user enters
    //participationID = [client participantID];
    NSLog(@"Participation ID: %lld", participationID);
    
    
    [_undoButton setEnabled:NO];
    [_redoButton setEnabled:NO];
    
}


//setting/passing the client to ViewController
-(void) setClient:(CollabrifyClient*)client_segue {
    client = client_segue;
    [client setDelegate:self];
    participationID = [client participantID];
    NSLog(@"Participation ID: %lld", participationID);
}

- (void)client:(CollabrifyClient *)client participantJoined:(CollabrifyParticipant *)participant{
    [participantJoined show];
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
                         
                     }
                     else {
                         NSLog(@"is not in sessoin");
                         NSLog([error localizedDescription]);
                         
                     }
                 }
                 else{
                     NSLog(@"Error Recieved: %@", error);
                     [ErrorOccurred show];
                 }
             }];
        }
    }
}


-(void)viewWillAppear:(BOOL)animated
{
    
}

- (void)client:(CollabrifyClient *)client encounteredError:(CollabrifyError *)error{
    
    [ErrorOccurred show];
    NSLog(@"Let's be serious.");
    //NSLog(@"Error received: %@", error);
}

- (void)resetTimer
{
    [eventDelay invalidate]; eventDelay = nil;
    
    //make new timer, after 1.5sec user has stopped typing
    //register change
    eventDelay = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                  target:self
                                                selector:@selector(broadcastEvent:)
                                                userInfo:nil
                                                 repeats:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
// idea is, i can push a cursorChangeEvent
// this way, if cursors are after an event submitted, they can be updated to point to the correct place in everyone's cursor array
//called when selecting textView or moving cursor
- (void)textViewDidChangeSelection:(UITextView *)textView {
    if (cursorStart == _textView.selectedRange.location) {
        NSLog(@"cursorStart == textView.selectedRange.location");
    }
    /*//this is the first time you select the box
    [self resetTimer];
    if (cursorMoveDistance == 0 && cursorStart == 0) {
        NSLog(@"ima send some garbage data now, sheeeit");
        currentEventType = CURSORMOVE;
        currentEvent->event->set_eventtype(CURSORMOVE);
    }
    NSLog(@"I'm moving my cursor from: %d", cursorStart);
    int32_t cursorMovePosition = _textView.selectedRange.location;
    //if you're already moving your cursor, update the move event
    if (currentEvent->event->eventtype() == CURSORMOVE) {
        if (cursorStart < cursorMovePosition) {
            //increasing the position of the cursor if 
            cursorMoveDistance++;
        }
        else{
            cursorMoveDistance--;
        }
    }
    // if you're not moving your cursor, you're deleting or inserting,
    // so apply and broadcast that event (since shouldChangeTextInRange applies event automagically)
    else{
        [self broadcastEvent:eventDelay];
        cursorStart = _textView.selectedRange.location;
        //then begin a new CURSORMOVE event
        currentEventType = CURSORMOVE;
        currentEvent->event->set_eventtype(currentEventType);
    }*/
    cursorStart = _textView.selectedRange.location;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if(range.length > 1){
        return NO;
    }
    
    // get cursor
    NSUInteger cursorPosition = textView.selectedRange.location;
    //cursorStart = cursorPosition;
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
        
        unichar deletedChar = [[_textView text] characterAtIndex:cursorPosition-1];
        currentEventString = [[NSMutableString stringWithCharacters:&deletedChar length:1] stringByAppendingString:currentEventString];
    }
    else {
        //if you were deleting, you aren't anymore, so make discrete event
        if ((currentEvent->event->eventtype() == REMOVE && [currentEventString length] > 0) ||
            (currentEvent->event->eventtype() == CURSORMOVE && cursorMoveDistance != 0)) {
            
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
        //if event is not nil, add to queue
        NSLog(@"Received event with orderID: %lld", orderID);
        
        latest_orderID = orderID;
        
        NSMutableArray * tempStack = [[NSMutableArray alloc] init];
        NSLog(@"Data received %@", received);
        NSLog(@"Received text: %s", received->event->textadded().c_str());
        NSLog(@"Cursor Begin Location, %d", received->event->initialcursorlocation());
        NSLog(@"Cursor End Location, %d", received->event->newcursorlocation());
        NSLog(@"Event Type: %u", received->event->eventtype());
        NSLog(@"Event ParticipationID: %lld", received->event->userid());
        
        // check for conflict in globalStack[orderID]
        if ([globalStack count] > orderID && [globalStack count]) {
            EventMessage * possibleConflict = [globalStack objectAtIndex:orderID];
            
            if (possibleConflict->event->userid() != received->event->userid()) {
                //there's a conflict if the users for the two events are different
                int count = [globalStack count];
                while (count - orderID > 0) {
                    //pop off event, reapply
                    EventMessage * toUndo = [self reverseEvent:[globalStack lastObject]];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{[self applyEvent:toUndo];});
                    [tempStack addObject:[globalStack lastObject]];
                    [globalStack removeLastObject];
                    count--;
                }
                
                
            }
        }
        
        //apply event if it's not from your changeset
        if (received->event->userid() != participationID) {
            dispatch_async(dispatch_get_main_queue(), ^(void){
                //this is crashing if we apply while we are typing.
                [self applyEvent:received];
            });
            [globalStack addObject:received];

        }
        else if([tempStack count] > 0){
            while ([tempStack count]) {
                dispatch_async(dispatch_get_main_queue(), ^{[self applyEvent:[tempStack lastObject]];});
                [tempStack removeLastObject];
            }
        }
        else {
       
            if (undo_trigger) {
                //NSNumber * undo_ID = [NSNumber numberWithInt:orderID];
                [redoStack addObject:[NSNumber numberWithInteger:latest_orderID]];
                undo_trigger = false;
            }
            else if (redo_trigger){
                [undoStack addObject:[NSNumber numberWithInteger:latest_orderID]];
                redo_trigger = false;
            }
            else {
                [undoStack addObject:[NSNumber numberWithInteger:latest_orderID]];
            }
        }
    latest_orderID++;
    }
    
    if ([undoStack count]) {
        [_undoButton setEnabled:YES];
    }
    else {
        [_undoButton setEnabled:NO];
    }
    if ([redoStack count]) {
        [_redoButton setEnabled:YES];
    }
    else {
        [_redoButton setEnabled:NO];
    }
    
}

//broadcast event, add to appropriate stack
- (void)broadcastEvent:(NSTimer *)t{
    assert(t == eventDelay);
    NSLog(@"Event Fired");
    NSError *error;
    //initialize event with current member variables as of calling broadcastEvent
    [currentEvent initWithType:currentEvent->event->eventtype()
         initialCursorLocation:_textView.selectedRange.location - [currentEventString length]
             newCursorLocation:_textView.selectedRange.location
                        Length:[currentEventString length]
                          Text:currentEventString id:participationID];
    
    //this could use similar logic as above..
    if (currentEvent->event->eventtype() == REMOVE) {
        currentEvent->event->set_initialcursorlocation(_textView.selectedRange.location);
        currentEvent->event->set_newcursorlocation(_textView.selectedRange.location + [currentEventString length]);
    }
//    else if(currentEvent->event->eventtype() == CURSORMOVE){
//        if (cursorMoveDistance == 0) {
//            return;
//        }
//        currentEvent->event->set_changelength(cursorMoveDistance);
//        cursorMoveDistance = 0;
//        currentEvent->event->set_initialcursorlocation(cursorStart);
//    }
    
    
    
    //reset cursor location
    cursorStart = _textView.selectedRange.location;
    //[self applyEvent:currentEvent];
    //add currentEvent to undo stack
    EventMessage * eventToBroadcast = currentEvent;
//    if (eventToBroadcast->event->userid() == participationID) {
//        [undoStack addObject:[NSNumber numberWithInteger:latest_orderID]];
//    }
    
    //broadcast event to other clients
    int32_t submissionID = [client broadcast:(dataForEvent(*(currentEvent->event))) eventType:[NSString stringWithFormat:@"%d", currentEvent->event->eventtype()]];
    
    //NSLog([NSString stringWithFormat:@"submissionID: %d", submissionID]);
    NSLog(@"Current Event String: %@", currentEventString);
    NSLog(@"Current Event Start Cursor Locaiton: %d", eventToBroadcast->event->initialcursorlocation());
    NSLog(@"Current Event Ending Cursor Locaiton: %d", eventToBroadcast->event->newcursorlocation());
    NSLog(@"Current Event Type: %d", eventToBroadcast->event->eventtype());
    
    eventToBroadcast->orderID = latest_orderID++;
    eventToBroadcast->submissionID = submissionID;
    //add to global history, as well as myEvents dictionary
    [globalStack addObject:eventToBroadcast];
    [myEvents setObject:eventToBroadcast forKey:[NSString stringWithFormat:@"%d", submissionID]];
    
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
            NSString * before = [textViewContent substringToIndex:initial_location];
            NSString * after = [textViewContent substringFromIndex:final_location];
            NSString * newTextViewContent = [before stringByAppendingString:after];
            _textView.text = newTextViewContent;
        }
        case CURSORMOVE:
        {
            
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

    reversed->event->set_initialcursorlocation(event->event->initialcursorlocation());
    reversed->event->set_newcursorlocation(event->event->newcursorlocation());
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
    
    NSInteger undo_orderID = [[undoStack lastObject] integerValue];
    [undoStack removeLastObject];
    //[redoStack addObject:undo_orderID];
    
    EventMessage * undo_event = [globalStack objectAtIndex:undo_orderID];
    NSInteger undo_initcursorLocation = undo_event->event->initialcursorlocation();
    NSInteger undo_newcursorLocation = undo_event->event->newcursorlocation();
    
    NSInteger orderID_count = [globalStack count];
    
    //calculate the offset
    NSInteger begin = undo_orderID + 1;
    while (begin != orderID_count) {
        
        //update the undo cursor location
        EventMessage * check_event = [globalStack objectAtIndex:begin];
        
        if (check_event->event->initialcursorlocation() <= undo_initcursorLocation) {
            
            if (check_event->event->eventtype() == REMOVE) {
                undo_initcursorLocation -= check_event->event->changelength();
                undo_newcursorLocation -= check_event->event->changelength();
            }
            else {
                undo_initcursorLocation += check_event->event->changelength();
                undo_newcursorLocation += check_event->event->changelength();
            }
        }
        else if (check_event->event->initialcursorlocation() > undo_initcursorLocation &&
                 check_event->event->newcursorlocation() < undo_newcursorLocation){
        }
        
        begin++;
    }
    
    //reverse the event
    
    EventMessage * reversed_undo_event = [self reverseEvent:undo_event];
    
    reversed_undo_event->event->set_initialcursorlocation(undo_initcursorLocation);
    reversed_undo_event->event->set_newcursorlocation(undo_newcursorLocation);
    
    //broadcast the event
    
    //signal put new event in redo stack
    undo_trigger = true;
    
    reversed_undo_event->orderID = latest_orderID;
    latest_orderID++;
    
    int32_t submissionID = [client broadcast:(dataForEvent(*(reversed_undo_event->event))) eventType:[NSString stringWithFormat:@"%u", reversed_undo_event->event->eventtype()]];
    //this has to happen because broadcast will not applyevent for you
    reversed_undo_event->submissionID = submissionID;
    [self applyEvent:reversed_undo_event];
    [globalStack addObject:reversed_undo_event];
    [myEvents setObject:reversed_undo_event forKey:[NSString stringWithFormat:@"%d", submissionID]];
    
}

// Redoing
- (IBAction)redo:(id)sender {
    //[self.textView.undoManager redo];
    NSLog(@"redo");
    if ([redoStack count] == 0) 
        return;
    
    NSInteger redo_orderID = [[redoStack lastObject] integerValue];
    [redoStack removeLastObject];
    //[redoStack addObject:undo_orderID];
    
    EventMessage * redo_event = [globalStack objectAtIndex:redo_orderID];
    NSInteger redo_initcursorLocation = redo_event->event->initialcursorlocation();
    NSInteger redo_newcursorLocation = redo_event->event->newcursorlocation();
    
    NSInteger orderID_count = [globalStack count];
    
    //calculate the offset
    NSInteger begin = redo_orderID + 1;
    while (begin != orderID_count) {
        
        //update the undo cursor location
        EventMessage * check_event = [globalStack objectAtIndex:begin];
        
        if (check_event->event->initialcursorlocation() <= redo_initcursorLocation) {
            
            if (check_event->event->eventtype() == REMOVE) {
                redo_initcursorLocation -= check_event->event->changelength();
                redo_newcursorLocation -= check_event->event->changelength();
            }
            else {
                redo_initcursorLocation += check_event->event->changelength();
                redo_newcursorLocation += check_event->event->changelength();
            }
        }
        else if (check_event->event->initialcursorlocation() > redo_initcursorLocation &&
                 check_event->event->newcursorlocation() < redo_newcursorLocation){
        }
        
        begin++;
    }
    
    //reverse the event
    
    EventMessage * reversed_redo_event = [self reverseEvent:redo_event];
    
    reversed_redo_event->event->set_initialcursorlocation(redo_initcursorLocation);
    reversed_redo_event->event->set_newcursorlocation(redo_newcursorLocation);
    
    //broadcast the event
    
    //signal put new event in redo stack
    redo_trigger = true;
    reversed_redo_event->orderID = latest_orderID;
    latest_orderID++;

    
    int32_t submissionID = [client broadcast:(dataForEvent(*(reversed_redo_event->event))) eventType:[NSString stringWithFormat:@"%u", reversed_redo_event->event->eventtype()]];
    reversed_redo_event->submissionID = submissionID;
    //this has to happen because broadcast will not applyevent for you
    [self applyEvent:reversed_redo_event];
    [globalStack addObject:reversed_redo_event];
    [myEvents setObject:reversed_redo_event forKey:[NSString stringWithFormat:@"%d", submissionID]];
    //[client broadcast:dataForEvent(reversed_undo_event) eventType:reversed_undo_event->event->eventtype()];
    
    
}

- (IBAction)create:(id)sender {
    // Do any additional setup after loading the view, typically from a nib.

    NSString * name_tag = @"oijerg";
    NSString * password_test = @"hello";
    
    NSString *test_name = @"CREATOR";
    NSError *error;
    NSArray *tags = [[NSArray alloc] initWithObjects:@"Some Tags", nil];
    
    [createSessionAlert show];
    
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
    int64_t sessionID_test = 2436070;
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
//NOT WORKING?? DONT KNOW WHY!


- (IBAction)exit2:(id)sender {
    [client leaveAndDeleteSession:YES completionHandler:
     ^(BOOL success, CollabrifyError *error){
         if (success) {
             NSLog(@"logout completed");
         }
         else {
             NSLog(@"logout not completed");
             NSLog(@"Error received, %@", error);
         }
         
     }];
    
    [self performSegueWithIdentifier:@"segue.main.push" sender:self];
    
    
    
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
