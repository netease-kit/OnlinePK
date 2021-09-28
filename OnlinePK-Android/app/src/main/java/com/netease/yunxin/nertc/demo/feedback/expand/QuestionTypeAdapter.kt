/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.nertc.demo.feedback.expand

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.BaseExpandableListAdapter
import android.widget.ImageView
import android.widget.TextView
import com.netease.yunxin.nertc.demo.R
import java.util.*

/**
 * Created by luc on 2020/11/17.
 */
class QuestionTypeAdapter(
    private val context: Context,
    groups: List<QuestionGroup>?,
    selectedList: List<QuestionItem>?
) : BaseExpandableListAdapter() {
    private val groups: List<QuestionGroup>
    private val selectedList: MutableList<QuestionItem>
    override fun getGroupCount(): Int {
        return groups.size
    }

    override fun getChildrenCount(groupPosition: Int): Int {
        return groups[groupPosition].items.size
    }

    override fun getGroup(groupPosition: Int): Any {
        return groups[groupPosition]
    }

    override fun getChild(groupPosition: Int, childPosition: Int): Any {
        return groups[groupPosition].items[childPosition]
    }

    override fun getGroupId(groupPosition: Int): Long {
        return groupPosition.toLong()
    }

    override fun getChildId(groupPosition: Int, childPosition: Int): Long {
        return groups[groupPosition].items[childPosition].id.toLong()
    }

    override fun hasStableIds(): Boolean {
        return true
    }

    override fun getGroupView(
        groupPosition: Int,
        isExpanded: Boolean,
        convertView: View,
        parent: ViewGroup
    ): View {
        val rootView =
            LayoutInflater.from(context).inflate(R.layout.view_item_feedback_group, parent, false)
        val tvName = rootView.findViewById<TextView>(R.id.tv_group_name)
        tvName.text = groups[groupPosition].title
        val ivArrow = rootView.findViewById<ImageView>(R.id.iv_arrow)
        ivArrow.setImageResource(if (isExpanded) R.drawable.icon_up_arrow else R.drawable.icon_down_arrow)
        return rootView
    }

    override fun getChildView(
        groupPosition: Int,
        childPosition: Int,
        isLastChild: Boolean,
        convertView: View,
        parent: ViewGroup
    ): View {
        val rootView =
            LayoutInflater.from(context).inflate(R.layout.view_item_feedback_child, parent, false)
        val item = groups[groupPosition].items[childPosition]
        val tvName = rootView.findViewById<TextView>(R.id.tv_item_name)
        tvName.text = item.name
        val chosenView = rootView.findViewById<View>(R.id.iv_chosen_icon)
        chosenView.visibility =
            if (isSelected(item)) View.VISIBLE else View.GONE
        return rootView
    }

    private fun isSelected(item: QuestionItem): Boolean {
        return if (selectedList.isEmpty()) {
            false
        } else selectedList.contains(item)
    }

    fun updateSelectedItem(item: QuestionItem) {
        if (selectedList.contains(item)) {
            selectedList.remove(item)
        } else {
            selectedList.add(item)
        }
    }

    override fun isChildSelectable(groupPosition: Int, childPosition: Int): Boolean {
        return true
    }

    init {
        this.groups = ArrayList(groups)
        this.selectedList = ArrayList(selectedList)
    }
}