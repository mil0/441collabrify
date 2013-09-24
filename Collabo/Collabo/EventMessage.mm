//
//  Message.m
//  Collabo
//
//  Created by milo kock on 9/23/13.
//  Copyright (c) 2013 441. All rights reserved.
//

#import "EventMessage.h"
#import "textevent.h"
@implementation EventMessage

-(id)init{
    self = [super init];
    if (self) {
        event = new Event();
    }
    return self;
}

-(void) initWithType:(EventType)type CursorLocation:(int)location Length:(int)length Text:(NSString *)text
                  id:(::google::protobuf::int64_t)user_id{
    event->set_initialcursorlocation(location);
    event->set_eventtype(type);
    event->set_changelength(length);
    event->set_textadded([text UTF8String]);
    event->set_userid(user_id);
}

-(NSData *)serializeEvent{
    std::string ps = event->SerializeAsString();
    return [NSData dataWithBytes:ps.c_str() length:ps.size()];
}



@end
