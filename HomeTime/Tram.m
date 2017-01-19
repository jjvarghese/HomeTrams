//
//  Tram.m
//  HomeTime
//
//  Created by Joshua J. Varghese on 17/1/17.
//  Copyright © 2017 REA. All rights reserved.
//

#import "Tram.h"

NSString * const kTramKeyRouteNumber = @"RouteNo";
NSString * const kTramKeyDestination = @"Destination";
NSString * const kTramKeyArrivalTime = @"PredictedArrivalDateTime";

@implementation Tram

- (id)initWithRawData:(NSDictionary *)tramDict {
    self = [super init];
    
    self.tramArrivalTime = [NSString stringWithFormat:@"%@", [tramDict objectForKey:kTramKeyArrivalTime]];
    self.tramDestination = [NSString stringWithFormat:@"%@", [tramDict objectForKey:kTramKeyDestination]];
    self.tramRouteNumber = [NSString stringWithFormat:@"%@", [tramDict objectForKey:kTramKeyRouteNumber]];

    return self;
}

@end
