//
//  NETSAudienceBottomBar.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/25.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NETSAudienceBottomBar.h"
#import "NETSToast.h"

@interface NETSAudienceBottomBar ()

@property (nonatomic, strong, readwrite) UITextField *textField;
@property (nonatomic, strong)   UILabel         *textLabel;
@property (nonatomic, strong)   UIButton        *giftBtn;
@property (nonatomic, strong)   UIButton        *closeBtn;
@property (nonatomic, strong)   UIButton        *requestConnectBtn;

@end

@implementation NETSAudienceBottomBar

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubview:self.textField];
        [self addSubview:self.textLabel];
        [self addSubview:self.giftBtn];
        [self addSubview:self.closeBtn];
        [self addSubview:self.requestConnectBtn];
        _buttonType = NETSAudienceBottomRequestTypeNormal;
    }
    return self;
}

- (void)layoutSubviews {
    self.textField.frame = CGRectMake(8, 0, self.width - 16 - 36 * 3 - 10 * 2, 36);
    self.textLabel.frame = self.textField.frame;
    self.requestConnectBtn.frame = CGRectMake(self.textLabel.right + 10, 0, 36, 36);
    self.giftBtn.frame = CGRectMake(self.requestConnectBtn.right + 10, 0, 36, 36);
    self.closeBtn.frame = CGRectMake(self.giftBtn.right + 10, 0, 36, 36);
}

- (void)setRoomType:(NERoomType)roomType {
    _roomType = roomType;
    if (roomType == NERoomTypeConnectMicLive) {
        self.requestConnectBtn.hidden = NO;
    }
}

#pragma mark - privite
- (void)setButtonType:(NETSAudienceBottomRequestType)buttonType {
    _buttonType = buttonType;
    switch (buttonType) {
        case NETSAudienceBottomRequestTypeNormal:{
            [self.requestConnectBtn setImage:[UIImage imageNamed:@"connectMic_able"] forState:UIControlStateNormal];
        }
            break;
        case NETSAudienceBottomRequestTypeApplying:{
            [self.requestConnectBtn setImage:[UIImage imageNamed:@"connectMic_disable"] forState:UIControlStateNormal];
        }
            break;
        case NETSAudienceBottomRequestTypeAccept:{
            [self.requestConnectBtn setImage:[UIImage imageNamed:@"connectMic_accept"] forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
}

- (void)clickButton:(UIButton *)button {
    if (button == self.giftBtn && self.delegate && [self.delegate respondsToSelector:@selector(clickGiftBtn)]) {
        [self.delegate clickGiftBtn];
    }
    if (button == self.closeBtn && self.delegate && [self.delegate respondsToSelector:@selector(clickCloseBtn)]) {
        [self.delegate clickCloseBtn];
    }
    if (button == self.requestConnectBtn && self.delegate && [self.delegate respondsToSelector:@selector(clickRequestConnect:)]) {
        //申请连麦
        [self.delegate clickRequestConnect:_buttonType];
    }
}

- (void)tapInputLabel:(UITapGestureRecognizer *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickTextLabel:)]) {
        [self.textField becomeFirstResponder];
        [self.delegate clickTextLabel:self.textLabel];
    }
}

- (void)resignFirstResponder
{
    [self.textField resignFirstResponder];
}

#pragma mark - lazy load

- (UITextField *)textField
{
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.textColor = [UIColor clearColor];
    }
    return _textField;
}

- (UILabel *)textLabel
{
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.backgroundColor = HEXCOLORA(0x0C0C0D, 0.6);
        _textLabel.layer.cornerRadius = 18;
        _textLabel.layer.masksToBounds = YES;
        _textLabel.font = [UIFont systemFontOfSize:14];
        _textLabel.textColor = HEXCOLOR(0xcccccc);
        _textLabel.text = NSLocalizedString(@"    说点什么...", nil);

        _textLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapInputLabel:)];
        [_textLabel addGestureRecognizer:tap];
    }
    return _textLabel;
}

- (UIButton *)giftBtn {
    if (!_giftBtn) {
        _giftBtn = [[UIButton alloc] init];
        [_giftBtn setImage:[UIImage imageNamed:@"send_gift_ico"] forState:UIControlStateNormal];
        [_giftBtn addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _giftBtn;
}

- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [[UIButton alloc] init];
        [_closeBtn setImage:[UIImage imageNamed:@"cha_ico"] forState:UIControlStateNormal];
        _closeBtn.layer.cornerRadius = 18;
        _closeBtn.layer.masksToBounds = YES;
        _closeBtn.backgroundColor = HEXCOLORA(0x0C0C0D, 0.6);
        [_closeBtn addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

- (UIButton *)requestConnectBtn {
    if (!_requestConnectBtn) {
        _requestConnectBtn = [[UIButton alloc] init];
        [_requestConnectBtn setImage:[UIImage imageNamed:@"connectMic_able"] forState:UIControlStateNormal];
        [_requestConnectBtn addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        _requestConnectBtn.hidden = YES;
    }
    return _requestConnectBtn;
}
@end
