//
//  BBBCardIO.m
//  BBBCardIO
//
//  Created by Ollie Relph on 24/09/2015.
//  Copyright © 2015 Oliver Relph. All rights reserved.
//

#import "BBBCardIO.h"
#import "RCTBridge.h"
#import "RCTEventDispatcher.h"
#import "CardIO.h"

@implementation RCTConvert (CardIODetectionMode)
RCT_ENUM_CONVERTER(CardIODetectionMode, (@{
                                           @"IMAGE_AND_NUMBER" : @(CardIODetectionModeCardImageAndNumber),
                                           @"IMAGE" : @(CardIODetectionModeCardImageOnly),
                                           @"AUTOMATIC" : @(CardIODetectionModeAutomatic)
                                           }), CardIODetectionModeCardImageAndNumber, integerValue);
@end

@implementation BBBCardIO {
    CardIOView *cardIOView;
}


@synthesize bridge, methodQueue;

RCT_EXPORT_MODULE(BBBCardIO);

RCT_EXPORT_VIEW_PROPERTY(pitchEnabled, BOOL);

RCT_EXPORT_VIEW_PROPERTY(languageOrLocale, NSString);

RCT_EXPORT_VIEW_PROPERTY(guideColor, UIColor);

RCT_EXPORT_VIEW_PROPERTY(useCardIOLogo, BOOL);

RCT_EXPORT_VIEW_PROPERTY(hideCardIOLogo, BOOL);

RCT_EXPORT_VIEW_PROPERTY(allowFreelyRotatingCardGuide, BOOL);

RCT_EXPORT_VIEW_PROPERTY(scanInstructions, NSString);

RCT_EXPORT_VIEW_PROPERTY(scanExpiry, BOOL);

RCT_EXPORT_VIEW_PROPERTY(detectionMode, CardIODetectionMode);

RCT_EXPORT_VIEW_PROPERTY(scannedImageDuration, CGFloat);

- (UIView *)view {
    cardIOView = [[CardIOView alloc] init];
    cardIOView.delegate = self;
    return cardIOView;
}

#pragma mark - CardIOViewDelegate Methods

- (void)cardIOView:(__unused CardIOView *)cardIOView didScanCard:(CardIOCreditCardInfo *)info {
    if (info) {
        
        NSString *cardType = [CardIOCreditCardInfo displayStringForCardType: info.cardType
                                                      usingLanguageOrLocale: cardIOView.languageOrLocale];
        
        NSMutableDictionary *cardInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         info.cardNumber, @"cardNumber",
                                         info.redactedCardNumber, @"redactedCardNumber",
                                         cardType, @"cardType",
                                         nil];
        
        if(info.expiryMonth > 0 && info.expiryYear > 0) {
            [cardInfo setObject:[NSNumber numberWithUnsignedInteger:info.expiryMonth] forKey:@"expiryMonth"];
            [cardInfo setObject:[NSNumber numberWithUnsignedInteger:info.expiryYear] forKey:@"expiryYear"];
        }
        if(info.cvv.length > 0) {
            [cardInfo setObject:info.cvv forKey:@"cvv"];
        }
        if(info.postalCode.length > 0) {
            [cardInfo setObject:info.postalCode forKey:@"zip"];
        }
        
        [self.bridge.eventDispatcher sendAppEventWithName:@"cardIOSuccess"
                                                     body:cardInfo];
    } else {
        
        [self.bridge.eventDispatcher sendAppEventWithName:@"cardIOError"
                                                     body:@{
                                                            @"message": @"User cancelled payment info"
                                                            }];
    }
    
    [cardIOView removeFromSuperview];
}

@end
