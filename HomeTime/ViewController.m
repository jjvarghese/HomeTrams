//
//  Copyright (c) 2015 REA. All rights reserved.
//

#import "ViewController.h"
#import "RestHelper.h"
#import "Helper.h"
#import "TramSectionHeader.h"
#import "TramCell.h"
#import "Tram.h"
#import "TramStop.h"
#import "HomeTime-Swift.h"

NSString * const kCellIdentifier = @"tramCellIdentifier";

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tramTimesTable;
@property (strong, nonatomic) NSArray<NSArray *> *trams;
@property (strong, nonatomic) NSArray<TramStop *> *stops;
@property (strong, nonatomic) NSMutableDictionary *tramsLoading;
@property (assign, nonatomic) BOOL errorShowing;
@property (copy, nonatomic) NSString *token;
@property (strong, nonatomic) UIRefreshControl *pullRefresh;

@end

@implementation ViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.stops = @[[[TramStop alloc] initWithId:kNorthId andName:@"Northbound"],
                   [[TramStop alloc] initWithId:kSouthId andName:@"Southbound"]];
    
    [self setupTable];
    [self clearTramData];
    [self loadTramData];
}

#pragma mark - Actions


- (void)loadTramData {
    [self toggleLoadForAllSections:YES];
    
    if (self.token) {
        NSLog(@"Existing token: %@", self.token);
        
        [self populateTramData];
    } else {
        [[RestHelper sharedInstance] fetchApiToken:^(NSString *token, NSError *error) {
            if (error) {
                [self toggleLoadForAllSections:NO];
                
                [self handleBasicError:error];
                
                NSLog(@"Error retrieving token: %@", error);
            } else {
                self.token = token;
                
                NSLog(@"New Token: %@", self.token);
                
                [self populateTramData];
            }
        }];
    }
}

- (NSArray *)convertRawTramsToTramObjects:(NSArray *)tramDicts {
    NSMutableArray *tramsToReturn = [NSMutableArray array];
    
    for (NSDictionary *tramDict in tramDicts) {
        Tram *tram = [[Tram alloc] initWithRawData:tramDict];
        
        [tramsToReturn addObject:tram];
    }
    
    return tramsToReturn;
}

- (void)populateTramData {
    for (TramStop *stop in self.stops) {
        [[RestHelper sharedInstance] loadTramApiResponseFromUrl:[Helper getStopUrlFromStopId:stop.tramStopId token:self.token]
                                                     completion:^(NSArray *trams, NSError *error) {
                                                         [self.tramsLoading setObject:@NO forKey:stop.tramStopId];
                                                         
                                                         if (error) {
                                                             [self handleBasicError:error];
                                                             
                                                             return;
                                                         } else {
                                                             NSArray *convertedTrams = [self convertRawTramsToTramObjects:trams];
                                                             
                                                             NSMutableArray *tempTramSections = [self.trams mutableCopy];
                                                             
                                                             [tempTramSections addObject:convertedTrams];
                                                             
                                                             self.trams = tempTramSections;
                                                             
                                                             [self refresh];
                                                         }
                                                     }];
    }
}

- (IBAction)clearButtonTapped:(UIBarButtonItem *)sender {
    [self clearTramData];
}

- (void)clearTramData {
    self.trams = [NSArray array];
    self.tramsLoading = [NSMutableDictionary dictionary];
    
    [self toggleLoadForAllSections:NO];
  
    [self.tramTimesTable reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.stops.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    TramSectionHeader *header = [[[NSBundle mainBundle] loadNibNamed:@"TramSectionHeader" owner:self options:nil] lastObject];
    
    if ([self tramSectionIsValid:section]) {
        NSArray *tramSection = [self.trams objectAtIndex:section];
        
        Tram *tramSample = [tramSection firstObject];
        header.routeNumberLabel.text = tramSample.tramRouteNumber;
        header.destinationLabel.text = tramSample.tramDestination;
    } else {
        TramStop *stop = [self.stops objectAtIndex:section];
        
        header.routeNumberLabel.text = @"";
        header.destinationLabel.text = @"";
        header.routeLabel.text = stop.tramStopName;
    }
    
    return header;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self tramSectionIsValid:section]) {
        NSArray *tramSection = [self.trams objectAtIndex:section];
        
        return tramSection.count;
    } else {
        return 1;
    }
}

- (TramCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TramCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
  
    BOOL populatedTable = [self tramSectionIsValid:indexPath.section];
    
    cell.wrapperView.hidden = !populatedTable;
    
    TramStop *stop = [self.stops objectAtIndex:indexPath.section];
    
    if (populatedTable) {
        NSArray *trams = [self.trams objectAtIndex:indexPath.section];

        Tram *tram = trams[indexPath.row];
        NSString *arrivalDateString = tram.tramArrivalTime;
        DotNetDateConverter *dateConverter = [[DotNetDateConverter alloc] init];
        
        NSDate *arrivalDate = [dateConverter dateFromDotNetFormattedDateString:arrivalDateString];
        
        NSTimeInterval differenceInMinutes = ([arrivalDate timeIntervalSinceDate:[NSDate date]]) / 60;
        
        cell.arrivalTimeLabel.text = [dateConverter formattedDateFromString:arrivalDateString];
        cell.arrivalTextLabel.text = @"ARRIVAL";
        cell.timeEstimationLabel.text = [NSString stringWithFormat:@"(%.0f minutes from now)", differenceInMinutes];
        cell.loadText.text = @"";
    } else if ([[self.tramsLoading objectForKey:stop.tramStopId] boolValue]) {
        cell.loadText.text = @"LOADING...";
    } else {
        cell.loadText.text = @"<< Pull down to load trams >>";
    }
  
    return cell;
}

#pragma mark UIAlertViewDelegate

// Error dialog flag reset
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    self.errorShowing = NO;
    
    [self.pullRefresh endRefreshing];
}

#pragma mark Misc/Convenience

- (void)setupTable {
    self.pullRefresh = [[UIRefreshControl alloc] init];
    [self.tramTimesTable addSubview:self.pullRefresh];
    [self.tramTimesTable registerNib:[UINib nibWithNibName:@"TramCell" bundle:nil] forCellReuseIdentifier:kCellIdentifier];
    [self.pullRefresh addTarget:self action:@selector(loadTramData) forControlEvents:UIControlEventValueChanged];
}

- (void)showError {
    [Helper showGenericError:self];
}

- (void)handleBasicError:(NSError *)error {
    [self.pullRefresh endRefreshing];
    
    if (error) {
        NSLog(@"Error retrieving trams: %@", error);
    }

    if (!self.errorShowing) {
        self.errorShowing = YES;
        
        [self performSelector:@selector(showError) withObject:nil afterDelay:0.2f];
    }
}

- (void)refresh {
    [self.pullRefresh endRefreshing];
    [self.tramTimesTable reloadData];
}

- (void)toggleLoadForAllSections:(BOOL)isLoading {
    for (TramStop *stop in self.stops) {
        [self.tramsLoading setObject:isLoading ? @YES : @NO forKey:stop.tramStopId];
    }
}

- (BOOL)tramSectionIsValid:(NSInteger)index {
    return (self.trams && (self.trams.count > index));
}

@end
