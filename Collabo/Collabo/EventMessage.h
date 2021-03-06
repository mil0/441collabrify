//
//  Message.h
//  Collabo
//
//  Created by milo kock on 9/23/13.
//  Copyright (c) 2013 441. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "textevent.h"
#import <google/protobuf/io/zero_copy_stream_impl_lite.h>
#import <google/protobuf/io/coded_stream.h>
@interface EventMessage : NSObject{
@public
    Event * event;
    int32_t submissionID;
    int32_t orderID;
}

-(void) initWithType:(EventType)type initialCursorLocation:(int)location newCursorLocation:(int)newLocation Length:(int)length Text:(NSString *)text id:(::google::protobuf::int64_t)user_id;

@end
