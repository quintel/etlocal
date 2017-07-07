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

    // TODO: Clean-up
    function drawDynamicLegend() {
        var div,
            bar,
            min,
            max,
            colorDiv,
            colorSpan,
            stops,
            infoDiv,
            layerSpan,
            unitSpan,
            wrapper = $("<div/>").addClass("dynamic");

        this.data.layers.forEach(function (layer) {
            stops = this.data.stops[layer];
            div   = $("<div/>")
                .addClass(layer)
                .addClass("legend-item")
                .toggle(this.areas.layers.current().name === layer);

            // infoDiv part
            infoDiv   = $("<div/>");
            layerSpan = $("<span>").html(layer);

            infoDiv.append(layerSpan);

            if (this.data.unit) {
                unitSpan = $("<span>").html(" (" + this.data.unit + ")");

                infoDiv.append(unitSpan);
            }

            div.append(infoDiv);
            // End of infoDiv

            stops.legend.bars.forEach(function (stop) {
                bar = $("<div/>")
                    .addClass("bar");

                min = $("<span>")
                    .addClass("min")
                    .html(stop.min);

                max = $("<span>")
                    .addClass("max")
                    .html(stop.max);

                colorSpan = $("<span>")
                    .addClass("color");

                colorDiv = $("<div>")
                    .css("background-color", "rgba(" + stop.color.join(", ") + ")")
                    .addClass("color-div");

                colorSpan.append(colorDiv);
                bar.append(min, colorSpan, max);
                div.append(bar);
            });

            wrapper.append(div);
        }.bind(this));

        this.scope.append(wrapper);
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
