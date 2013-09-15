//
//  CollaboClient.h
//  Collabo
//
//  Created by milo kock on 9/15/13.
//  Copyright (c) 2013 441. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Collabrify/Collabrify.h>
@interface CollaboClient : NSObject
/**
 * Create a session without a base file and no participant limit.
 *
 * @param sessionName The name of the session being created. Needs to be unique.
 * @param tags The tags that represent the session being created.
 * @param password A password to protect the session being created. Pass nil if the session does not need a password
 * @param startPaused Tells the client whether or not to immediately pause all events upon creation.
 * @param completionHandler A completion block that passes back information after a session has been created.
 *
 * @discussion This creates a session with no participant limit.
 * @warning CreateSessionCompletionHanler is called on the main thread
 */
- (void)createSessionWithName:(NSString *)sessionName tags:(NSArray *)tags password:(NSString *)password startPaused:(BOOL)startPaused completionHandler:(CreateSessionCompletionHandler)completionHandler;
@end
