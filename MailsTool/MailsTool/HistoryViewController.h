//
//  HistoryViewController.h
//  MailsTool
//
//  Created by allen on 10/4/2016.
//  Copyright © 2016 allen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HistoryViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>
{
    
}
@property (weak) IBOutlet NSTableView *tvHistory;
@property (weak) IBOutlet NSSegmentedControl *segCategory;

@end
