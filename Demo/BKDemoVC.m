//
//  BKViewController.m
//  BKTaggedRecursiveSubviewQuery
//
//  Copyright (c) 2014 Brian Kenny
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "BKDemoVC.h"
#import "UIView+BKTaggedRecursiveSubviewQuery.h"

@interface BKDemoVC ()

@end
#define PAD 5
//#define MINUSPAD (1.0-(2*PAD))


@implementation BKDemoVC
{
    UIView *rootVw_;
    UIView *bottomRightVw_;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    rootVw_ = [[UIView alloc] initWithFrame:CGRectMake(0, 30, 320, 320+PAD)];
    rootVw_.backgroundColor = [self randomColor];
    [self.view addSubview:rootVw_];
    [self addViewsToView:rootVw_ size:rootVw_.frame.size.width/3 across:3 depth:3 pad:PAD];

    [[[UIAlertView alloc] initWithTitle:@"Instructions"
                                message:@"Each view in the grid is tagged with 'x_is_#' and 'y_is_#' at creation.\n\nViews with a 'L' are UILabels.\n\nThe '%p' preidcate tests for a strongly red background color.\n\nAll queries are from the largest colored view except 'h2:@UILabel' which is from the smallest one in the bottom right corner.\n\nTap the buttons to select views matching the queries."
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles: nil] show];

    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    clearButton.frame =CGRectMake(5, 370, 50, 44);
    [self.view addSubview:clearButton];
    [clearButton setTitle:@"Clear" forState:UIControlStateNormal];
    [clearButton addTarget:self action:@selector(onClear) forControlEvents:UIControlEventTouchUpInside];

    UIButton *newButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    newButton.frame =CGRectMake(65, 370, 50, 44);
    [self.view addSubview:newButton];
    [newButton setTitle:@"New" forState:UIControlStateNormal];
    [newButton addTarget:self action:@selector(onNewGrid) forControlEvents:UIControlEventTouchUpInside];


    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    rightButton.frame =CGRectMake(130, 370, 50, 44);
    [self.view addSubview:rightButton];
    [rightButton setTitle:@"x_is_2" forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(onRight) forControlEvents:UIControlEventTouchUpInside];


    UIButton *topLeftButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    topLeftButton.frame =CGRectMake(190, 370, 130, 44);
    [self.view addSubview:topLeftButton];
    [topLeftButton setTitle:@"& x_is_0 y_is_0" forState:UIControlStateNormal];
    [topLeftButton addTarget:self action:@selector(onTopLeft) forControlEvents:UIControlEventTouchUpInside];




    UIButton *labelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    labelButton.frame =CGRectMake(5, 405, 100, 44);
    [self.view addSubview:labelButton];
    [labelButton setTitle:@"d2:@UILabel" forState:UIControlStateNormal];
    [labelButton addTarget:self action:@selector(onLabel) forControlEvents:UIControlEventTouchUpInside];

    UIButton *superButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    superButton.frame =CGRectMake(105, 405, 100, 44);
    [self.view addSubview:superButton];
    [superButton setTitle:@"h:@UILabel" forState:UIControlStateNormal];
    [superButton addTarget:self action:@selector(onSuper) forControlEvents:UIControlEventTouchUpInside];

    UIButton *super2Button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    super2Button.frame =CGRectMake(200, 405, 50, 44);
    [self.view addSubview:super2Button];
    [super2Button setTitle:@"h2:" forState:UIControlStateNormal];
    [super2Button addTarget:self action:@selector(onSuper2) forControlEvents:UIControlEventTouchUpInside];


    UIButton *takeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    takeButton.frame =CGRectMake(250, 405, 70, 44);
    [self.view addSubview:takeButton];
    [takeButton setTitle:@"t7:x_is_0" forState:UIControlStateNormal];
    [takeButton addTarget:self action:@selector(onTake) forControlEvents:UIControlEventTouchUpInside];

    
    UIButton *complexButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    complexButton.frame =CGRectMake(5, 440, 280, 44);
    [self.view addSubview:complexButton];
    [complexButton setTitle:@"d3: | (& @UILabel x_is_0) (& x_is_2 %p)" forState:UIControlStateNormal];
    [complexButton addTarget:self action:@selector(onComplex) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)onClear
{
    for(UIView *vw in [rootVw_ bk_viewQuery:@"@UIView"])
    {
        [self deselectView:vw];
    }
}

- (void)onNewGrid
{
    for(UIView *vw in rootVw_.subviews)
    {
        [vw removeFromSuperview];
    }
    [self addViewsToView:rootVw_ size:rootVw_.frame.size.width/3 across:3 depth:3 pad:PAD];
}

- (void)onLabel
{
    for(UIView *vw in [rootVw_ bk_viewQuery:@"d2:@UILabel"])
    {
        [self selectView:vw];
    }
}

-(void)onSuper
{
    for(UIView *vw in [bottomRightVw_ bk_viewQuery:@"h:@UILabel"])
    {
        [self selectView:vw];
    }
}

-(void)onSuper2
{
    for(UIView *vw in [bottomRightVw_ bk_viewQuery:@"h2:"])
    {
        [self selectView:vw];
    }
}

-(void)onTake
{
    for(UIView *vw in [rootVw_ bk_viewQuery:@"t7:x_is_0"])
    {
        [self selectView:vw];
    }
}

- (void)onRight
{
    for(UIView *vw in [rootVw_ bk_viewQuery:@"x_is_2"])
    {
        [self selectView:vw];
    }
}

- (void)onTopLeft
{
    for(UIView *vw in [rootVw_ bk_viewQuery:@"& x_is_0 y_is_0"])
    {
        [self selectView:vw];
    }
}

- (void)onComplex
{
    NSPredicate * redPred = BK_PRED_VIEW( return [self isRedView:view]; );
    NSArray *views = [rootVw_ bk_viewQuery:@"d3: |  (& @UILabel x_is_0) \
                                                      (& x_is_2   %p    )", redPred];
    
    for(UIView *vw in views)
    {
        [self selectView:vw];
    }
}


- (void)addViewsToView:(UIView *)rootView size:(float)size across:(int)across depth:(int)depth pad:(float)pad
{
    if (depth<1) {
        return;
    }
    for(int x=0;  x<across; x++)
    {
        for(int y=0; y<across; y++)
        {
            int r = arc4random_uniform(2);
            UIView *vw;
            if(r==0)
            {
                vw = [[UIView alloc] initWithFrame:CGRectMake(pad/.66+x*size, pad/.66+y*size, size-pad, size-pad)];
            }
            else if(r==1)
            {
                vw =[[UILabel alloc] initWithFrame:CGRectMake(pad/.66+x*size, pad/.66+y*size, size-pad, size-pad)];
                ((UILabel *)vw).text = @"L";
                ((UILabel *)vw).font = [UIFont systemFontOfSize:8];
            }
            vw.backgroundColor = [self randomColor];
            [rootView addSubview:vw];
            [vw bk_addTags:[NSString stringWithFormat:@"testTag x_is_%d y_is_%d temp1 temp2", x, y]];
            [vw bk_clearTags:@"temp1 temp2"];
            
            int newAcross = across/*-1*/;
            float newPad = pad*.66;
            int newSize = (size-pad)/newAcross;
            [self addViewsToView:vw size:newSize across:newAcross depth:depth-1 pad:newPad];
            if(depth==1)
            {
                bottomRightVw_ = vw;
            }
        }
    }
}

- (UIColor *)randomColor
{
    #define ARC4RANDOM_MAX      0x100000000
    double r = ((double)arc4random() / ARC4RANDOM_MAX);
    double g = ((double)arc4random() / ARC4RANDOM_MAX);
    double b = ((double)arc4random() / ARC4RANDOM_MAX);
    return [UIColor colorWithRed:r green:g blue:b alpha:0.3];
}

- (void)selectView:(UIView *)vw
{
    CGFloat r, g, b, a;
    if ([vw.backgroundColor getRed:&r green:&g blue:&b alpha:&a])
        vw.backgroundColor = [UIColor colorWithRed:r
                                             green:g
                                              blue:b
                                             alpha:1.0];
    vw.layer.borderColor = [UIColor redColor].CGColor;
    vw.layer.borderWidth = 1;
}

- (void)deselectView:(UIView *)vw
{
    CGFloat r, g, b, a;
    if ([vw.backgroundColor getRed:&r green:&g blue:&b alpha:&a])
        vw.backgroundColor = [UIColor colorWithRed:r
                                             green:g
                                              blue:b
                                             alpha:0.3];
    vw.layer.borderWidth = 0;
}

- (BOOL)isRedView:(UIView *)vw
{
    CGFloat r, g, b, a;
    if ([vw.backgroundColor getRed:&r green:&g blue:&b alpha:&a])
        vw.backgroundColor = [UIColor colorWithRed:r
                                             green:g
                                              blue:b
                                             alpha:0.3];
    return (r*.66 > b) && (r*.66 > g) && (r > 0.66);
}

- (BOOL)isBlueView:(UIView *)vw
{
    CGFloat r, g, b, a;
    if ([vw.backgroundColor getRed:&r green:&g blue:&b alpha:&a])
        vw.backgroundColor = [UIColor colorWithRed:r
                                             green:g
                                              blue:b
                                             alpha:0.3];
    return (b*.66 > g) && (b*.66 > r) && (b > 0.66);
}

@end
