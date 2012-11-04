//
//  QuotaCell.h
//  Shiva
//
//  Created by Jaka Jancar on 10/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Quota;

@interface QuotaCell : UIView {
    Quota *quota;
    
    UILabel *descriptionLabel;
    UILabel *progressLabel;
    UIImageView *progressBar;
}

@property (nonatomic, retain) Quota *quota;

@property (nonatomic, retain) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, retain) IBOutlet UILabel *progressLabel;
@property (nonatomic, retain) IBOutlet UIImageView *progressBar;

@end
