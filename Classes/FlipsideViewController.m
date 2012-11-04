//
//  FlipsideViewController.m
//  Shiva
//
//  Created by Jaka Jančar on 10.1.09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "FlipsideViewController.h"

@implementation FlipsideViewController

@synthesize usernameTextField;
@synthesize passwordTextField;
@synthesize saveButton;

- (void)viewDidLoad
{
    self.usernameTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    self.passwordTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
    
    [self.usernameTextField addTarget:self action:@selector(textFieldChangedValue:) forControlEvents:UIControlEventEditingChanged];
    [self.passwordTextField addTarget:self action:@selector(textFieldChangedValue:) forControlEvents:UIControlEventEditingChanged];
}

- (void)textFieldChangedValue:(UITextField *)textField
{
    [[NSUserDefaults standardUserDefaults] setObject:self.usernameTextField.text forKey:@"username"];
    [[NSUserDefaults standardUserDefaults] setObject:self.passwordTextField.text forKey:@"password"];
    
    self.saveButton.enabled = ![self.usernameTextField.text isEqualToString:@""] && ![self.passwordTextField.text isEqualToString:@""];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.usernameTextField) {
        // Return clicked in username, focus on password
        [self.passwordTextField becomeFirstResponder];
    } else if (textField == self.passwordTextField) {
        // Return clicked in password
        if ([self.usernameTextField.text isEqualToString:@""]) {
            // Username is still empty, focus on username
            [self.usernameTextField becomeFirstResponder];
        } else {
            // Username is full, same as if done was clicked
            if (![self.passwordTextField.text isEqualToString:@""])
                [self doneButtonClicked];
        }
    }
    
    return NO;
}

- (IBAction)doneButtonClicked
{
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (void)dealloc
{
    [usernameTextField release];
    [passwordTextField release];
    [saveButton release];
    [super dealloc];
}


@end
