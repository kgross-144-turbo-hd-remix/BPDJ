//
//  DJLeagueViewController.m
//  BallparkDJ
//
//  Created by Timothy Goodson on 5/21/12.
//  Copyright (c) 2012 BallparkDJ. All rights reserved.
//

#import "DJLeagueViewController.h"

@interface DJLeagueViewController (){
    BOOL _isTeamEdit;
}
@property(retain, nonatomic) UIPopoverController* popoverController;
@end

@implementation DJLeagueViewController
@synthesize parentDelegate;
@synthesize theLeague;
@synthesize teamTable;
@synthesize teamNameViewController;
@synthesize splitViewController;
@synthesize popoverController;
@synthesize rowUnderEdit;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerNotifications];
    UILongPressGestureRecognizer* longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(editTeamName:)];
    longPressRecognizer.minimumPressDuration = 0.4;
    [teamTable addGestureRecognizer:longPressRecognizer];
    [longPressRecognizer release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self setTeamTable:nil];
    [self setParentDelegate:nil];
    [self setTheLeague:nil];
    [self setTeamNameViewController:nil];
    [self setSplitViewController:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UITextViewTextDidEndEditingNotification 
                                                  object:[[self teamNameViewController] teamNameTextField]];
    if (self.parentDelegate.ourLeague.dataChanged) {
        [self.parentDelegate.ourLeague saveData];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation = UIInterfaceOrientationPortrait);
    } else {
        return YES;
    }
}

-(void)registerNotifications{
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(handle_TextFieldDidEndEditing:)
                               name:UITextFieldTextDidEndEditingNotification
                             object:[[self teamNameViewController] teamNameTextField]];
}

-(void)handle_TextFieldDidEndEditing:(id)notification{

        if (!_isTeamEdit) {
            DJTeam* t = [[[DJTeam alloc] init] autorelease];
            [t setTeamName:[[[self teamNameViewController] teamNameTextField] text]];
            DJPlayer* p = [[[DJPlayer alloc] init] autorelease];
            [p setPlayerName:@"Default Player"];
            [t addPlayerToPlayers:p];
            [self.theLeague.theTeams addObject:t];
        } else {
            [[self.theLeague.theTeams objectAtIndex:self.rowUnderEdit.row] setTeamName:[[[self teamNameViewController] teamNameTextField] text]];
            self.rowUnderEdit = nil;
        } 
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissModalViewControllerAnimated:YES];
    } else {
        [self.popoverController dismissPopoverAnimated:YES];
    } 
    self.teamNameViewController = nil;
    [[self teamTable] reloadData];
    self.parentDelegate.ourLeague.dataChanged = YES;
}

- (NSInteger)numberOfSections
{
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableview numberOfRowsInSection:(NSInteger)section{
    return self.theLeague.theTeams.count;
}

-(UITableViewCell*)tableView :(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)path{
    
    NSString* cellIdentifier = @"teamCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }   
    
    NSString* teamName = [[self.theLeague.theTeams objectAtIndex:path.row] teamName];
    cell.textLabel.text = teamName;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath) {
        [self.parentDelegate switchViewToEdit:indexPath.row];
    }

    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
       [self.theLeague.theTeams removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        self.parentDelegate.ourLeague.dataChanged= YES;
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        //nothing
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{

    NSInteger newTeamRow = [self.theLeague.theTeams indexOfObject:[self.theLeague.theTeams lastObject]];
    NSIndexPath* lastTeamIndexPath = [NSIndexPath indexPathForRow:newTeamRow inSection:0];
    [self.theLeague.theTeams removeLastObject];
    [self.teamTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:lastTeamIndexPath] 
                          withRowAnimation:UITableViewRowAnimationFade];

    self.popoverController = nil;
}

-(void)assignData:(DJLeague *)theData{
    [self setTheLeague:theData];
}

- (IBAction)addNewTeam:(UIBarButtonItem *)sender {
    _isTeamEdit = NO;
    [self callTeamNamer];
}



-(void)editTeamName:(UIGestureRecognizer*)gestureRecognizer{
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint p = [gestureRecognizer locationInView:self.teamTable];
        self.rowUnderEdit = [self.teamTable indexPathForRowAtPoint:p];
        _isTeamEdit = YES;
        [self callTeamNamer];
    }

}

-(void)callTeamNamer{
    
    [self setTeamNameViewController:[[[DJTeamNameViewController alloc] initWithNibName:@"DJTeamNameViewController" bundle:nil] autorelease]];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self presentModalViewController:[self teamNameViewController] animated:YES];
    } else {
        popoverController = [[UIPopoverController alloc] initWithContentViewController:self.teamNameViewController];
        popoverController.delegate = self;
        [popoverController presentPopoverFromRect:CGRectMake((self.parentDelegate.window.bounds.size.width / 2) - 75, 250, 400, 300) 
                                           inView: self.teamTable 
                         permittedArrowDirections:(UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown)
                                         animated:YES];
    }
}

-(void)dealloc{
    [parentDelegate release];
    [theLeague release];
    [teamTable release];
    [teamNameViewController release];
    [splitViewController release];
    if (self.parentDelegate.ourLeague.dataChanged) {
        [self.parentDelegate.ourLeague saveData];
    }
    [super dealloc];
}
@end
