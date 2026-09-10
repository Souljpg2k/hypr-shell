import qs.Components
import QtQuick
import QtQuick.Effects

Item {
    anchors.fill: parent
    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: Colors.shadow
        shadowBlur: 0.3
    }

    Canvas {
        id: canvas
        width: 145
        height: 145
        anchors.centerIn: parent

        onPaint: {
            const ctx = getContext("2d");

            ctx.reset();

            const cx = width / 2;
            const cy = height / 2;
            const petals = 8;
            const baseRadius = 66;
            const waveRadius = 5;

            ctx.beginPath();

            for (let i = 0; i <= 360; i++) {
                const t = i * Math.PI / 180;
                const r = baseRadius + waveRadius * Math.sin(t * petals);
                const x = cx + Math.cos(t) * r;
                const y = cy + Math.sin(t) * r;
                if (i === 0)
                    ctx.moveTo(x, y);
                else
                    ctx.lineTo(x, y);
            }
            ctx.closePath();
            ctx.fillStyle = Colors.bg;
            ctx.fill();
        }

        RotationAnimation on rotation {
            from: 0
            to: 360
            duration: 20000
            loops: Animation.Infinite
            running: true
        }
    }
}
