//
//  NETSInputToolBar.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/19.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSInputToolBar.h"

@interface NETSInputToolBar ()

@property (nonatomic, strong, readwrite)   UITextField     *textField;
@property (nonatomic, strong)   UILabel         *inputLab;
@property (nonatomic, strong)   UIButton        *beautyBtn;
@property (nonatomic, strong)   UIButton        *connectRequestBtn;
@property (nonatomic, strong)   UIButton        *musicBtn;
@property (nonatomic, strong)   UIButton        *moreBtn;
@property (nonatomic, strong)   UIView          *redTagView;
@property(nonatomic, assign) NERoomType roomType;
@end

@implementation NETSInputToolBar


- (instancetype)initWithRoomType:(NERoomType)roomType {
    if (self = [super init]) {
        _roomType = roomType;
        [self inputViewAddsubviews];
    }
    return self;
}

- (void)inputViewAddsubviews {
    [self addSubview:self.textField];
    [self addSubview:self.inputLab];
    [self addSubview:self.beautyBtn];
    if (self.roomType == NERoomTypeConnectMicLive) {
        [self addSubview:self.connectRequestBtn];
    }
    [self addSubview:self.musicBtn];
    [self addSubview:self.moreBtn];
    [self addNotificationObserve];
    
}
- (void)addNotificationObserve{
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(micApplyCountDidChange:) name:NotificationName_Audience_ApplyConnectMic object:nil]; // 顶部歌曲变化通知
}

- (void)micApplyCountDidChange:(NSNotification *)notification {
    NSDictionary *musicInfo = notification.userInfo;
    BOOL isdisPlay  = [musicInfo[@"isDisPlay"] boolValue];
    self.redTagView.hidden = !isdisPlay;
}

- (void)layoutSubviews
{
    CGFloat inputWidth = 0;
    if (self.roomType == NERoomTypeConnectMicLive) {
        inputWidth = self.width - 16 - 4 * 36 - 4 * 10;
    }else {
        inputWidth = self.width - 16 - 3 * 36 - 3 * 10;
    }
    self.textField.frame = CGRectMake(8, 0, inputWidth, self.height);
    self.inputLab.frame = CGRectMake(8, 0, inputWidth, self.height);
    self.beautyBtn.frame = CGRectMake(self.inputLab.right + 10, 0, 36, 36);
    if (self.roomType == NERoomTypeConnectMicLive) {
        self.connectRequestBtn.frame = CGRectMake(self.beautyBtn.right + 10, 0, 36, 36);
        self.musicBtn.frame = CGRectMake(self.connectRequestBtn.right + 10, 0, 36, 36);
    }else {
        self.musicBtn.frame = CGRectMake(self.beautyBtn.right + 10, 0, 36, 36);
    }
    self.moreBtn.frame = CGRectMake(self.musicBtn.right + 10, 0, 36, 36);
    self.textField.frame = self.inputLab.frame;
}

- (void)setFrame:(CGRect)frame
{
    CGRect rect = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 36);
    [super setFrame:rect];
}

- (void)clickButton:(UIButton *)button
{
    if (!(self.delegate && [self.delegate respondsToSelector:@selector(clickInputToolBarAction:)])) {
        return;
    }
    NETSInputToolBarAction action = NETSInputToolBarUnknown;
    if (button == self.beautyBtn) {
        action = NETSInputToolBarBeauty;
    } else if (button == self.connectRequestBtn) {
        //连麦申请
        action = NETSInputToolBarConnectRequest;
    } else if (button == self.musicBtn) {
        action = NETSInputToolBarMusic;
    } else if (button == self.moreBtn) {
        action = NETSInputToolBarMore;
    }
    [self.delegate clickInputToolBarAction:action];
}

- (void)clickInputLabel
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickInputToolBarAction:)]) {
        [self.textField becomeFirstResponder];
        [self.delegate clickInputToolBarAction:NETSInputToolBarInput];
    }
}

- (void)resignFirstResponder {
    [self.textField resignFirstResponder];
}

-(void)scenarioChanged:(NSString *)changeIconName {
    [self.connectRequestBtn setImage:[UIImage imageNamed:changeIconName] forState:UIControlStateNormal];
}

#pragma mark - lazyMethod
/// private button
- (UIButton *)alphaCircleButton
{
    UIButton *btn = [[UIButton alloc] init];
    [btn addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

/// 输入视图默认富文本文案
- (NSAttributedString *)_inputLabPlaceholder
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"   "];
    
    NSTextAttachment *attchment = [[NSTextAttachment alloc] init];
    attchment.bounds = CGRectMake(0, -2, 16, 16);
    attchment.image = [UIImage imageNamed:@"msg_ico"];
    NSAttributedString *attachStr = [NSAttributedString attributedStringWithAttachment:attchment];
    [attributedString appendAttributedString:attachStr];
    
    NSAttributedString *tipStr = [[NSAttributedString alloc] initWithString:NSLocalizedString(@" 说点什么...", nil)];
    [attributedString appendAttributedString:tipStr];
    
    return [attributedString copy];
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

- (UILabel *)inputLab
{
    if (!_inputLab) {
        _inputLab = [[UILabel alloc] init];
        _inputLab.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        _inputLab.layer.cornerRadius = 18;
        _inputLab.layer.masksToBounds = YES;
        _inputLab.attributedText = [self _inputLabPlaceholder];
        _inputLab.textColor = [UIColor whiteColor];
        _inputLab.font = [UIFont systemFontOfSize:14];
        _inputLab.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickInputLabel)];
        [_inputLab addGestureRecognizer:tap];
    }
    return _inputLab;
}

- (UIButton *)beautyBtn {
    if (!_beautyBtn) {
        _beautyBtn = [self alphaCircleButton];
        [_beautyBtn setImage:[UIImage imageNamed:@"anchorBottom_beauty_icon"] forState:UIControlStateNormal];
    }
    return _beautyBtn;
}

- (UIButton *)connectRequestBtn {
    if (!_connectRequestBtn) {
        _connectRequestBtn = [self alphaCircleButton];
        [_connectRequestBtn setImage:[UIImage imageNamed:@"connectMic_able"] forState:UIControlStateNormal];
        [_connectRequestBtn addSubview:self.redTagView];
    }
    return _connectRequestBtn;
}

- (UIButton *)moreBtn {
    if (!_moreBtn) {
        _moreBtn = [self alphaCircleButton];
        [_moreBtn setImage:[UIImage imageNamed:@"anchorBottom_more_icon"] forState:UIControlStateNormal];
    }
    return _moreBtn;
}

- (UIButton *)musicBtn {
    if (!_musicBtn) {
        _musicBtn = [self alphaCircleButton];
        [_musicBtn setImage:[UIImage imageNamed:@"anchorBottom_music_icon"] forState:UIControlStateNormal];
    }
    return _musicBtn;
}

- (UIView *)redTagView {
    if (!_redTagView) {
        _redTagView = [[UIView alloc]initWithFrame:CGRectMake(25, 0, 10, 10)];
        _redTagView.backgroundColor = UIColor.redColor;
        [_redTagView cornerAllCornersWithCornerRadius:5];
        _redTagView.hidden = YES;
    }
    return _redTagView;
}

@end
