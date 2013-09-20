//
//  ViewController.m
//  Collabo
//
//  Created by milo kock on 9/6/13.
//  Copyright (c) 2013 441. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize initialText;
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    [eventDelay invalidate]; eventDelay = nil;
    //make new timer, after 1.5sec user has stopped typing
    //register change
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    [dict setObject:text forKey:@"text"];
    [dict setObject:NSStringFromRange(range) forKey:@"range"];
    
    eventDelay = [NSTimer scheduledTimerWithTimeInterval:1.5
                                                  target:self
                                                selector:@selector(eventDelayFire:)
                                                userInfo:dict
                                                 repeats:NO];
    return YES;
}


// called when text view changes
// sets up timer to wait until user has stopped typing for 1.5 seconds,
// then calles eventDelayFire to fire event
- (void)textViewDidChange:(UITextView *)textView
{
}

//detect change from previous document content
-(void)eventDelayFire:(NSTimer *)t{
    assert(t == eventDelay);
    NSDictionary * dict = [eventDelay userInfo];
    
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesBegan:withEvent:");
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}


// Undoing
- (IBAction)join:(id)sender {
}

- (IBAction)undo:(id)sender {
    [self.textView.undoManager undo];
}

// Redoing
- (IBAction)redo:(id)sender {
    [self.textView.undoManager redo];
}

- (IBAction)create:(id)sender {

}

@end
