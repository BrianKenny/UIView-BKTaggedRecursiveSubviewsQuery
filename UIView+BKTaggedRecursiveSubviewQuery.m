//
//  UIView+BKTaggedRecursiveSubviewQuery.m
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

#import "UIView+BKTaggedRecursiveSubviewQuery.h"
#import <objc/runtime.h>

static char const * const sc_BKTaggedRecursiveSubviewQueryKey =  "BKTaggedRecursiveSubviewQueryKey";


#define PRED_VIEW(blockBody)  [NSPredicate predicateWithBlock:^(UIView * view, NSDictionary *bindings){ blockBody }]

#define PRED_HAS_TAG(TAG)  PRED_VIEW( return [view bk_hasTag:TAG]; )
#define PRED_OF_KIND(CLASS)  PRED_VIEW( return [view isKindOfClass:[CLASS class]]; )
#define PRED_AND(PREDS) [NSCompoundPredicate andPredicateWithSubpredicates:PREDS]
#define PRED_OR(PREDS) [NSCompoundPredicate orPredicateWithSubpredicates:PREDS]
#define PRED_NOT(PREDS) [NSCompoundPredicate notPredicateWithSubpredicate:PREDS]

#define SEPARATOR [NSCharacterSet whitespaceAndNewlineCharacterSet]

@implementation UIView (BKTaggedRecursiveSubviewQuery)

#pragma mark - Tag Methods

-(NSArray *)bk_tags
{
    NSMutableArray *tags = objc_getAssociatedObject(self, sc_BKTaggedRecursiveSubviewQueryKey);
    return tags ? tags : @[];
}

