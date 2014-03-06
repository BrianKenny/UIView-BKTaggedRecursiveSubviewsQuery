This project aims to be a much more powerful alternative to UIView's `tag`, `viewWithTag`, and `subviews` methods. Think jQuery selectors.  It adds two parts.  The first is is allowing a view to have unlimited NSString tags.  The pertinent bits are

```objective-c
- (NSMutableDictionary *)tags;
- (UIView *)addTags:(NSString *)tags;
- (UIView *)clearTags:(NSString *)tags;
```
Note: tags are a string containing one or more whitespace separated tags.


The second, and more powerful part, is a recursive super/subview query with a concise DSL that allows searching by tags, classes, arbitrary predicates, or any combination thereof.

```objective-c
- (NSArray *)viewQuery:(NSString *)query, ... ;
```

#### Query DSL

The query string starts with an optional prefix block indicating search direction and depth/height.  Query strings use prefix notation and whitespace as separators.  Logical operators are '!', '|' and '&'.  @indicates the following text is a class to be used in an isKindOfClass test.  %p indicates a predicate to passed as a vararg.  All other text is interpreted as tags. Here are  a few examples to make it clearer.

```objective-c
// get all subviews that have the my_view tag
[self.view viewQuery:@"my_view"]

// get all subviews that have any of the tags my_view my_other_view pick_me
[self.view viewQuery:@"| my_view my_other_view pick_me"]

// get all subviews to 3 deep that are UILabels
[self.view viewQuery:@"d3: @UILabel"]

// get all superviews that are UIImageViews
[self.view viewQuery:@"h: @UIImageView"]

// get all superviews to a height of 8 that have a width of 50
[self.view viewQuery:@"h8: %p", BK_PRED_VIEW(return view.width == 50;)]

// get all subviews to 3 deep that are both not of class UILabel and don't have the tag my_tag
[self.view viewQuery:@"d3:& ! @UILabel ! my_tag"]

//get subviews to depth 3 that are either UILabels with tag x_is_0 or that have tag x_is_2 and red backgrounds
NSPredicate * redPred = BK_PRED_VIEW( return [self isRedView:view]; );
NSArray *views = [self.view viewQuery:@"d3: |   (& @UILabel x_is_0)\
                                                (& x_is_2   %p    )", redPred];

```


#### Misc.

By default there are unprefixed convenience methods, which is slightly unsafe.  You can eliminate these by defining BK_TAG_SUBVIEW_NO_CONVENIENCE_METHODS.  Likewise BK_TAG_SUBVIEW_NO_HELPER_PREDS will remove the helper macros.


Also, there's a small set of tests, and demo app if you want to give it a quick try.
