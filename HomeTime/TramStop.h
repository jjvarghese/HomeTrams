//
//  TramStop.h
//  HomeTime
//
//  Created by Joshua J. Varghese on 17/1/17.
//  Copyright © 2017 REA. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const kNorthId = @"4055";
static NSString * const kSouthId = @"4155";

@interface TramStop : NSObject

- (id)initWithId:(NSString *)stopId
         andName:(NSString *)name;

@property (strong, nonatomic) NSString *tramStopName;
@property (strong, nonatomic) NSString *tramStopId;

@end
