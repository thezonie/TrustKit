/*
 
 AppDelegate.m
 TrustKitDemo
 
 Copyright 2015 The TrustKit Project Authors
 Licensed under the MIT license, see associated LICENSE file for terms.
 See AUTHORS file for the list of project authors.
 
 */

#import "AppDelegate.h"
#import <TrustKit/TrustKit.h>
#import <TrustKit/TSKPinningValidator.h>
#import <TrustKit/TSKPinningValidatorResult.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Override TrustKit's logger method
    // FIXME: logger
//    void (^loggerBlock)(NSString *) = ^void(NSString *message)
//    {
//        NSLog(@"TrustKit log: %@", message);
//    };
//    [TrustKit setLoggerBlock:loggerBlock];
    
    
    // Initialize TrustKit
    NSDictionary *trustKitConfig =
    @{
      // Do not auto-swizzle NSURLSession delegates
      kTSKSwizzleNetworkDelegates: @NO,
      
      kTSKPinnedDomains: @{
              
              // Pin invalid SPKI hashes to *.yahoo.com to demonstrate pinning failures
              @"yahoo.com": @{
                      kTSKEnforcePinning: @YES,
                      kTSKIncludeSubdomains: @YES,
                      kTSKPublicKeyAlgorithms: @[kTSKAlgorithmRsa2048],
                      
                      // Wrong SPKI hashes to demonstrate pinning failure
                      kTSKPublicKeyHashes: @[
                              @"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=",
                              @"BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB="
                              ],
                      
                      // Send reports for pinning failures
                      // Email info@datatheorem.com if you need a free dashboard to see your App's reports
                      kTSKReportUris: @[@"https://overmind.datatheorem.com/trustkit/report"]
                      },
              
              
              // Pin valid SPKI hashes to www.datatheorem.com to demonstrate success
              @"www.datatheorem.com" : @{
                      kTSKEnforcePinning:@YES,
                      kTSKPublicKeyAlgorithms : @[kTSKAlgorithmEcDsaSecp384r1],
                      
                      // Valid SPKI hashes to demonstrate success
                      kTSKPublicKeyHashes : @[
                              @"58qRu/uxh4gFezqAcERupSkRYBlBAvfcw7mEjGPLnNU=", // CA key: COMODO ECC Certification Authority
                              @"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=", // Fake key but 2 pins need to be provided
                              ]
                      }}};
    
    [TrustKit initializeWithConfiguration:trustKitConfig];

    // Demonstrate how to receive pin validation notifications (only useful for performance/metrics)
    [TrustKit sharedInstance].validationDelegateQueue =dispatch_get_main_queue();
    [TrustKit sharedInstance].validationDelegateCallback = ^(TSKPinningValidatorResult * _Nonnull result) {
        NSLog(@"Received pinning validation notification:\n\tDuration: %0.4f\n\tDecision: %ld\n\tResult: %ld\n\tHostname: %@",
              result.validationDuration,
              (long)result.finalTrustDecision,
              (long)result.validationResult,
              result.serverHostname);
    };
    
    return YES;
}

@end
