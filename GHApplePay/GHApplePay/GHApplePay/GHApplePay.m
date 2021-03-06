//
//  GHApplePay.m
//  GHApplePay
//
//  Created by shen_gh on 16/3/1.
//  Copyright © 2016年 com.joinup(Beijing). All rights reserved.
//

#import "GHApplePay.h"

@implementation GHApplePay

- (instancetype)initWithPayReceiver:(NSString *)payReceiver amount:(NSString *)amount presentVC:(UIViewController *)vc{
    self=[super init];
    if (self) {
        if([PKPaymentAuthorizationViewController canMakePayments]) {
            PKPaymentSummaryItem *widget = [PKPaymentSummaryItem summaryItemWithLabel:payReceiver amount:[NSDecimalNumber decimalNumberWithString:amount]];
            
            PKPaymentRequest *request = [[PKPaymentRequest alloc] init];
            request.countryCode = @"CH";//国别：中国
            request.currencyCode = @"CNY";//货币类型：人民币
            //支持哪种结算网关
            request.supportedNetworks = @[PKPaymentNetworkChinaUnionPay,PKPaymentNetworkAmex,PKPaymentNetworkMasterCard,PKPaymentNetworkVisa];
            
            request.merchantCapabilities = PKMerchantCapability3DS | PKMerchantCapabilityEMV | PKMerchantCapabilityCredit | PKMerchantCapabilityDebit;
            request.merchantIdentifier = @"merchant.com.sghApplePay";
            request.paymentSummaryItems = @[widget];//商品
            //账单地址
            request.requiredBillingAddressFields = PKAddressFieldAll;
            
            PKPaymentAuthorizationViewController *payMentVc = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
            payMentVc.delegate = self;
            if (!vc) {
                NSLog(@"出问题了，vc deallocated");
            }else{
                [vc presentViewController:payMentVc animated:YES completion:nil];
            }
        }else{
            NSLog(@"不支持ApplePay");
        }
    }
    return self;
}

#pragma mark - PKPaymentAuthorizationViewControllerDelegate
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller didAuthorizePayment:(PKPayment *)payment completion:(void (^)(PKPaymentAuthorizationStatus status))completion{
    BOOL asyncSuccessful = NO;
    
    if(asyncSuccessful) {
        completion(PKPaymentAuthorizationStatusSuccess);
        NSLog(@"Payment was successful");
        if (_delegate&&[_delegate respondsToSelector:@selector(GHApplePayDidSuccess)]) {
            [_delegate GHApplePayDidSuccess];
        }
    } else {
        completion(PKPaymentAuthorizationStatusFailure);
        NSLog(@"Payment was unsuccessful");
        if (_delegate&&[_delegate respondsToSelector:@selector(GHApplePayDidFailure)]) {
            [_delegate GHApplePayDidFailure];
        }
    }
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
