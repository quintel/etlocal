/*globals Areas,DatasetSelector,ol*/

Areas.DatasetSelector = (function () {
    'use strict';

    var GROUP = 'dataset_selector';

    function openPopup(position, data) {
        var popup   = this.areas.map.getOverlays().item(0),
            content = document.getElementById('popup-content');

        $(content).find('h5').html(data.area);
        $(content).find('a.dataset-open')
            .off('click')
            .on('click', function (e) {
                e.preventDefault();

                DatasetInterface.open(data.id);
            });

        popup.setPosition(position);

        // Prevent people from clicking on the ETModel link
        $("a[disabled='disabled']").on("click", function (e) {
            e.preventDefault();
        });
    }

    // Private: findDataset()
    //
    // Finds a dataset based on the 'id' feature property.
    // All layer features needs an 'id' attribute. See
    // https://github.com/quintel/etlayers why that is.
    //
    function findDataset(position, feature) {
        var geoId = feature.get('id');

        $.ajax({
            url: "/datasets/" + geoId + ".json",
            type: 'GET',
            dataType: 'json',
            success: function (data) {
                if (data) {
                    openPopup.call(this, position, data);
                } else if (console) {
                    console.log("No dataset with " + geoId + " found");
                }
            }.bind(this),
            error: function (e) {
                alert(e);
            }
        });
    }

    function click(e) {
        // We'll assume for now that there will be only one feature to click
        // on. If this changes, please do so here.
        this.areas.map.forEachFeatureAtPixel(e.pixel, function (selectedFeature, layer) {
            layer.setStyle(function (feature) {
                var isFilled = feature.get('id') === selectedFeature.get('id'),
                    style    = isFilled ? 'filled' : 'normal';

                return [this.areas.layers.styles[style]];
            }.bind(this));

            findDataset.call(this, e.coordinate, selectedFeature);
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
