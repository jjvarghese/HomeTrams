#import <Kiwi/Kiwi.h>
#import "RestHelper.h"
#import "ViewController.h"
#import "TramStop.h"
#import "Tram.h"
#import "TramSectionHeader.h"
#import "Helper.h"

@interface ViewController (Spec) <UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tramTimesTable;
@property (strong, nonatomic) NSArray<NSArray *> *trams;
@property (strong, nonatomic) NSArray<TramStop *> *stops;
@property (strong, nonatomic) NSMutableDictionary *tramsLoading;
@property (copy, nonatomic) NSString *token;
@property (assign, nonatomic) BOOL errorShowing;

- (void)clearTramData;
- (void)loadTramData;
- (void)handleBasicError:(NSError *)error;

@end

SPEC_BEGIN(ViewControllerSpec)
  describe(@"ViewController", ^{
    __block ViewController *viewController;
      
      beforeEach(^{
          UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
          viewController = [storyboard instantiateViewControllerWithIdentifier:@"viewController"];

          [viewController view];
          [viewController tramTimesTable];

      });

      it(@"Should have sections for each stop ID", ^{
          NSInteger sections = [viewController.tramTimesTable numberOfSections];
          [[theValue(sections) should] equal:@(viewController.stops.count)];
      });

      it (@"Should have its API able to retrieve a token", ^{
          [[RestHelper sharedInstance] fetchApiToken:^(NSString *token, NSError *error) {
              [[error should] beNil];
            }];
      });
      
      it (@"Should flag itself as showing an error when an error occurs", ^{
          [viewController handleBasicError:nil];
          
          [[theValue(viewController.errorShowing) should] beTrue];
      });
      
      it (@"Should create a corresponding dictionary of loading flags for each stop", ^{
          [viewController loadTramData];
          
          [[theValue(viewController.tramsLoading.count) should] equal:@(viewController.stops.count)];
          
          for (TramStop *stop in viewController.stops) {
              NSNumber *isLoading = [viewController.tramsLoading objectForKey:stop.tramStopId];
              
              [[isLoading should] beNonNil];
          }
      });
      
      it (@"Each stop should have a tram name associated with it", ^{
          for (TramStop *stop in viewController.stops) {
              BOOL hasName = NO;
              
              if (stop.tramStopName && stop.tramStopName.length > 0) {
                  hasName = YES;
              }

              [[theValue(hasName) should] beTrue];
          }
      });
      
      it (@"Should be able to clear tram data", ^{
          [viewController clearTramData];
          
          [[viewController.trams should] beEmpty];
          
          NSInteger section = [viewController.tramTimesTable numberOfSections] - 1;
          
          while (section > -1) {
              NSInteger rows = [viewController.tramTimesTable numberOfRowsInSection:section];
              
              [[theValue(rows) should] equal:@1];

              section--;
          }
      });
      
      it (@"should have its API able to successfully get trams from all stops", ^{
          for (TramStop *stop in viewController.stops) {
              [[RestHelper sharedInstance] fetchApiToken:^(NSString *token, NSError *error) {
                  [[RestHelper sharedInstance] loadTramApiResponseFromUrl:[Helper getStopUrlFromStopId:stop.tramStopId token:token]
                                                               completion:^(NSArray *trams, NSError *error) {
                                                                   [[error should] beNil];
                                                                   [[trams shouldNot] beEmpty];
                                                               }];
              }];
          }
      });
      
  });
SPEC_END
