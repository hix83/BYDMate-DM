package com.bydmate.app

import org.junit.Assert.assertEquals
import org.junit.Test

class AdaptiveUiScaleTest {
    @Test
    fun fullSizeWindowIsNotScaled() {
        assertEquals(1f, adaptiveUiScale(widthDp = 1280, heightDp = 720))
        assertEquals(1f, adaptiveUiScale(widthDp = 411, heightDp = 891))
    }

    @Test
    fun shortFreeformWindowsUseCompactScale() {
        assertEquals(0.88f, adaptiveUiScale(widthDp = 800, heightDp = 540))
        assertEquals(0.80f, adaptiveUiScale(widthDp = 800, heightDp = 420))
        assertEquals(0.72f, adaptiveUiScale(widthDp = 640, heightDp = 320))
        assertEquals(0.72f, adaptiveUiScale(widthDp = 438, heightDp = 584))
    }
}
