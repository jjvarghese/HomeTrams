//
//  RestHelper.m
//  HomeTime
//
//  Created by Joshua J. Varghese on 17/1/17.
//  Copyright © 2017 REA. All rights reserved.
//

#import "RestHelper.h"

const char * backgroundQueue = "hometimebg";
NSString * const kDeviceToken = @"DeviceToken";

@interface RestHelper()

@property (strong, nonatomic) NSURLSession *session;

@end

@implementation RestHelper

#pragma mark -
#pragma mark Public
#pragma mark -

+ (instancetype)sharedInstance {
    static RestHelper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[RestHelper alloc] init];
        
        sharedInstance.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                               delegate:nil
                                                          delegateQueue:[NSOperationQueue mainQueue]];
    });
    
    return sharedInstance;
}

- (void)loadTramApiResponseFromUrl:(NSString *)tramsUrl completion:(void (^)(NSArray *responseData, NSError *error))completion {
    dispatch_async(dispatch_queue_create(backgroundQueue, NULL), ^{
        NSURLSessionDataTask *task = [[RestHelper sharedInstance].session dataTaskWithURL:[NSURL URLWithString:tramsUrl]
                                                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *requestError) {
                                                                            if (requestError != nil) {
                                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                                    completion(nil, requestError);
                                                                                });
                                                                            } else {
                                                                                NSError *jsonError = nil;
                                                                                NSDictionary *jsonRespsone = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error:&jsonError];
                                                                                
                                                                                if (jsonRespsone == nil) {
                                                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                                                        completion(nil, jsonError);
                                                                                    });
                                                                                } else {
                                                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                                                        completion(jsonRespsone[@"responseObject"], nil);
                                                                                    });
                                                                                }
                                                                            }
                                                                        }];
        [task resume];
    });
}

- (void)fetchApiToken:(void (^)(NSString *token, NSError *error))completion {
    dispatch_async(dispatch_queue_create(backgroundQueue, NULL), ^{
        NSString *tokenUrl = [NSString stringWithFormat:@"%@/GetDeviceToken/?aid=TTIOSJSON&devInfo=HomeTimeiOS", kBaseRestUrl];
        
        [[RestHelper sharedInstance] loadTramApiResponseFromUrl:tokenUrl
                                                     completion:^(NSArray *response, NSError *error) {
                                                         NSDictionary *tokenObject = response.firstObject;
                                                         NSString *token = tokenObject[kDeviceToken];
                                                         
                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                             completion(token, error);
                                                         });
                                                     }];
    });
}

@end
