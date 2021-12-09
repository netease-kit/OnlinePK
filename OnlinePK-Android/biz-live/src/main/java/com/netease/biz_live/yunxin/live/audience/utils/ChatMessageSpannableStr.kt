/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.audience.utils

import android.content.Context
import android.graphics.drawable.Drawable
import android.text.SpannableStringBuilder
import android.text.Spanned
import android.text.style.ForegroundColorSpan
import androidx.annotation.ColorInt
import androidx.annotation.DrawableRes
import androidx.core.content.ContextCompat
import com.netease.biz_live.yunxin.live.chatroom.span.VerticalImageSpan
import java.util.*

/**
 * Created by luc on 2020/11/10.
 */
class ChatMessageSpannableStr(private val messageInfo: CharSequence) {
    fun getMessageInfo(): CharSequence {
        return messageInfo
    }

    /**
     * 消息构建
     */
    class Builder {
        private val builder: SpannableStringBuilder = SpannableStringBuilder()

        /**
         * 添加 icon 资源
         *
         * @param context     app 上下文
         * @param drawableRes icon 资源id
         */
        fun append(
            context: Context,
            @DrawableRes drawableRes: Int,
            width: Int,
            height: Int
        ): Builder? {
            val drawable = ContextCompat.getDrawable(context, drawableRes)
            Objects.requireNonNull(drawable)
            return drawable?.let { append(it, width, height) }
        }

        /**
         * 添加 Icon
         *
         * @param drawable icon 资源
         */
        fun append(drawable: Drawable, width: Int, height: Int): Builder {
            drawable.setBounds(0, 0, width, height)
            append(" ", VerticalImageSpan(drawable))
            return this
        }

        /**
         * 添加文字同时带有颜色
         *
         * @param content 添加内容
         * @param color   颜色数值
         */
        fun append(content: CharSequence?, @ColorInt color: Int): Builder {
            append(content, ForegroundColorSpan(color))
            return this
        }

        /**
         * 添加CharSequence
         *
         * @param content 添加内容
         */
        fun append(content: CharSequence?): Builder {
            builder.append(content)
            return this
        }

        /**
         * 构建 ChatMessage
         */
        fun build(): ChatMessageSpannableStr {
            return ChatMessageSpannableStr(builder)
        }

        /**
         * 为 text 添加对应的 span 对象
         */
        private fun append(text: CharSequence?, what: Any?) {
            val start = builder.length
            text?.let {
                builder.append(text)
                builder.setSpan(what, start, builder.length, Spanned.SPAN_INCLUSIVE_EXCLUSIVE)
            }
        }

    }
}