-(NSMutableArray *)bk_mutableTags
{
    NSMutableArray *mtags = objc_getAssociatedObject(self, sc_BKTaggedRecursiveSubviewQueryKey);
    if (mtags == nil)
    {
        mtags = [[NSMutableArray alloc] init];
        objc_setAssociatedObject(self, sc_BKTaggedRecursiveSubviewQueryKey, mtags, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return mtags;
}

- (UIView *)bk_addTags:(NSString *)tags
{
    [self.bk_mutableTags addObjectsFromArray:[tags componentsSeparatedByCharactersInSet:SEPARATOR]];
    return self;
}

- (UIView *)bk_clearTags:(NSString *)tags
{
    if(tags==nil)
        objc_setAssociatedObject(self, sc_BKTaggedRecursiveSubviewQueryKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    else
        [self.bk_mutableTags removeObjectsInArray:[tags componentsSeparatedByCharactersInSet:SEPARATOR]];
    return self;
}

- (BOOL)bk_hasTag:(NSString *)tag
{
    for(NSString * viewTag in self.bk_tags)
    {
        if([viewTag isEqualToString:tag])
            return YES;
    }
    return NO;
}

#pragma mark - Public Subview Methods

- (NSMutableArray *)bk_superviewsToDepth:(int)depth withPredicate:(NSPredicate *)predicate
{
    NSMutableArray *array = [[NSMutableArray alloc] init];

    UIView *vw = self.superview;
    for( ; vw!= nil; depth--)
    {
        if(depth == 0)
        {
            break;
        }
        if([predicate evaluateWithObject:vw])
        {
            [array addObject:vw];
        }
        vw = vw.superview;
    }
    return array;
}

- (NSMutableArray *)bk_subviewsToDepth:(int)depth withPredicate:(NSPredicate *)predicate
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [self bk_subviewsToDepth:depth usingArray:array withPredicate:predicate];
    return array;
}

- (NSArray *)bk_viewQuery:(NSString *)query, ...
{
    //get vararg predicates for use substitution with %p tokens
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"%p" options:NSRegularExpressionCaseInsensitive error:&error];
    int predCt = [regex numberOfMatchesInString:query options:0 range:NSMakeRange(0, query.length)];
    NSMutableArray * predSubstitutionAry = [[NSMutableArray alloc] initWithCapacity:predCt];
    va_list args;
    va_start(args, query);
    for( int i = 0; i < predCt; i++ ) {
        NSPredicate *pred = va_arg(args, NSPredicate *);
        [predSubstitutionAry addObject:pred];
    }
    va_end(args);
    return [self bk_viewQuery_internal:query predicateList:predSubstitutionAry];
}

#pragma mark - Private Methods

- (NSArray *)bk_viewQuery_internal:(NSString *)query predicateList:(NSMutableArray *)predSubstitutionAry
{
    
    // ensure ! prefix has spaces around it
    query = [query stringByReplacingOccurrencesOfString:@"!" withString:@" ! "];
    
    // "d##:"  recursion depth prefix
    BOOL up = [query hasPrefix:@"h"] || [query hasPrefix:@"u"];
    int depth = -1;
    NSRange range = [query rangeOfString:@":"];
    if(range.length>0)
    {
        NSString *depthStr = [query substringWithRange:NSMakeRange(1, range.location-1)];
        depth = depthStr.length>0 ? [depthStr intValue] : -1;
        query = [query substringFromIndex:range.location+1];
    }
    
    NSArray *predAry = queryStrToPredAry(query, predSubstitutionAry);
    assert(predAry.count == 1);
    return up ? [self bk_superviewsToDepth:depth withPredicate:predAry[0]]
              : [self bk_subviewsToDepth:depth withPredicate:predAry[0]];
}

//! Recursive subview enumeration filtered by predicate. Passes mutable array for results to avoid returning & joing lots of arrays
- (void)bk_subviewsToDepth:(int)depth usingArray:(NSMutableArray *)returnValuesArray withPredicate:(NSPredicate *)predicate
{
    if(depth==0)
        return;
    [returnValuesArray addObjectsFromArray:[self.subviews filteredArrayUsingPredicate:predicate]];
    for(UIView *subview in self.subviews)
    {
        [returnValuesArray addObjectsFromArray:[subview bk_subviewsToDepth:depth-1 withPredicate:predicate]];
    }
}


#pragma mark - Private C functions

NSMutableArray * convertTokenAryToPreAry(NSMutableArray *array,  NSMutableArray * predSubstitutionAry)
{
    for(int i=array.count-1; i>=0; i--)
    {
        NSString *token = array[i];
        if (![token isKindOfClass:[NSString class]])
        {
            //ignore non strings(which will be predicates from previously processed () chunks)
        }
        else if([token hasPrefix:@"&"])
        {
            [array replaceObjectsInRange:NSMakeRange(i,array.count-i)
                    withObjectsFromArray:@[PRED_AND([array subarrayWithRange:NSMakeRange(i+1,array.count-i-1)])]];
        }
        else if([token hasPrefix:@"|"])
        {
            [array replaceObjectsInRange:NSMakeRange(i,array.count-i)
                    withObjectsFromArray:@[PRED_OR([array subarrayWithRange:NSMakeRange(i+1,array.count-i-1)])]];
        }
        else if([token hasPrefix:@"!"])
        {
            [array replaceObjectsInRange:NSMakeRange(i,2) withObjectsFromArray:@[PRED_NOT(array[i+1])]];
        }
        else if([token hasPrefix:@"%p"])
        {
            array[i] = [predSubstitutionAry lastObject];
            [predSubstitutionAry removeLastObject];
        }
        else if([token hasPrefix:@"@"])
        {
            array[i] = PRED_OF_KIND(NSClassFromString([token substringFromIndex:1]));
        }
        else
        {
            array[i] = PRED_HAS_TAG(token);
        }
        
    }
    return array;
}

NSMutableArray * splitString(NSString *str)
{
    NSMutableArray *array = [[str componentsSeparatedByCharactersInSet:SEPARATOR] mutableCopy];
    NSPredicate *pred =[NSPredicate predicateWithBlock:^(NSString * splitStr, NSDictionary *bindings){
        return (BOOL)([splitStr length] > 0);
    }];
    [array filterUsingPredicate:pred];   //because componentsSeparatedBy leaves @"" element in place of the separators
    return array;
}

id queryStrToPredAry(NSString * str, NSMutableArray * predSubstitutionAry)
{
    //scan for a matched pair of ()s
    int open = -1;
    int close = -1;
    int nestCt = 0;
    for (int i=0; i<str.length && close == -1; i++)
    {
        char ch = [str characterAtIndex:i];
        if (ch == '(')
        {
            nestCt++;
            if(open == -1)
                open = i;
        }
        else if(ch == ')')
        {
            nestCt--;
            if(nestCt==0)
                close = i;
        }
    }
    
    //base case - no parens
    if(open == -1)
    {
        NSMutableArray *separated = splitString(str);
        NSMutableArray * preds = convertTokenAryToPreAry(separated, predSubstitutionAry);
        return preds;
    }
    
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    // do the tail end first
    if(close < str.length-1)
    {
        NSString *str3  = [str substringFromIndex:close+1];
        NSArray *part3 = queryStrToPredAry(str3, predSubstitutionAry);
        [ret addObjectsFromArray:part3];
    }
    
    //then the paren chunk we just identivied
    NSString *str2  = [str substringWithRange:NSMakeRange(open+1, close-open-1)];
    NSArray *part2 = queryStrToPredAry(str2, predSubstitutionAry);
    [ret insertObjects:part2 atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, part2.count)]];
    
    //and finally the head
    if (open>0)
    {
        NSString *str1  = [str substringToIndex:open-1];
        NSArray *part1 = splitString(str1);
        [ret insertObjects:part1 atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, part1.count)]];
    }
    
    ret = convertTokenAryToPreAry(ret, predSubstitutionAry);
    return ret;
}

#pragma mark - Un-prefixed Public Methods

#ifndef BK_TAG_SUBVIEW_NO_CONVENIENCE_METHODS
- (NSArray *)tags
{
    return self.bk_tags;
}

- (UIView *)addTags:(NSString *)tags
{
    return [self bk_addTags:tags];
}

- (UIView *)clearTags:(NSString *)tags
{
    return [self bk_clearTags:tags];
}

- (NSArray *)viewQuery:(NSString *)query, ...
{
    //get vararg predicates for use substitution with %p tokens
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"%p" options:NSRegularExpressionCaseInsensitive error:&error];
    int predCt = [regex numberOfMatchesInString:query options:0 range:NSMakeRange(0, query.length)];
    NSMutableArray * predSubstitutionAry = [[NSMutableArray alloc] initWithCapacity:predCt];
    va_list args;
    va_start(args, query);
    for( int i = 0; i < predCt; i++ ) {
        NSPredicate *pred = va_arg(args, NSPredicate *);
        [predSubstitutionAry addObject:pred];
    }
    va_end(args);
    return [self bk_viewQuery_internal:query predicateList:predSubstitutionAry];
}
#endif

@end
