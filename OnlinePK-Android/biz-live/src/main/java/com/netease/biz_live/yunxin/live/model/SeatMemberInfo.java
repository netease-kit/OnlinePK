package com.netease.biz_live.yunxin.live.model;

import java.io.Serializable;
import java.util.Objects;

public class SeatMemberInfo implements Serializable {
    public String accountId;
    public String nickName;
    public String avatar;
    public int audio;
    public int video;
    public String avRoomCName;
    public String avRoomCid;
    public long avRoomUid;
    public String avRoomCheckSum;

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        SeatMemberInfo that = (SeatMemberInfo) o;
        return Objects.equals(accountId, that.accountId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(accountId);
    }

}
