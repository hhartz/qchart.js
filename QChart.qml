/* QChart.qml ---
 *
 * Author: Julien Wintz
 * Created: Thu Feb 13 20:59:40 2014 (+0100)
 * Version:
 * Last-Updated: jeu. mars  6 12:55:14 2014 (+0100)
 *           By: Julien Wintz
 *     Update #: 69
 */

/* Change Log:
 *
 */

import QtQuick 2.0

import "QChart.js" as Charts

Item {
    id: chartRoot

    property   var chart;
    property   var chartData;
    property   int chartType: 0;
    property  bool chartAnimated: false;
    property alias chartAnimationEasing: chartAnimator.easing.type;
    property alias chartAnimationDuration: chartAnimator.duration;
    property   int chartAnimationProgress: 0;
    property   var chartOptions: ({})
    property real customScale: 2

    Connections {
        target: leftWindow
        onActiveChanged: if (active) {canvas.requestPaint()}
    }

    onChartAnimationProgressChanged: {
        canvas.requestPaint();
    }

    onChartDataChanged: {
        // force creation of a new chart instance with updated data
        chart = undefined;
        canvas.requestPaint();
    }

    function repaint() { canvas.requestPaint() }

    onVisibleChanged: if (visible) repaint()

    Canvas {

        id: canvas;

        // ///////////////////////////////////////////////////////////////

        // /////////////////////////////////////////////////////////////////
        // Callbacks
        // /////////////////////////////////////////////////////////////////

        scale: 1/customScale
        onScaleChanged: console.log("scale: " + scale)
        transformOrigin: Item.TopLeft
        width: parent.width * customScale
        height: parent.height * customScale
        Component.onCompleted: {
            var ctx = getContext("2d");
            ctx.scale(customScale, customScale)
        }

        onPaint: {
            if(!chart) {
                switch(chartType) {
                case Charts.ChartType.BAR:
                    chart = new Charts.Chart(canvas, canvas.getContext("2d")).Bar(chartData, chartOptions);
                    break;
                case Charts.ChartType.DOUGHNUT:
                    chart = new Charts.Chart(canvas, canvas.getContext("2d")).Doughnut(chartData, chartOptions);
                    break;
                case Charts.ChartType.LINE:
                    chart = new Charts.Chart(canvas, canvas.getContext("2d")).Line(chartData, chartOptions);
                    break;
                case Charts.ChartType.PIE:
                    chart = new Charts.Chart(canvas, canvas.getContext("2d")).Pie(chartData, chartOptions);
                    break;
                case Charts.ChartType.POLAR:
                    chart = new Charts.Chart(canvas, canvas.getContext("2d")).PolarArea(chartData, chartOptions);
                    break;
                case Charts.ChartType.RADAR:
                    chart = new Charts.Chart(canvas, canvas.getContext("2d")).Radar(chartData, chartOptions);
                    break;
                default:
                    console.log('Chart type should be specified.');
                }

                chart.init();

                if (chartAnimated)
                    chartAnimator.start();
                else
                    chartAnimationProgress = 100;
            }
            chart.draw(chartAnimationProgress/100);
        }

        onHeightChanged: {
            requestPaint();
        }

        onWidthChanged: {
            requestPaint();
        }


        // /////////////////////////////////////////////////////////////////
        // Functions
        // /////////////////////////////////////////////////////////////////


        // /////////////////////////////////////////////////////////////////
        // Internals
        // /////////////////////////////////////////////////////////////////

        PropertyAnimation {
            id: chartAnimator;
            target: chartRoot;
            property: "chartAnimationProgress";
            to: 100;
            duration: 500;
            easing.type: Easing.InOutElastic;
        }
    }
}
