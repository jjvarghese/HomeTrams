//
//  TramCell.h
//  HomeTime
//
//  Created by Joshua J. Varghese on 17/1/17.
//  Copyright © 2017 REA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TramCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *arrivalTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeEstimationLabel;
@property (strong, nonatomic) IBOutlet UILabel *arrivalTextLabel;
@property (strong, nonatomic) IBOutlet UIView *wrapperView;
@property (strong, nonatomic) IBOutlet UILabel *loadText;

@end
