//
//  ViewController.h
//  Collabo
//
//  Created by milo kock on 9/6/13.
//  Copyright (c) 2013 441. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Collabrify/Collabrify.h>
#import "EventMessage.h"
#import <google/protobuf/io/zero_copy_stream_impl_lite.h>
#import <google/protobuf/io/coded_stream.h>

@interface ViewController : UIViewController <UITextViewDelegate, CollabrifyClientDataSource, CollabrifyClientDelegate>{
    NSMutableString * currentEventString;
    NSTimer * eventDelay;
    CollabrifyClient * client;
    NSMutableArray * undoStack;
    NSMutableArray * redoStack;
    int64_t participationID; // participation ID - set when user creates/join session
    int32_t cursorStart;
    int32_t cursorEnd;
    EventMessage * currentEvent;
    EventType currentEventType;
}


- (IBAction)undo:(id)sender;
- (IBAction)redo:(id)sender;

- (IBAction)create:(id)sender;
- (IBAction)join:(id)sender;

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)applyEvent:(EventMessage *)eventToApply;

@property (weak, nonatomic) IBOutlet UITextView *textView;


//NSData *dataForMessage(::google::protobuf::Message &message);
//NSData *parseDelimitedMessageFromData(::google::protobuf::Message &message, NSData *data);

//CollabrifyDataSource Methods

/**
 * Return the data offset by baseFilSize or nil if the size matches your base file's size
 *
 * @param client The client requesting the data source for a base file chunk.
 * @param baseFileSize The current size of the base file that has been uploaded
 * @return The base file chunk that the data source wants uploaded.
 * @warning Never returning nil from this method can result in an invite loop of uploading data and
 * receiving a request to continue uploading.
 * @warning Data is not requested on the main thread.
 */
- (NSData *)client:(CollabrifyClient *)client requestsBaseFileChunkForCurrentBaseFileSize:(NSInteger)baseFileSize;



//CollabrifyClientDelegate Methods

/**
 * Receive data from the session along with its orderID. Decode the data in an app-specific way
 *
 * @param client The client informing the delegate that it has received an event.
 * @param orderID The orderID of the event.
 * @param submissionRegistrationID The submission registration id of the event if the event originated from the client. If the event
 * originated on a remote client, this parameter will be -1.
 * @param eventType A string representing the type of the event. May be nil if the type is not set.
 * @param data The data representing the event.
 * @discussion CollabrifyClientReceivedEventNotification is posted with CollabrifyClientOrderIDKey and CollabrifyClientEventDataKey.
 *
 * If the incoming event did not originate from this client, submissionRegistrationID will be -1
 *
 * @warning This method is not called on the main thread. Any UI interaction needs to be done on the main thread
 */
- (void)client:(CollabrifyClient *)client receivedEventWithOrderID:(int64_t)orderID submissionRegistrationID:(int32_t)submissionRegistrationID eventType:(NSString *)eventType data:(NSData *)data;

/**
 * Called when the a chunk of base file is received or when all of the chunks have been received.
 * When all data has been received, data is nil.
 *
 * @param client The client informing the delegate that it has received a base file chunk.
 * @param data The base file chunk in data form.
 * @warning This method is not called on the main thread.
 */
- (void)client:(CollabrifyClient *)client receivedBaseFileChunk:(NSData *)data;

/**
 * Received upon successfully uploading a chunk of the base file
 *
 * @param client The client informing the delegate that the base file has been uploaded.
 * @param baseFileSize The size of the completed base file.
 * @discussion CollabrifyClientUploadedBaseFileNotification is posted with CollabrifyClientBaseFileSizeKey.
 * @warning This method is called on the main thread.
 */
- (void)client:(CollabrifyClient *)client uploadedBaseFileWithSize:(NSInteger)baseFileSize;

/**
 * Called when the session has been ended by its owner. You may still receive events, but you cannot broadcast.
 * Once you leave, you will be unable to rejoin the session.
 *
 * @param client The client informing the delegate that the session has ended.
 * @param sessionID The session id of the just ended session
 * @discussion CollabrifyClientSessionEnded notification is posted with CollabrifyClientSessionIDKey.
 * @warning Called on the main thread.
 */
- (void)client:(CollabrifyClient *)client endedSession:(int64_t)sessionID;

/**
 * Called when a participant has joined the session
 *
 * @param client The client informing the delegate that a participant has joined.
 * @param participant The participant that has just joined session.
 * @discussion CollabrifyClientParticipantJoinedNotification is posted with CollabrifyClientParticipantKey.
 * @warning Called on the main thread
 * @see CollabrifyParticipant
 */
- (void)client:(CollabrifyClient *)client participantJoined:(CollabrifyParticipant *)participant;

/**
 * Called when a participant has left the session
 *
 * @param client The client informing the delegate that a participant has left.
 * @param participant The participant that has just left the session.
 * @discussion CollabrifyClientParticipantLeftNotification is posted with CollabrifyClientParticipantKey.
 * @warning Called on the main thread
 * @see CollabrifyParticipant
 */
- (void)client:(CollabrifyClient *)client participantLeft:(CollabrifyParticipant *)participant;

/**
 * Pull the NSLocalizedDescriptionKey from the error's userInfo to understand the error.
 * Check CollabrifyError.h for domains and specific error codes
 *
 * @param client The client informing an object that an error occurred.
 * @param error An error object if an error occurrs. Otherwise this is nil.
 * @discussion CollabrifyClientEncounteredErrorNotification is posted with CollabrifyClientErrorKey.
 * @warning Always called on the main thread.
 * @see CollabrifyError
 */
- (void)client:(CollabrifyClient *)client encounteredError:(CollabrifyError *)error;

/**
 * Use Background Service methods from below here.
 * Always called after the AppDelegate methods and before the client has handled them
 *
 * @param client The client informing the delegate that it has entered the background.
 * @warning This is experimental and may cause strange behavior.
 */
- (void)clientDidEnterBackground:(CollabrifyClient *)client;


@end

