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

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesBegan:withEvent:");
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}


// Undoing
- (IBAction)undo:(id)sender {
    [self.textView.undoManager undo];
    NSLog(@"undo");
}

// Redoing
- (IBAction)redo:(id)sender {
    [self.textView.undoManager redo];
    NSLog(@"redo");
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:


    (NSURLResponse *)response{
    /*
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    int code = [httpResponse statusCode];
    NSString *str;
    NSMutableString *myString = [NSMutableString string];
    str = [NSString stringWithFormat:@"%d", code];
    [myString appendString:str];
    NSLog(myString);
        */
}

- (IBAction)create:(id)sender {
    // Do any additional setup after loading the view, typically from a nib.
    /*
    NSURL *url = [NSURL URLWithString:@"http:\\collabrify-cloud.appspot.com/request"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:3.0];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"text/html" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:nil];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
    if (connection) {
        NSLog(@"done");
    }
    
    */
    NSString * name_tag = @"hello";
    NSArray * tag_test = nil;
    NSString * password_test = @"hello";
    bool startpause_test = TRUE;
    
    NSString *test = @"bob";
    NSError *error;
    NSArray *tags = [[NSArray alloc] initWithObjects:@"Some Tags", nil];

    client = [[CollabrifyClient alloc] initWithGmail:test
                       displayName:test
                      accountGmail:@"441fall2013@umich.edu"
                       accessToken:@"XY3721425NoScOpE"
                    getLatestEvent:NO
                             error:&error];
    
    [client createSessionWithName:name_tag
                             tags:tags
                         password:password_test
                      startPaused:NO
                completionHandler:^(int64_t sessionID, CollabrifyError * error)
                {
                    
                    if(!error){
                        NSLog(@"Session Successfully Created");
                        //[self performSegueWithIdentifier:@"createTheSession"sender:self];
                    }
                    else{
                        NSLog(@"%@", error);
                        //[wholeScreen setHidden:YES];
                        //[visableObj setHidden:YES];
                        //[spinner stopAnimating];
                    }
                }];


    bool test2 = [client isInSession];


    if (test2) {
        NSLog(@"is in session");
    }
    else {
        NSLog(@"is not in sessoin");
        NSLog([error localizedDescription]);
        
    }
    
    
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

- (IBAction)join:(id)sender {
    //NSString * name_tag = @"hello";
    //NSArray * tag_test = nil;
    NSString * password_test = @"hello";
    bool startpause_test = TRUE;
    int64_t sessionID_test = 12;
    
    [client joinSessionWithID:sessionID_test
                      password:password_test
                   startPaused:startpause_test
             completionHandler:^(int64_t code, int32_t code2, CollabrifyError *error) {
                 NSLog(@"join completed");}];
}
@end
