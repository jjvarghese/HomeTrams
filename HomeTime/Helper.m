//
//  Helper.m
//  HomeTime
//
//  Created by Joshua J. Varghese on 17/1/17.
//  Copyright © 2017 REA. All rights reserved.
//

#import "Helper.h"
#import "RestHelper.h"

@implementation Helper

#pragma mark -
#pragma mark Public
#pragma mark -

+ (void)showGenericError:(UIViewController<UIAlertViewDelegate> *)vc {
    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                             message:@"Something went wrong retrieving the trams. Please try again later and contact support if the problem persists."
                                                            delegate:vc
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil, nil];
    
    [errorAlertView show];
}

+ (NSString *)getStopUrlFromStopId:(NSString *)stopId token:(NSString *)token {
    NSString *urlTemplate = [NSString stringWithFormat:@"%@/GetNextPredictedRoutesCollection/{STOP_ID}/78/false/?aid=TTIOSJSON&cid=2&tkn={TOKEN}", kBaseRestUrl];
    
    return [[urlTemplate stringByReplacingOccurrencesOfString:@"{STOP_ID}" withString:stopId] stringByReplacingOccurrencesOfString:@"{TOKEN}" withString:token];
}

@end
