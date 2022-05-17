package com.netease.live_pk.utils;

public enum NEAssetsEnum {
    EFFECTS("beauty"),
    FILTERS("filters"),
    MAKEUPS("makeups");

    private String assetsPath;

    NEAssetsEnum(String assetsPath) {
        this.assetsPath = assetsPath;
    }

    public String getAssetsPath() {
        return assetsPath;
    }
}
