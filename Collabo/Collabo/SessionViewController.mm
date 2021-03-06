//
//  SessionViewController.m
//  Collabo
//
//  Created by Joshua Yu on 9/20/13.
//  Copyright (c) 2013 441. All rights reserved.
//

#import "SessionViewController.h"


@interface SessionViewController ()

@end

@implementation SessionViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}




- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.navigationController setNavigationBarHidden:NO];
    NSLog(@"Number of sessions: %d", [sessionList count]);
    NSLog(@"Session ID: %lld", [[sessionList objectAtIndex:0] sessionID]);
    NSLog(@"Session Name: %@", [[sessionList objectAtIndex:0] sessionName]);

}

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        [self.navigationController setNavigationBarHidden:YES];
    }
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [sessionList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    // UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault)
                                                   reuseIdentifier:@"cell"];
    CollabrifySession * session = [sessionList objectAtIndex:[indexPath row]];
    NSLog(@"Session Name: %@", [session sessionName]);
    cell.textLabel.text = [session sessionName];
    
    return cell;
}

- (void) setSessionList:(NSArray *)list{
    sessionList = list;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    
    NSString * password_test = nil;
    bool startpause_test = FALSE;
    int64_t sessionID_test = 2436070;
    [client joinSessionWithID:[[sessionList objectAtIndex:[indexPath row]] sessionID]
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
                        NSLog(@"Participation ID: %lld", participationID);
                        [self performSegueWithIdentifier:@"segue.join2" sender:self];

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([[segue identifier] isEqualToString:@"segue.join2"]){
        [segue.destinationViewController setClient:client];
    }
}


//setting/passing the client to ViewController
-(void) setClient:(CollabrifyClient*)client_segue {
    client = client_segue;
    //[client setDelegate:self];
    //participationID = [client participantID];
}
@end
