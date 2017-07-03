/*globals Areas,ChartRenderer*/

Areas.ChartRenderer = (function () {
    'use strict';

    function colorAreas(layer, stops) {
        var region,
            colorStops = stops[layer.get('name')];

        layer.setStyle(function (feature) {
            region = feature.get(layer.get('filter'));

            return [new ol.style.Style({
                fill: new ol.style.Fill({
                    color: colorStops.stops[region] || [0, 0, 0, 0]
                })
            })];
        });

        //drawLegend.call(this, data.legend);
    }

    function updateLayer(layer, data) {
        var isVisible = (data.layers.indexOf(layer.get('name')) > -1);

        layer.setVisible(isVisible);

        if (data.stops && isVisible) {
            colorAreas.call(this, layer, data.stops);
        }
    }

    function updateChart(data) {
        this.areas.map.getLayers().forEach(function (layer) {
            if (layer.get('name')) {
                updateLayer.call(this, layer, data);
            }
        }.bind(this));
    }

    //function drawLegend(legend) {
    //    var styles = [];

    //    $(".legend .colors").css({ "display": "inline-block"});
    //    $(".legend .max_value").text(legend.max + legend.unit);
    //    $(".legend .min_value").text(legend.min + legend.unit);

    //    ["-webkit-", "-o-", "-moz-", ""].forEach(function (prefix) {
    //        styles.push(prefix + "linear-gradient("
    //            + legend.max_color + ", " + legend.min_color + ")");
    //    });

    //    $(".legend .color-gradient").attr("style", "background: " + styles.join(";"));
    //}

    ChartRenderer.prototype = {
        render: function () {
            $.ajax({
                url: "charts",
                type: "POST",
                data: {
                    chart: {
                        type: this.scope.chartType
                    }
                },
                success: updateChart.bind(this)
            });
        }
    };

    function ChartRenderer(scope) {
        this.scope = scope;
        this.areas = scope.areas;
    }

    return ChartRenderer;
}());
