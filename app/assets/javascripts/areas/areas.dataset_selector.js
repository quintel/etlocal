/*globals Areas,DatasetSelector,ol*/

Areas.DatasetSelector = (function () {
    'use strict';

    var GROUP = 'dataset_selector';

    function openPopup(position, data) {
        var popup   = this.areas.map.getOverlays().item(0),
            content = document.getElementById('popup-content');

        $(content).find('h5').html(data.name);
        $(content).find('em').html(data.group);
        $(content).find('a.dataset-open')
            .off('click')
            .on('click', function (e) {
                e.preventDefault();

                history.pushState(data.id, data.name, '/datasets/' + data.geo_id);
                DatasetInterface.open(data.id);
            });

        popup.setPosition(position);
    }

    // Private: findDataset()
    //
    // Finds a dataset based on the 'id' feature property.
    // All layer features needs an 'id' attribute. See
    // https://github.com/quintel/etlayers why that is.
    //
    function findDataset(position, layer, feature) {
        var geoId = feature.get(layer.get('name_attr'))

        geoId = geoId === 'GB' ? 'UK' : geoId
        geoId = geoId === 'GR' ? 'EL' : geoId

        $.ajax({
            url: "/datasets/" + geoId + ".json",
            type: 'GET',
            dataType: 'json',
            success: function (data) {
                if (data) {
                    colourDataset.call(this, layer, feature)
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

    function colourDataset(layer, selectedFeature) {
        var identifier = layer.get('name_attr')

        layer.setStyle(function (feature) {
            var isFilled = feature.get(identifier) === selectedFeature.get(identifier),
                style    = isFilled ? 'filled' : 'normal';

            return [this.areas.layers.styles[style]];
        }.bind(this));
    }

    function click(e) {
        // We'll assume for now that there will be only one feature to click
        // on. If this changes, please do so here.
        this.areas.map.forEachFeatureAtPixel(e.pixel, function (selectedFeature, layer) {
            findDataset.call(this, e.coordinate, layer, selectedFeature);
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

                history.pushState('', '', '/');
                $("#dataset-overlay").hide();
                $('#dataset-overlay .content').empty();
                $('.content-map .container #search-bar-holder').show();
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
