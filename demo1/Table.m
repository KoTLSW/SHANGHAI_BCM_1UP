//
//  Table.m
//  demo1
//
//  Created by mac on 2017/8/23.
//  Copyright © 2017年 maceastwin. All rights reserved.
//

#import "Table.h"


//=============================================
@interface Table ()

@property(nonatomic,assign)int  index;
@end
//=============================================
@implementation Table
//=============================================
- (id)init:(NSView*)parent DisplayData:(NSArray*)arrayData
{
//    NSLog(@"2");
    self = [super init];
    
    
    _index=0;
    
    if (self)
    {
        [self InitTableView:arrayData];
        
        [parent addSubview:self.view];
        
        self.view.translatesAutoresizingMaskIntoConstraints =NO;
        
        NSLayoutConstraint *constraint = nil;
        
        constraint = [NSLayoutConstraint constraintWithItem:self.view
                                                  attribute:NSLayoutAttributeLeading
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:parent
                                                  attribute:NSLayoutAttributeLeading
                                                 multiplier:1.0f
                                                   constant:0];
        [parent addConstraint:constraint];
        
        constraint = [NSLayoutConstraint constraintWithItem:self.view
                                                  attribute:NSLayoutAttributeTrailing
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:parent
                                                  attribute:NSLayoutAttributeTrailing
                                                 multiplier:1.0f
                                                   constant:0];
        [parent addConstraint:constraint];
        
        constraint = [NSLayoutConstraint constraintWithItem:self.view
                                                  attribute:NSLayoutAttributeTop
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:parent
                                                  attribute:NSLayoutAttributeTop
                                                 multiplier:1.0f
                                                   constant:0];
        [parent addConstraint:constraint];
        
        constraint = [NSLayoutConstraint constraintWithItem:self.view
                                                  attribute:NSLayoutAttributeBottom
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:parent
                                                  attribute:NSLayoutAttributeBottom
                                                 multiplier:1.0f
                                                   constant:0];
        [parent addConstraint:constraint];
        
        
        
        
        
                [self.table setColumnAutoresizingStyle:NSTableViewUniformColumnAutoresizingStyle];
                [self.table setAllowsColumnResizing:YES];
                NSArray* columns=[self.table tableColumns];
                for(int i=2;i<[columns count];i++)
                {
                    [columns[i] setWidth:100];
                    if (i==5)
                    {
                        [columns[i] setWidth:200];
                    }
                }
        
    }
    
    return self;
}



//=============================================
- (void)tableViewColumnDidResize:(NSNotification *)aNotification
{
    NSTableView* aTableView = aNotification.object;
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,aTableView.numberOfRows)];
    [aTableView noteHeightOfRowsWithIndexesChanged:indexes];
    
//    NSLog(@"aaa");
}
//=============================================
-(void)InitTableView:(NSArray*)arrayData
{
    _arrayDataSource =[[NSMutableArray alloc] init];
    
    int countDisplay=1;
    
    for (int i=0; i<[arrayData count]; i++)
    {
        //解析数组下标,取值
        Item* item=[arrayData objectAtIndex:i];
        
        if(item.isTest == YES)
        {
            NSMutableDictionary* dic=[[NSMutableDictionary alloc] init];
            
            //赋值,在tableView 上显示的数据(固定值)
            [dic setValue:[NSString stringWithFormat:@"%d",countDisplay] forKey:TABLE_COLUMN_ID];
            [dic setValue:item.testName?    item.testName:   @""    forKey:TABLE_COLUMN_TESTNAME];
            [dic setValue:item.units?     item.units:    @""    forKey:TABLE_COLUMN_UNITS];
            [dic setValue:item.min?     item.min:    @""    forKey:TABLE_COLUMN_MIN];
            [dic setValue:item.max?  item.max: @""    forKey:TABLE_COLUMN_MAX];
            [dic setValue:item.value ?  item.value:  @""    forKey:TABLE_COLUMN_VALUE];
            [dic setValue:item.result ? item.result: @""    forKey:TABLE_COLUMN_RESULT];
            
            [_arrayDataSource addObject:dic];
            countDisplay++;
        }
    }
    
    
    [self.table reloadData];
    [self.table needsDisplay];
    
}
//=============================================
-(void)SelectRow:(int)rowindex
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSIndexSet* indexSet = [[NSIndexSet alloc] initWithIndex:rowindex];
        [self.table selectRowIndexes:indexSet byExtendingSelection:NO];  // 选择指定行
        [self.table scrollRowToVisible:rowindex];                        // 滚动到指定行
        [self.table needsDisplay];
    });
}

//=============================================
-(void)flushTableRow:(Item*)item RowIndex:(NSInteger)rowIndex
{
    BOOL ispass = NO;
    
    if([item.result isEqualToString:@"PASS"])ispass=YES;
    
    NSLog(@"================%@",item.result);
    
    
    NSDictionary* color = [NSDictionary dictionaryWithObjectsAndKeys:ispass?[NSColor greenColor]:[NSColor redColor],NSForegroundColorAttributeName, nil];
    
    NSAttributedString* result = [[NSAttributedString alloc] initWithString:ispass?@"           PASS":@"            FAIL" attributes:color];
    
    //给模型对应的 key 值赋值
    [[_arrayDataSource objectAtIndex:rowIndex] setValue:item.testName   forKey:TABLE_COLUMN_TESTNAME];
    [[_arrayDataSource objectAtIndex:rowIndex] setValue:item.units    forKey:TABLE_COLUMN_UNITS];
    [[_arrayDataSource objectAtIndex:rowIndex] setValue:item.min    forKey:TABLE_COLUMN_MIN];
    [[_arrayDataSource objectAtIndex:rowIndex] setValue:item.max forKey:TABLE_COLUMN_MAX];
    [[_arrayDataSource objectAtIndex:rowIndex] setValue:result      forKey:TABLE_COLUMN_RESULT];
    [[_arrayDataSource objectAtIndex:rowIndex] setValue:item.value  forKey:TABLE_COLUMN_VALUE];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSIndexSet* indexSet = [[NSIndexSet alloc] initWithIndex:rowIndex];
        [self.table selectRowIndexes:indexSet byExtendingSelection:NO]; // 选择指定行
        [self.table scrollRowToVisible:rowIndex];// 滚动到指定行
        [self.table reloadData];
        [self.table needsDisplay];
    });
    
}
//=============================================
-(void)ClearTable
{
    for (int i=0; i<[_arrayDataSource count]; i++)
    {
        [[_arrayDataSource objectAtIndex:i] setValue:@"" forKey:TABLE_COLUMN_VALUE];
        [[_arrayDataSource objectAtIndex:i] setValue:@"" forKey:TABLE_COLUMN_RESULT];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.table reloadData];
    });
}

#pragma mark-tableView Delegate/DataSource
//=============================================
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
//    NSLog(@"%ld",_arrayDataSource.count);
    return [_arrayDataSource count];
}
//=============================================
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if ([_arrayDataSource objectAtIndex:row]==nil)
        
        return @"";
    else
    {
        return [[_arrayDataSource objectAtIndex:row] objectForKey:[tableColumn identifier]];
    }
}
//=============================================
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}
//=============================================
@end
//=============================================


