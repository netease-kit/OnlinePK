/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.beautyFaceunity.gles.core;

/**
 * Off-screen EGL surface (pbuffer).
 * <p>
 * It's good practice to explicitly release() the surface, preferably from a "finally" block.
 */
public class OffscreenSurface extends EglSurfaceBase {
    /**
     * Creates an off-screen surface with the specified width and height.
     */
    public OffscreenSurface(EglCore eglCore, int width, int height) {
        super(eglCore);
        createOffscreenSurface(width, height);
    }

    /**
     * Releases any resources associated with the surface.
     */
    public void release() {
        releaseEglSurface();
    }
}
