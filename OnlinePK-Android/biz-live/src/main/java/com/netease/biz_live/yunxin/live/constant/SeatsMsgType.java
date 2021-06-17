package com.netease.biz_live.yunxin.live.constant;

/**
 * @author sunkeding
 * 麦位消息type
 */
public @interface SeatsMsgType {
    /**
     * 管理员同意上麦
     */
    int ADMIN_ACCEPT_JOIN_SEATS = 3001;
    /**
     * 管理员主动邀请上麦
     */
    int ADMIN_INVITE_JOIN_SEATS = 3002;
    /**
     * 管理员踢下麦
     */
    int ADMIN_KICK_SEATS = 3003;
    /**
     * 上麦者下麦
     */
    int LINKED_AUDIENCE_LEAVE_SEATS = 3004;
    /**
     * 观众申请上麦
     */
    int UNLINKED_AUDIENCE_APPLY_JOIN_SEATS = 3005;
    /**
     * 观众取消上麦申请
     */
    int UNLINKED_AUDIENCE_CANCEL_APPLY_JOIN_SEATS = 3006;
    /**
     * 管理员拒绝观众上麦申请
     */
    int ADMIN_REJECT_UNLINKED_AUDIENCE_JOIN_SEATS = 3007;
    /**
     * 观众拒绝同意上麦
     */
    int UNLINKED_AUDIENCE_REJECT_JOIN_SEATS = 3008;
    /**
     * 观众同意上麦
     */
    int UNLINKED_AUDIENCE_ACCEPT_JOIN_SEATS = 3009;

    /**
     * 管理员取消屏蔽麦位
     */
    int ADMIN_REOPEN_SEATS = 3010;

    /**
     * 管理员屏蔽麦位
     */
    int ADMIN_CLOSE_SEATS = 3011;
    /**
     * 麦位音视频变化
     */
    int AV_CHANGE = 3012;

    /**
     * 观众上麦成功
     */
    int LINKED_AUDIENCE_ENTER_SEATS = 3013;
}
