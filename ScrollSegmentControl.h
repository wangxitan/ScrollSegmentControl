//
//  ScrollSegmentControl.h
//  RECT
//
//  Created by wxt on 16/5/19.
//  Copyright © 2016年 XitanWang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ScrollItem;
@protocol ScrollSegmentControlDelegate <NSObject>

-(void)beginScrollerFormPosintion:(NSInteger)position;
-(void)endScrollerFormPosintion:(NSInteger)position;
@end
@interface ScrollSegmentControl : UIControl
@property (nonatomic,strong) NSArray<ScrollItem       *> * items;
@property (nonatomic,assign) NSInteger         position;//default 0;
@property (nonatomic,assign) CGFloat           inset;// default(0)
@property (nonatomic,assign) CGFloat           cornerRadius;// default(5)
@property (nonatomic,strong) UIColor           *selectionColor; //default [UIColor orangeColor]
@property(nonatomic,assign) id<ScrollSegmentControlDelegate> delegat;

@end

@interface ScrollItem : NSObject;
@property (nonatomic,copy  ) NSString          * item_Name;
@property (nonatomic,strong) UIColor           * title_norml_Color;
@property (nonatomic,strong) UIColor           * title_selected_Color;
-(id)initWithItem_Name:(NSString *)item_Name
     title_norml_Color:(UIColor *)title_norml_Color
   tile_selected_Color:(UIColor *)tile_selected_Color;
@end