//
//  DJTeamNameViewController.m
//  BallparkDJ
//
//  Created by Timothy Goodson on 5/26/12.
//  Copyright (c) 2012 BallparkDJ. All rights reserved.
//

#import "DJTeamNameViewController.h"

@interface DJTeamNameViewController ()

@end

@implementation DJTeamNameViewController
@synthesize teamNameTextField;

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
    [self.teamNameTextField becomeFirstResponder];
}

-(bool)textFieldShouldReturn:(UITextField*)textField{
    [textField resignFirstResponder];
    return NO;
}

- (void)viewDidUnload
{
    [self setTeamNameTextField:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return YES;
    }
}

@end
