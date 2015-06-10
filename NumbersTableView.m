

#import "NumbersTableView.h"

@interface NumbersTableView ()

@end

@implementation NumbersTableView

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    trustedHosts = @[@"1223455", @"12345677" , @"qwerty.nl"];
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"usersInfo"];
    allUsersInfo = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    //NSLog(@"USERS: %@", allUsersInfo);
    idArray = [allUsersInfo objectForKey:@"CustomerNumbersById"];
    self.tableView.backgroundColor = bgColor;
    myDelegate = [[UIApplication sharedApplication]delegate];
    isRequesting = NO;
    
}

-(void)getMsisdnsByID
{
    NSMutableDictionary *bodyDict = [[NSMutableDictionary alloc]init];
    [bodyDict setValue:[[NSUserDefaults standardUserDefaults]valueForKey:@"Key"] forKey:@"SecurityKey"];
    NSDictionary *customerId = [idArray objectAtIndex:myDelegate.selectedID];
    [bodyDict setValue:[customerId valueForKey:@"Key"] forKey:@"CustomerId"];
    [bodyDict setValue:@"2" forKey:@"ApplicationId"];
    NSString *ApibaseAdress = @"https://qwertyuiycytc/json/GetCustomerInfo";
    NSURL *Apiurl = [NSURL URLWithString:ApibaseAdress];
    NSMutableURLRequest *apirequest = [NSMutableURLRequest requestWithURL:Apiurl];
    [apirequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [apirequest setTimeoutInterval:10];
    NSMutableDictionary *coverDict = [[NSMutableDictionary alloc]init];
    [coverDict setValue:bodyDict forKey:@"r"];
    NSLog(@"%@", coverDict);
    NSError *error;
    NSData *jsonGenData = [NSJSONSerialization dataWithJSONObject:coverDict options:NSJSONWritingPrettyPrinted error:&error];
    [apirequest setHTTPBody:jsonGenData];
    [apirequest setHTTPMethod:@"POST"];
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    isRequesting = YES;
    [NSURLConnection sendAsynchronousRequest:apirequest queue:queue completionHandler:^(NSURLResponse *response, NSData *respData, NSError *error)
     {
         if (respData!=nil) {
             NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:respData options:kNilOptions error:&error];
             NSLog(@"response: %@", responseDict);
             if ([[[responseDict objectForKey:@"GetCustomerInfoResult"]valueForKey:@"ResultCode"]integerValue] == 0) {
                 NSString *keyString = [[responseDict objectForKey:@"GetCustomerInfoResult"]valueForKey:@"SecurityKey"];
                 if ( keyString != (NSString*)[NSNull null] && keyString.length >0 ) {
                     NSLog(@"KEY FOUND");
                     [[NSUserDefaults standardUserDefaults]setValue:keyString forKey:@"Key"];
                     if ([[responseDict objectForKey:@"GetCustomerInfoResult"]valueForKey:@"Object"] && [[responseDict objectForKey:@"GetCustomerInfoResult"]valueForKey:@"Object"]!= [NSNull null] && [[[responseDict objectForKey:@"GetCustomerInfoResult"]objectForKey:@"Object"]valueForKey:@"Msisdn"]) {
                         NSArray *allMsisdns = [[[responseDict objectForKey:@"GetCustomerInfoResult"]objectForKey:@"Object"]valueForKey:@"Msisdn"];
                         NSLog(@"ALL NUMBERS COUNT: %d", allMsisdns.count);
                         [myDelegate.phoneNumbersArray removeAllObjects];
                         if (allMsisdns.count>0) {
                             for (NSDictionary *msisdnDict in allMsisdns) {
                                 NSLog(@"MSI DICT: %@", msisdnDict);
                                 NSString *msisdnString = [NSString stringWithFormat:@"%@", [msisdnDict valueForKey:@"Msisdn"]];
                                 [myDelegate.phoneNumbersArray addObject:msisdnString];
                             }
                         }
                         dispatch_async(dispatch_get_main_queue(), ^{
                             [self.tableView reloadData];
                         });
                         NSLog(@"NUMBERS COUNT: %d", myDelegate.phoneNumbersArray.count);
                     }
                     
                 }
                 
             }
             
             if ([[[responseDict objectForKey:@"GetCustomerInfoResult"]valueForKey:@"ResultCode"]intValue]==2) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self showMessage:@"Er was een serverfout"];
                 });
             }
         }
         isRequesting = NO;
     }];
    
}


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(isRequesting == YES){
        return nil;
    } else {
        return indexPath;
    }
}

-(BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

-(void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
        if ([trustedHosts containsObject:challenge.protectionSpace.host])
            [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

-(void)showMessage:(NSString*)message
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alert show];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
