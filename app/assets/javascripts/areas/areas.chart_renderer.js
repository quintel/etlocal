Areas.ChartRenderer = (function () {
    'use strict';

    function updateChart(data) {
        var filter = ["in", data.layer_info.filter].concat(data.stops.map(function (stop) {
            return stop[0];
        }));

        this.areas.map.setPaintProperty(data.layer_info.name, 'fill-color', {
            type:     "categorical",
            property: data.layer_info.filter,
            stops:    data.stops
        });

        this.areas.map.setFilter(data.layer_info.name, filter);

        drawLegend.call(this, data.legend);
    }

    function drawLegend(legend) {
        var styles = [];

        $(".legend .colors").css({ "display": "inline-block"});
        $(".legend .max_value").text(legend.max + legend.unit);
        $(".legend .min_value").text(legend.min + legend.unit);

        ["-webkit-", "-o-", "-moz-", ""].forEach(function(prefix) {
            styles.push(prefix + "linear-gradient("
                + legend.max_color + ", " + legend.min_color + ")");
        });

        $(".legend .color-gradient").attr("style", "background: " + styles.join(";"));
    }

    ChartRenderer.prototype = {
        render: function () {
            $.ajax({
                url: "charts",
                type: "POST",
                data: {
                    chart: {
                        type: this.scope.chartType,
                        layer: this.scope.layerId
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
