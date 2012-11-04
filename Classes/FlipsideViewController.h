//
//  FlipsideViewController.h
//  Shiva
//
//  Created by Jaka Jančar on 10.1.09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlipsideViewController : UIViewController {
    UITextField *usernameTextField;
    UITextField *passwordTextField;
    UIButton *saveButton;
}

@property (nonatomic, retain) IBOutlet UITextField *usernameTextField;
@property (nonatomic, retain) IBOutlet UITextField *passwordTextField;
@property (nonatomic, retain) IBOutlet UIButton *saveButton;

- (IBAction)doneButtonClicked;

@end
