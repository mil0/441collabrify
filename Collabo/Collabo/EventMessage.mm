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

-(BOOL) initWithType:(EventType)type CursorLocation:(int)location Length:(int)length Text:(NSString *)text
                  id:(::google::protobuf::int64_t)user_id{
    event->set_initialcursorlocation(location);
    event->set_eventtype(type);
    event->set_changelength(length);
    event->set_textadded([text UTF8String]);
    event->set_userid(user_id);
    return YES;
}

-(NSData *)serializeEvent{
    std::string ps = event->SerializeAsString();
    return [NSData dataWithBytes:ps.c_str() length:ps.size()];
}


/*
NSData *parseDelimitedMessageFromData(::google::protobuf::Message &message, NSData *data)
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

NSData *dataForMessage(::google::protobuf::Message &message)
{
    const int bufferLength = message.ByteSize() + ::google::protobuf::io::CodedOutputStream::VarintSize32(message.ByteSize());
    std::vector<char> buffer(bufferLength);
    
    ::google::protobuf::io::ArrayOutputStream arrayOutput(&buffer[0], bufferLength);
    ::google::protobuf::io::CodedOutputStream codedOutput(&arrayOutput);
    
    codedOutput.WriteVarint32(message.ByteSize());
    message.SerializeToCodedStream(&codedOutput);
    
    return [NSData dataWithBytes:&buffer[0] length:bufferLength];
}
*/



@end
