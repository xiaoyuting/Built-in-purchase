//
//  ViewController.m
//  n内置购买
//
//  Created by 雨停 on 2017/11/24.
//  Copyright © 2017年 yuting. All rights reserved.
//

#import "ViewController.h"
#import <StoreKit/StoreKit.h>
@interface ViewController ()<SKProductsRequestDelegate,SKPaymentTransactionObserver>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    // Do any additional setup after loading the view, typically from a nib.
}
//根据付费Product ID去请求
-(void)searchProduct{
    if ([SKPaymentQueue canMakePayments]) {
        // 执行下面提到的第5步：
        [self getProductInfo];
    } else {
        NSLog(@"失败，用户禁止应用内付费购买.");
    }
   
    
    
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self searchProduct];
}
- (void)getProductInfo{
    SKProductsRequest * request = [[SKProductsRequest alloc]initWithProductIdentifiers:[NSSet setWithArray:@[@"商品ID"]]];
    request.delegate = self;
    [request start];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response NS_AVAILABLE_IOS(3_0){
    if(response.invalidProductIdentifiers.count>0){
        NSLog(@"ProductID无效");
    }else{
        SKMutablePayment * payment = [SKMutablePayment paymentWithProduct:response.products.lastObject];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
}
-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased://购买成功
                [self dl_completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed://购买失败
                [self dl_failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored://已经购买过该商品 恢复购买
                [self dl_restoreTransaction:transaction];
                break;
            case SKPaymentTransactionStatePurchasing://正在处理
                break;
            default:
                break;
        }
    }
}
// 购买成功的验证
-(void)dl_completeTransaction: (SKPaymentTransaction *)transaction{
    NSString * productIdentifier  = transaction.payment.productIdentifier;
    NSData  * receiptData = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]];
    NSString * receipt = [receiptData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    if(receipt.length>0 && productIdentifier.length>0){
        /**
         可以将receipt发给服务器进行购买验证
         */
    }
    [[SKPaymentQueue defaultQueue]finishTransaction:transaction];
                             
}
- (void)dl_failedTransaction:(SKPaymentTransaction*)transaction{
    if(transaction.error.code ==SKErrorPaymentCancelled){
        NSLog(@"取消支付");
    }else{
        NSLog(@"支付失败");
    }
}
- (void)dl_restoreTransaction:(SKPaymentTransaction *)transaction {
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

-(void)dl_validateReceiptWiththeAppStore:(NSString *)receipt
{
    NSError *error;
    NSDictionary *requestContents = @{@"receipt-data": receipt};
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestContents options:0 error:&error];
    
    if (!requestData) {
        
    }else{
        
    }
    NSURL *storeURL;
#ifdef DEBUG
    storeURL = [NSURL URLWithString:@"https://sandbox.itunes.apple.com/verifyReceipt"];
#else
    storeURL = [NSURL URLWithString:@"https://buy.itunes.apple.com/verifyReceipt"];
#endif
    
    NSMutableURLRequest *storeRequest = [NSMutableURLRequest requestWithURL:storeURL];
    [storeRequest setHTTPMethod:@"POST"];
    [storeRequest setHTTPBody:requestData];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:storeRequest queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (connectionError) {
                                   /* 处理error */
                               } else {
                                   NSError *error;
                                   NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                   if (!jsonResponse) {
                                       /* 处理error */
                                   }else{
                                       /* 处理验证结果 */
                                   }
                               }
                           }];
    
}

-(void)dealloc
{
    //移除购买结果监听
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

@end
