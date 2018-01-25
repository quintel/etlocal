/*globals Areas,DatasetSelector,ol*/

Areas.DatasetSelector = (function () {
    'use strict';

    var GROUP = 'dataset_selector';

    function openPopup(position, feature, layer) {
        var geoId      = feature.get(layer.get('filter')),
            name       = feature.get(layer.get('name_attr')),
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
                url: '/datasets/' + geoId + '/edit.js'
            });
        });

        popup.setPosition(position);

        // Prevent people from clicking on the ETModel link
        $("a[disabled='disabled']").on("click", function (e) {
            e.preventDefault();
        });
    }

    function click(e) {
        // We'll assume for now that there will be only one feature to click
        // on. If this changes, please do so here.
        this.areas.map.forEachFeatureAtPixel(e.pixel, function (selectedFeature, layer) {
            layer.setStyle(function (feature) {
                var filter   = layer.get('filter'),
                    isFilled = feature.get(filter) === selectedFeature.get(filter),
                    style    = isFilled ? 'filled' : 'normal';

                return [this.areas.layers.styles[style]];
            }.bind(this));

            openPopup.call(this, e.coordinate, selectedFeature, layer);
        }.bind(this));
    }

    DatasetSelector.prototype = {
        enable: function () {
            this.eventKey = this.areas.map.on('click', click.bind(this));

            this.areas.layers.eachLayer(function (layer, group) {
                layer.setVisible(group === GROUP);

                if (group === GROUP) {
                    layer.setStyle(this.styles.normal);
                }
            });

            this.closeButtonOverlay.on("click", function (e) {
                e.preventDefault();

                $("#dataset-overlay").hide();
                $('.content-map .container #search-bar').show();
            });
        },

        disable: function () {
            ol.Observable.unByKey(this.eventKey);

            this.closeButtonOverlay.off("click");
        }
    };

    function DatasetSelector(areas) {
        this.areas = areas;
        this.closeButtonOverlay = $("#dataset-overlay .button-close a");
    }

    return DatasetSelector;
}());
