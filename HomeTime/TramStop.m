//
//  TramStop.m
//  HomeTime
//
//  Created by Joshua J. Varghese on 17/1/17.
//  Copyright © 2017 REA. All rights reserved.
//

#import "TramStop.h"

@implementation TramStop

- (id)initWithId:(NSString *)stopId
         andName:(NSString *)name {
    self = [super init];
    
    self.tramStopId = stopId;
    self.tramStopName = name;
    
    return self;
}

@end
