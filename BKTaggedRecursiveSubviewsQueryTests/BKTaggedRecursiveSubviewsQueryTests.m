//
//  BKTaggedRecursiveSubviewsQueryTests.m
//  BKTaggedRecursiveSubviewsQueryTests
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

#import <XCTest/XCTest.h>
#import "UIView+BKTaggedRecursiveSubviewQuery.h"

#define IMG_CT 3
#define LBL_CT 3
#define TXT_CT 5
#define VW_CT  2

@interface BKTaggedRecursiveSubviewsQueryTests : XCTestCase
@end

@implementation BKTaggedRecursiveSubviewsQueryTests
{
    UIView *_rootView;
}
- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
/*  Setup creates this view heirarchy
 
0 - UIView(_rootView)
1 - UIImageView,             UIView
2 - UILabel,                 UIView
3 - UIImageView
4 - UILabel
5 - UIImageView
6 - UILabel
7 - UITextField, UITextField, UITextField, UITextField, UITextField
*/
    
    _rootView = [[UIView alloc] init];

    UIView *vw = _rootView;

    for(int i=0; i<VW_CT; i++)
    {
        UIView *vw2 = [[[UIView alloc] init] addTags:[NSString stringWithFormat:@"depth_%d plain_vw", i]];
        [vw addSubview:vw2];
        vw = vw2;
    }
    
    vw = _rootView;
    
    for(int i=0; i<IMG_CT+LBL_CT; i++)
    {
        UIView *vw2 = i%2 ? [[UILabel alloc] init] : [[UIImageView alloc] init];
        [vw addSubview:vw2];
        [vw2 addTags: i%2 ? @"label stuff all" : @"image_vw things all"];
        [vw2 addTags:[NSString stringWithFormat:@"depth_%d", i]];
        vw = vw2;
    }
    
    for(int i=0; i<TXT_CT; i++)
    {
        UIView *vw2 =  [[UITextField alloc] init];
        [vw addSubview:vw2];
        [vw2 addTags: @"txt depth_6"];
    }
    
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    //Subview tag & kind
    
    XCTAssertTrue([_rootView viewQuery:@""].count == IMG_CT+LBL_CT+TXT_CT+VW_CT, @"");
    XCTAssertTrue([_rootView viewQuery:@"label"].count == LBL_CT , @"");
    XCTAssertTrue([_rootView viewQuery:@"image_vw"].count == IMG_CT , @"");
    XCTAssertTrue([_rootView viewQuery:@"txt"].count == TXT_CT , @"");
    XCTAssertTrue([_rootView viewQuery:@"| label image_vw"].count == IMG_CT+LBL_CT , @"");
    XCTAssertTrue([_rootView viewQuery:@"@UILabel"].count == LBL_CT , @"");
    XCTAssertTrue([_rootView viewQuery:@"| @UILabel image_vw"].count == LBL_CT+IMG_CT , @"");
    XCTAssertTrue([_rootView viewQuery:@"& label @UILabel"].count == 3 , @"");

    XCTAssertTrue([_rootView viewQuery:@"d4:label"].count == 2 , @"");
    XCTAssertTrue([_rootView viewQuery:@"d4:@UILabel"].count == 2 , @"");
    XCTAssertTrue([_rootView viewQuery:@"d4:(| label image_vw)"].count == 4 , @"");
    XCTAssertTrue([_rootView viewQuery:@"d4:(& label image_vw)"].count == 0 , @"");

    XCTAssertTrue([_rootView viewQuery:@"t2:"].count == 2 , @"");
    XCTAssertTrue([_rootView viewQuery:@"d4 t99:label"].count == 2 , @"");
    XCTAssertTrue([_rootView viewQuery:@"t99 d4:label"].count == 2 , @"");
    XCTAssertTrue([_rootView viewQuery:@"d4 t1:label"].count == 1 , @"");

    // Subview Predicate
    
    NSPredicate * predYES = BK_PRED_VIEW( return YES; );
    NSPredicate * predSubviews = BK_PRED_VIEW( return (BOOL)(view.subviews.count>0); );
    NSPredicate * predNoSubviews = BK_PRED_VIEW( return (BOOL)(view.subviews.count==0); );
    NSPredicate * predParrentIsLabel = BK_PRED_VIEW( return (BOOL)([view.superview isKindOfClass:[UILabel class]]); );
    
    NSArray *ary =[_rootView viewQuery:@"%p", predYES ];
    XCTAssertTrue(ary.count == IMG_CT+LBL_CT+TXT_CT+VW_CT, @"");
    
    ary = [_rootView viewQuery:@"%p", predSubviews];
    XCTAssertTrue(ary.count == IMG_CT+LBL_CT+VW_CT-1, @"");
    
    ary = [_rootView viewQuery:@"%p", predNoSubviews];
    XCTAssertTrue(ary.count == TXT_CT+1 , @"");
    
    ary = [_rootView viewQuery:@"%p", predParrentIsLabel];
    XCTAssertTrue(ary.count == 7 , @"");
    
    ary = [_rootView viewQuery:@"& %p @UITextField", predParrentIsLabel];
    XCTAssertTrue(ary.count == TXT_CT , @"");
    
    ary = [_rootView viewQuery:@"| (& label @UILabel) (& %p @UITextField)", predParrentIsLabel];
    XCTAssertTrue(ary.count == TXT_CT+LBL_CT , @"");
    
    ary = [_rootView viewQuery:@"| (& label @UILabel) (& %p @UITextField) depth_0", predParrentIsLabel];
    XCTAssertTrue(ary.count == TXT_CT+LBL_CT+2 , @"");
    
    ary = [_rootView viewQuery:@"| (& label @UILabel) (& %p @UITextField) depth_1", predParrentIsLabel];
    XCTAssertTrue(ary.count == TXT_CT+LBL_CT+1 , @"");

    //Super

    UIView * depth5Vw = [_rootView viewQuery:@"depth_5"][0];
    ary = [depth5Vw viewQuery:@"u:@UILabel"];
    XCTAssertTrue(ary.count == 2 , @"");

    ary = [depth5Vw viewQuery:@"u:@UIImageView"];
    XCTAssertTrue(ary.count == 3 , @"");

    ary = [depth5Vw viewQuery:@"u3:@UIView"];
    XCTAssertTrue(ary.count == 3 , @"");

    ary = [depth5Vw viewQuery:@"u3 t2:@UIView"];
    XCTAssertTrue(ary.count == 2 , @"");

    ary = [depth5Vw viewQuery:@"u3 t2:| @UIView label"];
    XCTAssertTrue(ary.count == 2 , @"");

    ary = [depth5Vw viewQuery:@"u3 t5:| @UIView label"];
    XCTAssertTrue(ary.count == 3 , @"");

}








@end
