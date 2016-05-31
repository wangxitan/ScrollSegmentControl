//
//  ScrollSegmentControl.m
//  RECT
//
//  Created by wxt on 16/5/19.
//  Copyright © 2016年 XitanWang. All rights reserved.
//

#define size_width self.bounds.size.width

#import "ScrollSegmentControl.h"

@interface ScrollSegmentControl()
{
    UIView * markView;
}
@property(nonatomic,assign)CGPoint initPoint;
@property(nonatomic,assign)CGPoint markViewOldPoint;
@property(nonatomic,strong)NSMutableArray<UILabel *> * NormalsubViews;
@property(nonatomic,strong)NSMutableArray<UILabel *> * SelectsubViews;
@property(nonatomic,strong)NSMutableArray<NSValue*> * PointsSectionArray;
@property(nonatomic,assign)NSInteger beginPosition;
@property(nonatomic,assign)NSInteger endPosition;

@end
@implementation ScrollSegmentControl
-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initBaseModel];
    }
    return self;
}
//
-(void)initBaseModel
{
    self.NormalsubViews = [NSMutableArray array];
    self.SelectsubViews = [NSMutableArray array];
    self.PointsSectionArray = [NSMutableArray array];
    self.backgroundColor = [UIColor whiteColor];
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.selectionColor = [UIColor orangeColor];
    self.layer.borderWidth = 0.5;
    self.cornerRadius = 5;
    self.position = 0;
    self.inset = 0;
    self.beginPosition=0;
    self.endPosition = 0;
}
// 停止拖拽后 停留位置
-(NSInteger)aninmationForNowpoint:(CGPoint )point{
    
    
    __block NSInteger loc;
    [self.PointsSectionArray enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj CGPointValue].x>=point.x) {
            
            if ([obj CGPointValue].x-point.x<= size_width/(2*(self.PointsSectionArray.count))) {
               loc = idx;
            }else{
                loc =  idx-1;
            }
            * stop = YES;
        }
    }];
    self.endPosition = loc;
    return loc;
}
// 拖拽事件
-(void)panAction:(UIPanGestureRecognizer *)pan{
    if (pan.state ==UIGestureRecognizerStateBegan) {
        self.initPoint = markView.center;
        if (self.delegat &&[self.delegat respondsToSelector:@selector(beginScrollerFormPosintion:)]) {
            [self.delegat beginScrollerFormPosintion:self.beginPosition];
            }
        return;
    }
    
    if (pan.state == UIGestureRecognizerStateChanged) {
        
        CGPoint point;
        if (self.initPoint.x+[pan translationInView:self].x>=[self.NormalsubViews firstObject].center.x && self.initPoint.x+[pan translationInView:self].x<=[self.NormalsubViews lastObject].center.x) {
            point = CGPointMake(self.initPoint.x+[pan translationInView:self].x, markView.center.y);
        }else{
            point = self.initPoint.x+[pan translationInView:self].x>size_width/2?[self.NormalsubViews lastObject].center:[self.NormalsubViews firstObject].center;
        }
        [self layoutMakeViewWithPoint:point];

    }else{
        [UIView animateWithDuration:0.2 animations:^{
            [self layoutMakeViewWithPoint:[self.PointsSectionArray[[self aninmationForNowpoint:self->markView.center]]CGPointValue]];
        } completion:^(BOOL finished) {
            if (self.delegat &&[self.delegat respondsToSelector:@selector(endScrollerFormPosintion:)]) {
                [self.delegat endScrollerFormPosintion:self.endPosition];
                self.beginPosition = self.endPosition;
            }
            
        }];
    }
}


-(void)layoutSubviews
{
    [super layoutSubviews];
    if (self.NormalsubViews.count==0) {
        return;
    }
    

    CGFloat subView_width = size_width/self.NormalsubViews.count;
    [self.PointsSectionArray removeAllObjects];
    [self.NormalsubViews enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj setFrame:CGRectMake(idx*subView_width, 0,subView_width, self.frame.size.height)];
        [self.PointsSectionArray addObject:[NSValue valueWithCGPoint:obj.center]];
       
    }];
    [markView setFrame:CGRectInset(self.NormalsubViews[0].frame, self.inset, self.inset)];
    [self layoutMakeViewWithPoint:self.NormalsubViews[self.position].center];
    [self decorateViews];
    
}
// 修饰控件形状
-(void)decorateViews{
    self.layer.cornerRadius = self.cornerRadius;
    markView.layer.cornerRadius = self.cornerRadius<markView.bounds.size.height/2?self.cornerRadius:markView.bounds.size.height/2;
    markView.backgroundColor = self.selectionColor;
    markView.clipsToBounds = YES;
}
-(void)layoutMakeViewWithPoint:(CGPoint)point{
    markView.center = point;
    [self.NormalsubViews enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UILabel * seleectLabel = self.SelectsubViews[idx];
        [seleectLabel setFrame:[self convertRect:obj.frame toView:self->markView]];
    }];
}
#pragma  mark---setters
-(void)setItems:(NSArray<ScrollItem *> *)items
{
    _items = items;
    
    [self.NormalsubViews removeAllObjects];
    [self.SelectsubViews removeAllObjects];
    [items enumerateObjectsUsingBlock:^(ScrollItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UILabel * label = [UILabel new];

        [label setText:obj.item_Name];
        [label setTextColor:obj.title_norml_Color];
        [self addSubview:label];
        [self.NormalsubViews addObject:label];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setUserInteractionEnabled:YES];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        [label addGestureRecognizer:tap];
        
    }];
    
    markView = [UIView new];
    [self addSubview:markView];
    
    
    [items enumerateObjectsUsingBlock:^(ScrollItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UILabel * label = [UILabel new];
        [label setText:obj.item_Name];
        [label setTextColor:obj.title_selected_Color];
        [self->markView addSubview:label];
        [self.SelectsubViews addObject:label];
        [label setTextAlignment:NSTextAlignmentCenter];
        
        
    }];
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panAction:)];
    [markView addGestureRecognizer:pan];
    
}
-(void)tapAction:(UITapGestureRecognizer*)tap{
    [self.PointsSectionArray enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqualToValue:[NSValue valueWithCGPoint:tap.view.center]]) {
            [self setPosition:idx];
        }
    }];
}
-(void)setPosition:(NSInteger)position
{
    _position = position;
    if (self.PointsSectionArray.count==0)return;
    self.endPosition = position;
    [UIView animateWithDuration:0.2 animations:^{
        [self layoutMakeViewWithPoint:[self.PointsSectionArray[position]CGPointValue]];
    } completion:^(BOOL finished) {
        if (self.delegat &&[self.delegat respondsToSelector:@selector(endScrollerFormPosintion:)]) {
            [self.delegat endScrollerFormPosintion:self.endPosition];
            self.beginPosition = self.endPosition;
        }
        
    }];

    
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end


@implementation ScrollItem
-(id)initWithItem_Name:(NSString *)item_Name title_norml_Color:(UIColor *)title_norml_Color tile_selected_Color:(UIColor *)tile_selected_Color
{
    if (self = [super init]) {
        self.item_Name = item_Name;
        self.title_norml_Color = title_norml_Color;
        self.title_selected_Color = tile_selected_Color;
    }
    return self;
}


@end