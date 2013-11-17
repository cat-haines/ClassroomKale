//
//  TrackController.m
//  ClassroomKale
//
//  Created by Aron Steg on 11/16/13.
//  Copyright (c) 2013 Electric Imp. All rights reserved.
//

#import "TrackController.h"
#import "SelectColorController.h"
#import <Firebase/Firebase.h>


@interface TrackController()
{
    Firebase* fb;
    UIColor *last_color;
}

@property (weak, nonatomic) IBOutlet UILabel *lblTemp;
@property (weak, nonatomic) IBOutlet UILabel *lblHumidity;
@property (weak, nonatomic) IBOutlet UIButton *btnPump;
@property (weak, nonatomic) IBOutlet UIButton *btnLight;
@property (weak, nonatomic) IBOutlet UILabel *lblOverflow;
@end


@implementation TrackController

@synthesize lblTemp;
@synthesize lblHumidity;
@synthesize btnPump;
@synthesize btnLight;
@synthesize lblOverflow;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    // Blank out the existing labels
    [lblTemp setText:@""];
    [lblHumidity setText:@""];
    [btnPump setTitle:@"" forState:UIControlStateNormal];
    [btnLight setTitle:@"" forState:UIControlStateNormal];
    [lblOverflow setHidden:true];
    
    // Sync with Firebase
    fb = [[Firebase alloc] initWithUrl:@"https://classroomkale.firebaseio.com/kales/1/status"];

}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [fb removeAllObservers];
    [fb observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        NSLog(@"%@ -> %@", snapshot.name, snapshot.value);
        if (snapshot.value) {
            [lblTemp setText:[NSString stringWithFormat:@"%0.01f° C", [snapshot.value[@"temperature"] floatValue]]];
            
            [lblHumidity setText:[NSString stringWithFormat:@"%0.01f %%", [snapshot.value[@"humidity"] floatValue]]];
            
            bool PUMP = [snapshot.value[@"pump"] isEqualToNumber:@1];
            [btnPump setTitle:(PUMP ? @"ON" : @"OFF") forState:UIControlStateNormal];
            
            bool ISOVERFLOW = [snapshot.value[@"overflow"] isEqualToNumber:@1];
            [lblOverflow setHidden:!ISOVERFLOW];
            
            bool LIGHT = ![snapshot.value[@"light"] isEqualToString:@"000000"];
            [btnLight setTitle:(LIGHT ? @"ON" : @"OFF") forState:UIControlStateNormal];
            
            NSUInteger red = 0, green = 0, blue = 0;
            sscanf([snapshot.value[@"light"] UTF8String], "%02X%02X%02X", &red, &green, &blue);
            UIColor *color = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
            [btnLight setBackgroundColor:color];
            
            const CGFloat *componentColors = CGColorGetComponents(color.CGColor);
            UIColor *newColor = [[UIColor alloc] initWithRed:(1.0 - componentColors[0])
                                                       green:(1.0 - componentColors[1])
                                                        blue:(1.0 - componentColors[2])
                                                       alpha:componentColors[3]];
            btnLight.titleLabel.textColor = newColor;
            
        }
    }];
    
    [self postCommand:@"update" withValue:@"now"];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [fb removeAllObservers];
}

- (IBAction)btnWaterPump:(UIButton *)sender
{
    if ([btnPump.titleLabel.text isEqualToString:@"OFF"]) {
        [btnPump setTitle:@"ON" forState:UIControlStateNormal];
        [self postCommand:@"pump" withValue:@"1"];
    } else {
        [btnPump setTitle:@"OFF" forState:UIControlStateNormal];
        [self postCommand:@"pump" withValue:@"0"];
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([btnLight.titleLabel.text isEqualToString:@"ON"]) {
        return YES;
    } else {
        return NO;
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    SelectColorController *dest = [segue destinationViewController];
    dest.initialColor = last_color;
}

- (IBAction)btnLight:(UIButton *)sender
{
    if ([btnLight.titleLabel.text isEqualToString:@"OFF"]) {
        btnLight.titleLabel.text = @"ON";
        [btnLight setTitle:@"ON" forState:UIControlStateNormal];
    } else {
        last_color = [btnLight.backgroundColor copy];
        btnLight.backgroundColor =[UIColor colorWithRed:0 green:0 blue:0 alpha:1];
        btnLight.titleLabel.text = @"OFF";
        btnLight.titleLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
        [btnLight setTitle:@"OFF" forState:UIControlStateNormal];
        [self postCommand:@"light" withValue:@{@"r":@0, @"g":@0, @"b":@0}];
    }
}


- (IBAction)postCommand:(NSString *)command withValue:(id)value
{
    // Setup the command packet
    NSDictionary *msg = @{@"command": command, @"value": value};
    NSData *postData = [NSJSONSerialization dataWithJSONObject:msg options:0 error:nil];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    // Set up the URL request
    NSString *agenturl = @"https://agent.electricimp.com/i8UugRGJORm2";
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:agenturl]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    // Fire
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!conn) {
        NSLog(@"Connection could not be made to %@", agenturl);
    } else {
        NSLog(@"Posted: %@", msg);
    }
}



@end
