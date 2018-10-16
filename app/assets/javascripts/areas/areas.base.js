/*globals ol*/

var Areas = (function () {
    'use strict';

    function zoom() {
        var currentRes    = this.view.getResolution(),
            previousLayer = this.layers.current(),
            filtered      = this.layers.filter(function (layer) {
                return currentRes > layer.minres &&
                       currentRes < layer.maxres;
            });

        this.layers.setCurrent(filtered[0]);

        if (previousLayer !== filtered[0]) {
            this.popup.close();
            $(".dynamic .legend-item").hide();

            if (filtered[0]) {
                $(".dynamic .legend-item." + filtered[0].name).show();
            }
        }
    }

    function drawMap() {
        this.center = [5.494687, 52.231560];
        this.zoom   = 7.9;

        this.view = new ol.View({
            center: ol.proj.fromLonLat(this.center),
            zoom: this.zoom
        });

        this.map = new ol.Map({
            controls: ol.control.defaults().extend([
                new Areas.ResetButton({ scope: this })
            ]),
            target: 'map',
            overlays: [this.popup.get()],
            layers: this.layers.layerGroups,
            view: this.view
        });

        this.map.on('moveend', zoom.bind(this));
        this.toggle.enable();
        this.toggle.switchMode('dataset_selector');
    }

    return {
        init: function () {
            if ($("#map").length < 1) { return; }

            ol.inherits(Areas.ResetButton, ol.control.Control);

            this.layers       = new Areas.Layers(this);
            this.searchBox    = new Areas.Search(this, $("form#search"));
            this.toggle       = new Areas.Toggle(this);
            this.popup        = new Areas.Popup(this);

            this.interfaces   = {
                chart:            new Areas.VisualMode(this),
                dataset_selector: new Areas.DatasetSelector(this)
            };

            drawMap.call(this);

            return this;
        }
    };
}());
