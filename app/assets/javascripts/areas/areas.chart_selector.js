/*globals Areas,ChartSelector*/

Areas.ChartSelector = (function () {
    'use strict';

    function openPopup(position, feature, layer) {
        var source     = $('#default').html(),
            geoId      = feature.get(layer.get('filter')),
            name       = feature.get(layer.get('name_attr')),
            properties = feature.getProperties(),
            popup      = this.areas.map.getOverlays().item(0),
            content    = document.getElementById('popup-content');

        if (layer.get('name') === "provinces_ds") {
            geoId = geoId.toLowerCase();
        }

        $(content).find('h5').html(name);
        $(content).find('a.dataset-open').off('click').on('click', function (e) {
            e.preventDefault();

            $.ajax({
                type: "GET",
                dataType: 'script',
                url: 'datasets/' + geoId + '/commits/new.js'
            });
        })

        popup.setPosition(position);

        // Prevent people from clicking on the ETModel link
        $("a[disabled='disabled']").on("click", function (e) {
            e.preventDefault();
        });
    }

    function click(e) {
        // We'll assume for now that there will be only one feature to click
        // on. If this changes, please do so here.
        this.areas.map.forEachFeatureAtPixel(e.pixel, function (feature, layer) {
            openPopup.call(this, e.coordinate, feature, layer);
        }.bind(this));
    }

    ChartSelector.prototype = {
        enable: function () {
            this.areas.map.on('click', click.bind(this));

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
