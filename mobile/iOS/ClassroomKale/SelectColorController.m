//
//  SelectColorController.m
//  ClassroomKale
//
//  Created by Aron Steg on 11/16/13.
//  Copyright (c) 2013 Electric Imp. All rights reserved.
//

#import "SelectColorController.h"

@interface SelectColorController ()

@property (weak, nonatomic) IBOutlet UISlider *sldRed;
@property (weak, nonatomic) IBOutlet UISlider *sldGreen;
@property (weak, nonatomic) IBOutlet UISlider *sldBlue;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;

@end

@implementation SelectColorController

@synthesize initialColor;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSLog(@"Color = %@", initialColor);
    if (initialColor) {
        CGFloat r, g, b, a;
        [initialColor getRed:&r green:&g blue:&b alpha:&a];
        [_sldRed setValue:(r*255)];
        [_sldGreen setValue:(g*255)];
        [_sldBlue setValue:(b*255)];
        [self updateLight];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnClose:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnRed:(id)sender
{
    [_sldRed setValue:255];
    [_sldGreen setValue:0];
    [_sldBlue setValue:0];
    [self updateLight];
}

- (IBAction)btnGreen:(id)sender
{
    [_sldRed setValue:0];
    [_sldGreen setValue:255];
    [_sldBlue setValue:0];
    [self updateLight];
}

- (IBAction)btnBlue:(id)sender
{
    [_sldRed setValue:0];
    [_sldGreen setValue:0];
    [_sldBlue setValue:255];
    [self updateLight];
}

- (IBAction)btnYellow:(id)sender
{
    [_sldRed setValue:255];
    [_sldGreen setValue:255];
    [_sldBlue setValue:0];
    [self updateLight];
}

- (IBAction)btnWhite:(id)sender
{
    [_sldRed setValue:255];
    [_sldGreen setValue:255];
    [_sldBlue setValue:255];
    [self updateLight];
}

- (IBAction)btnRainbow:(id)sender
{
    [self postCommand:@"light" withValue:@"rainbow"];
}

- (IBAction)sliderChanged:(UISlider *)sender
{
    UIColor *color = [UIColor colorWithRed:_sldRed.value/255.0 green:_sldGreen.value/255.0 blue:_sldBlue.value/255.0 alpha:1];
    [_btnClose setBackgroundColor:color];
    
    const CGFloat *componentColors = CGColorGetComponents(color.CGColor);
    UIColor *newColor = [[UIColor alloc] initWithRed:(1.0 - componentColors[0])
                                               green:(1.0 - componentColors[1])
                                                blue:(1.0 - componentColors[2])
                                               alpha:componentColors[3]];
    _btnClose.titleLabel.textColor = newColor;
    
}

- (IBAction)sliderUpdate:(id)sender
{
    [self updateLight];
}

- (void)updateLight
{
    [self sliderChanged:nil];
    
    NSMutableDictionary *rgb = [[NSMutableDictionary alloc] init];
    rgb[@"r"] = [NSNumber numberWithInteger:_sldRed.value];
    rgb[@"g"] = [NSNumber numberWithInteger:_sldGreen.value];
    rgb[@"b"] = [NSNumber numberWithInteger:_sldBlue.value];
    [self postCommand:@"light" withValue:rgb];
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
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:nil];
    if (!conn) {
        NSLog(@"Connection could not be made to %@", agenturl);
    } else {
        NSLog(@"Posted: %@", msg);
    }
}



@end
