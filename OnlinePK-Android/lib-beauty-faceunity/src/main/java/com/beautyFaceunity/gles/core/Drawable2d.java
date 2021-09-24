/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.beautyFaceunity.gles.core;

import java.nio.FloatBuffer;

/**
 * Base class for stuff we like to draw.
 */
public class Drawable2d {

    public static final int SIZEOF_FLOAT = 4;
    public static final int COORDS_PER_VERTEX = 2;
    public static final int TEXTURE_COORD_STRIDE = 2 * SIZEOF_FLOAT;
    public static final int VERTEXTURE_STRIDE = COORDS_PER_VERTEX * SIZEOF_FLOAT;

    private FloatBuffer mTexCoordArray;
    private FloatBuffer mVertexArray;
    private int mVertexCount;

    public Drawable2d() {
    }

    /**
     * Prepares a drawable from a "pre-fabricated" shape definition.
     * <p>
     * Does no EGL/GL operations, so this can be done at any time.
     */
    public Drawable2d(float[] FULL_RECTANGLE_COORDS, float[] FULL_RECTANGLE_TEX_COORDS) {
        updateVertexArray(FULL_RECTANGLE_COORDS);
        updateTexCoordArray(FULL_RECTANGLE_TEX_COORDS);
    }

    /**
     * Prepares a drawable from a "pre-fabricated" shape definition.
     * <p>
     * Does no EGL/GL operations, so this can be done at any time.
     */
    public Drawable2d(float[] FULL_RECTANGLE_COORDS) {
        updateVertexArray(FULL_RECTANGLE_COORDS);
    }

    public void updateVertexArray(float[] FULL_RECTANGLE_COORDS) {
        mVertexArray = GlUtil.createFloatBuffer(FULL_RECTANGLE_COORDS);
        mVertexCount = FULL_RECTANGLE_COORDS.length / COORDS_PER_VERTEX;
    }

    public void updateTexCoordArray(float[] FULL_RECTANGLE_TEX_COORDS) {
        mTexCoordArray = GlUtil.createFloatBuffer(FULL_RECTANGLE_TEX_COORDS);
    }

    /**
     * Returns the array of vertices.
     * <p>
     * To avoid allocations, this returns internal state.  The caller must not modify it.
     */
    public FloatBuffer vertexArray() {
        return mVertexArray;
    }

    /**
     * Returns the array of texture coordinates.
     * <p>
     * To avoid allocations, this returns internal state.  The caller must not modify it.
     */
    public FloatBuffer texCoordArray() {
        return mTexCoordArray;
    }

    /**
     * Returns the number of vertices stored in the vertex array.
     */
    public int vertexCount() {
        return mVertexCount;
    }

}
