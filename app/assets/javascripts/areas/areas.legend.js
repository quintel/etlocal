/*globals Areas,Legend*/

Areas.Legend = (function () {
    'use strict';

    function clear() {
        this.scope.html('');
    }

    function drawStaticLegend() {
        var img = "/assets/" + this.data.chart_type + ".png",
            imgTag = $("<img/>").attr("src", img);

        this.scope.html(imgTag);
    }

    function drawDynamicLegend() {
        var legend  = Handlebars.compile($("#legend").html()),
            current = this.areas.layers.currentLayer.name;

        this.scope.append(legend(this.data));
        this.scope.find(".legend-item." + current).show();
    }

    Legend.prototype = {
        draw: function () {
            clear.call(this);

            switch (this.data.legend_type) {
                case 'static':
                    drawStaticLegend.call(this);
                    break;
                case 'dynamic':
                    drawDynamicLegend.call(this);
                    break;
                case 'none':
                    break;
                default:
                    throw "unknown type: " + this.data.type;
                    break;
            }
        }
    };

    function Legend(areas, data) {
        this.areas = areas;
        this.data  = data;
        this.scope = $(".interface.chart .legend");
    }

    return Legend;
}());
