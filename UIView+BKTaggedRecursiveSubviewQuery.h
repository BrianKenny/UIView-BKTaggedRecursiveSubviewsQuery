//
//  UIView+BKTaggedRecursiveSubviewQuery.h
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

#import <UIKit/UIKit.h>

@interface UIView (BKTaggedRecursiveSubviewQuery)

//! Array of string tags or empty array if none.  returns self for chaining.
- (NSArray *)bk_tags;

//! Tags to add(space separated alphanumeric text)  returns self for chaining.
- (UIView *)bk_addTags:(NSString *)tags;

//! Tags to remove(space separated alphanumeric text)  returns self for chaining.
- (UIView *)bk_clearTags:(NSString *)tags;

/**
 * Performs a superview or subview query with the specified query string and optional predicates.
 *
 * For example: [self.veiw bk_viewQuery:@"d5: (| tag1 !tag2 (& @UITextField %p))" BK_PRED_VIEW(view.height>100)]
 * retuns an array with any subviews to a depth of 5 having tag1 or lacking tag2 or which are both UITextFields
 * (or one of its subclasses) and have a  height greater than 100.
 */
- (NSArray *)bk_viewQuery:(NSString *)query, ... ;


#ifndef BK_TAG_SUBVIEW_NO_CONVENIENCE_METHODS
- (NSArray *)tags;
- (UIView *)addTags:(NSString *)tags;
- (UIView *)clearTags:(NSString *)tags;
- (NSArray *)viewQuery:(NSString *)query, ... ;
#endif


@end

#ifndef BK_TAG_SUBVIEW_NO_HELPER_PREDS
//! Convenience macro for block predicates.  Ex: BK_PRED_VIEW(view.height==44)
#define BK_PRED_VIEW(blockBody)  [NSPredicate predicateWithBlock:^(UIView *view, NSDictionary *bindings){ blockBody }]
#endif
