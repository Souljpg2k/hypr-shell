import qs.Components
import QtQuick

Canvas {
    property real size: 34

    width: size
    height: size

    onPaint: {
        const ctx = getContext("2d")
        ctx.reset()
        ctx.fillStyle = Colors.sf
        const scale = size / 34
        const r = 5 * scale
        ctx.beginPath()
        ctx.moveTo(8.5 * scale, 6 * scale)
        ctx.arcTo(17 * scale, 0, 34 * scale, 12 * scale, r)
        ctx.arcTo(34 * scale, 12 * scale, 28 * scale, 32 * scale, r)
        ctx.arcTo(28 * scale, 32 * scale, 6 * scale, 32 * scale, r)
        ctx.arcTo(6 * scale, 32 * scale, 0, 12 * scale, r)
        ctx.arcTo(0, 12 * scale, 17 * scale, 0, r)
        ctx.closePath()
        ctx.fill()
    }
}