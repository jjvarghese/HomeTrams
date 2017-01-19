//
//  Tram.h
//  HomeTime
//
//  Created by Joshua J. Varghese on 17/1/17.
//  Copyright © 2017 REA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tram : NSObject

@property (strong, nonatomic) NSString *tramArrivalTime;
@property (strong, nonatomic) NSString *tramRouteNumber;
@property (strong, nonatomic) NSString *tramDestination;

- (id)initWithRawData:(NSDictionary *)tramDict;

@end
