Areas.ChartSelector = (function () {
    'use strict';

    function openPopup(position, feature, layer) {
        var source   = $('#default').html(),
            property = feature.properties[layer.filter];

        feature.properties.geoId = feature.properties[layer.filter];

        if (layer.name === "provinces") {
            feature.properties.geoId = feature.properties.geoId.toLowerCase();
        }

        this.areas.currentPopup = new mapboxgl.Popup()
            .setLngLat(this.areas.map.unproject(position))
            .setHTML(Handlebars.compile(source)(feature.properties))
            .addTo(this.areas.map);

        // Prevent people from clicking on the ETModel link
        $("a[disabled='disabled']").on("click", function (e) {
            e.preventDefault()
        });
    }

    function click(e) {
        var layer    = this.areas.layers.current(),
            bbox     = [[e.point.x - 5, e.point.y - 5],
                        [e.point.x + 5, e.point.y + 5]],
            features = this.areas.map.queryRenderedFeatures(bbox, {
                layers: [ layer.name + 'normal' ]
            });

        if (features.length > 0) {
            openPopup.call(this, e.point, features[0], layer);
        }

        this.areas.map.setFilter(layer.name + "filled", features.length > 0
            ? ['==', layer.filter, features[0].properties[layer.filter]]
            : layer.mapFilter);
    }

    ChartSelector.prototype = {
        enable: function () {
            if(!this.areas.map.listens('click')) {
                this.areas.map.on('click', click.bind(this));
            }

            this.closeButtonOverlay.on("click", function (e) {
                e.preventDefault();

                $("#dataset-overlay").hide();
                $('.content-map .container #search-bar').show();
            });
        },

        disable: function () {
            this.closeButtonOverlay.off("click");
        }
    };

    function ChartSelector(areas) {
        this.areas = areas;
        this.closeButtonOverlay = $("#dataset-overlay .button-close a");
    }

    return ChartSelector;
}());
