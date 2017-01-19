//
//  Helper.h
//  HomeTime
//
//  Created by Joshua J. Varghese on 17/1/17.
//  Copyright © 2017 REA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Helper : NSObject

+ (void)showGenericError:(UIViewController<UIAlertViewDelegate> *)vc;
+ (NSString *)getStopUrlFromStopId:(NSString *)stopId token:(NSString *)token;

@end
