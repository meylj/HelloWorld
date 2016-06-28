//
//  ViewController.m
//  MailsTool
//
//  Created by allen on 20/3/2016.
//  Copyright © 2016 allen. All rights reserved.
//

#import "ViewController.h"
#import "VaildateAndSignViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    VaildateAndSignViewController * VSC =[[VaildateAndSignViewController alloc]init];
    NSLog(@"%@",VSC);
    
    [super viewDidLoad];

    // Do any additional setup after loading the view.

}

- (void)setRepresentedObject:(id)representedObject
{
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)SignRequirement:(id)sender
{
    NSNotificationCenter * nc =[NSNotificationCenter defaultCenter];
    [nc postNotificationName:@"SignMail" object:self userInfo:@{@"View":@"SignMail"}];

    
}
-(void)testNofitication:(NSNotification *)aNote
{
    NSLog(@"%@",aNote.userInfo);
    NSLog(@"%@",aNote.name);
    
}



@end
