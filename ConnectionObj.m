//
//  ConnectionObj.m
//
//  Created by Chernoivanenko Yuriy on 3/19/15.
//  Copyright (c) 2015 HYS Enterprise Yuri Chernoivanenko. All rights reserved.
//

#import "ConnectionObj.h"

@implementation ConnectionObj

@synthesize connectDelegate;

-(id)initWithSendingDictionary:(NSDictionary*)dict{
    
    self = [super init];
    if (self) {
        [dict setValue:@"qwerty.net" forKey:@"domain"];
        [dict setValue:@"12345" forKey:@"key"];
         NSString *initialUrl = @"http://qwertyu.net/mobile.php";
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:initialUrl]];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        NSError *error;
        NSData *jsonGenData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonString = [[NSString alloc]initWithData:jsonGenData encoding:NSUTF8StringEncoding];
        NSLog(@"JSON: %@", jsonString);
        [request setHTTPBody:jsonGenData];
        [request setHTTPMethod:@"POST"];
        
        connect = [[NSURLConnection alloc]initWithRequest:request delegate:self];
        return self;
    }
    
    return nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    responseData = [[NSMutableData alloc]init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    [responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    
    return nil;
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    if (responseData!=nil)
    {
        NSError *error;
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
        
        if (responseDict==nil) {
            NSString *string = [[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
            NSLog(@"RESP STRING: %@", string);
        }
        
        if (self.connectDelegate && ![responseDict isKindOfClass:[NSNull class]] && responseDict!=nil) {
            [connectDelegate connect:responseDict];
        }
        
        if (self.connectDelegate && ([responseDict isKindOfClass:[NSNull class]] || responseDict==nil )) {
            [connectDelegate connectFailed];
        }
    }
    
    connect = nil;
    responseData = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    NSLog(@"ERROR = %@", error);
    
    if (connectDelegate) {
        [connectDelegate connectFailed];
    }
    
    //[self showMessage:@"Er was een serverfout"];
    
    connect = nil;
    responseData = nil;
}

@end
