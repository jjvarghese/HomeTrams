//
//  RestHelper.h
//  HomeTime
//
//  Created by Joshua J. Varghese on 17/1/17.
//  Copyright © 2017 REA. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const kBaseRestUrl = @"http://ws3.tramtracker.com.au/TramTracker/RestService";

@interface RestHelper : NSObject

+ (instancetype)sharedInstance;

- (void)loadTramApiResponseFromUrl:(NSString *)tramsUrl completion:(void (^)(NSArray *responseData, NSError *error))completion;
- (void)fetchApiToken:(void (^)(NSString *token, NSError *error))completion;

@end
