//
//  ConnectionObj.h
//
//  Created by Chernoivanenko Yuriy on 3/19/15.
//  Copyright (c) 2015 HYS Enterprise Yuri Chernoivanenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ConnectDelegate <NSObject>

-(void)connect:(NSDictionary*)recievedData;
-(void)connectFailed;

@end


@interface ConnectionObj : NSObject <NSURLConnectionDelegate>{
    
    NSURLConnection *connect;
    NSMutableData *responseData;
    
}

@property (nonatomic, retain) id connectDelegate;

-(id)initWithSendingDictionary:(NSDictionary*)dict;

@end
