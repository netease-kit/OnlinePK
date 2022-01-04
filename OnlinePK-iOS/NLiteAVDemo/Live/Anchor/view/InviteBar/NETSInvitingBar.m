//
//  NETSInvitingBar.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/25.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NETSInvitingBar.h"
#import "TopmostView.h"
#import "NETSAudienceMask.h"


@interface NETSInvitingBar ()

@property (nonatomic, strong)   UIView      *bgView;
@property (nonatomic, strong)   UILabel     *tip;
@property (nonatomic, strong)   UIButton    *cancel;
@property (nonatomic, strong)   UIButton    *discardButton;
@property (nonatomic, assign)   BOOL        topUserInteractionEnabled;
@property (nonatomic, weak)     id<NETSInvitingBarDelegate> delegate;
@property (nonatomic, assign) NETSInviteBarType barType;
@end

@implementation NETSInvitingBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.bgView];
        [self.bgView addSubview:self.tip];
        [self.bgView addSubview:self.cancel];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame barType:(NETSInviteBarType)barType{
    if ([self initWithFrame:frame]) {
        self.barType = barType;
        [self.bgView addSubview:self.discardButton];
    }
    return  self;
}


- (void)layoutSubviews {
    self.bgView.frame = CGRectMake(8, kIsFullScreen ? 118 : 94, self.width - 16, 44);
    if (self.barType == NETSInviteBarTypeConnectMic) {
        self.cancel.frame = CGRectMake(self.bgView.width - 12 - 78, 8, 78, 28);
        self.discardButton.frame = CGRectMake(self.cancel.left-10-52, 8, 52, 28);
        self.tip.frame = CGRectMake(12, 11, self.bgView.width - 52 -78 -30, 22);

    }else {
        self.tip.frame = CGRectMake(12, 11, self.bgView.width - 36 - 52, 22);
        self.cancel.frame = CGRectMake(self.bgView.width - 12 - 52, 8, 52, 28);
    }
}

+ (NETSInvitingBar *)showInvitingWithTarget:(id)target title:(NSString *)title
{

    NETSInvitingBar *bar = [[NETSInvitingBar alloc] initWithFrame:CGRectMake(8, 0, kScreenWidth - 16, 44)];
    bar.tip.text = title;
    bar.delegate = target;
    
    UIView *topmostView = [TopmostView viewForApplicationWindow];
    topmostView.userInteractionEnabled = NO;
    [[UIApplication sharedApplication].keyWindow addSubview:bar];

    return bar;
}

+ (NETSInvitingBar *)showInvitingWithTarget:(id)target title:(NSString *)title barType:(NETSInviteBarType)type {
    
    NETSInvitingBar *bar = [[NETSInvitingBar alloc] initWithFrame:CGRectMake(8, 0, kScreenWidth - 16, 44) barType:type];
    bar.tip.text = title;
    bar.delegate = target;
    
    UIView *topmostView = [TopmostView viewForApplicationWindow];
    topmostView.userInteractionEnabled = NO;
    [bar.cancel setTitle:NSLocalizedString(@"点击查看", nil) forState:UIControlStateNormal];
    [[UIApplication sharedApplication].keyWindow addSubview:bar];

    return bar;
}


- (void)cancelAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickCancelInviting:)]) {
        [self.delegate clickCancelInviting:self.barType];
    }
    [self dismiss];
}

- (void)discardAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickDiscardButton:)]) {
        [self.delegate didClickDiscardButton:self.barType];
    }
    [self dismiss];
}

- (void)dismiss {
    UIView *topmostView = [TopmostView viewForApplicationWindow];
    topmostView.userInteractionEnabled = _topUserInteractionEnabled;
    [self removeFromSuperview];
}

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIView *subview in self.subviews) {
           CGPoint convertedPoint = [subview convertPoint:point fromView:self];
           UIView *hitTestView = [subview hitTest:convertedPoint withEvent:event];
           if (hitTestView) {
               return hitTestView;
           }
       }
    return nil;
}

#pragma mark - lazy load

- (UIView *)bgView
{
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        _bgView.layer.cornerRadius = 4;
        _bgView.layer.masksToBounds = YES;
    }
    return _bgView;
}

- (UILabel *)tip
{
    if (!_tip) {
        _tip = [[UILabel alloc] init];
        _tip.font = [UIFont systemFontOfSize:14];
        _tip.textColor = [UIColor whiteColor];
    }
    return _tip;
}

- (UIButton *)cancel {
    if (!_cancel) {
        _cancel = [[UIButton alloc] init];
        _cancel.layer.cornerRadius = 4;
        _cancel.layer.masksToBounds = YES;
        _cancel.titleLabel.font = TextFont_14;
        [_cancel setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
        [_cancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_cancel addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
        [_cancel setGradientBackgroundWithColors:@[HEXCOLOR(0xfa555f),HEXCOLOR(0xd846f6)] locations:nil startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 0)];
    }
    return _cancel;
}

- (UIButton *)discardButton {
    if (!_discardButton) {
        _discardButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _discardButton.layer.cornerRadius = 4;
        _discardButton.layer.masksToBounds = YES;
        _discardButton.layer.borderWidth = 1;
        _discardButton.layer.borderColor = UIColor.whiteColor.CGColor;
        [_discardButton setTitle:NSLocalizedString(@"忽略", nil) forState:UIControlStateNormal];
        [_discardButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _discardButton.titleLabel.font = TextFont_14;
        [_discardButton addTarget:self action:@selector(discardAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _discardButton;
}
@end
