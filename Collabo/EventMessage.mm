//
//  EventMessage.m
//  Collabo
//
//  Created by milo kock on 9/12/13.
//  Copyright (c) 2013 441. All rights reserved.
//

#import "EventMessage.h"
#include "textevent.h"

@implementation EventMessage
- (void) doSomething {
    Event * event = new Event();
    event->set_eventtype(EventType(0));
}
@end
