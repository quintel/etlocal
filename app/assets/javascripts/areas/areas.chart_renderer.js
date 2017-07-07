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
    }

    function updateLayer(layer, data) {
        var isVisible = (data.layers.indexOf(layer.get('name')) > -1);

        layer.setVisible(isVisible);

        if (data.stops && isVisible) {
            colorAreas.call(this, layer, data.stops);
        }

        if (isVisible) {
            new Areas.Legend(this.areas, data).draw();
        }
    }

    function updateChart(data) {
        this.areas.map.getLayers().forEach(function (layer) {
            if (layer instanceof ol.layer.Group) {
                layer.getLayers().forEach(function (layer) {
                    if (layer.get('name')) {
                        updateLayer.call(this, layer, data);
                    }
                }.bind(this));
            }
        }.bind(this));
    }

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
