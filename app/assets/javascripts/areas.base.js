var Areas = (function () {
    'use strict';

    function zoom() {
        var currentZoom   = this.map.getZoom(),
            previousLayer = this.layers.current(),
            filtered      = this.layers.filter(function (layer) {
                return currentZoom > layer.minzoom &&
                       currentZoom < layer.maxzoom
            });

        this.layers.setCurrent(filtered[0]);

        if (previousLayer != filtered[0]) {
            this.closePopup();
        }
    }

    function loaded() {
        this.toggle.enable();
        this.layers.draw();
        this.switchMode('dataset_selector');
    }

    function drawMap() {
        this.center = [5.594687, 52.031560];
        this.zoom   = 6.8;

        this.map = new mapboxgl.Map({
            container: 'map',
            style: 'mapbox://styles/grdw/cj0l07vpv004d2qjr4s46hxcq',
            center: this.center,
            zoom: this.zoom,
            minZoom: 6
        });

        this.map.addControl(new mapboxgl.NavigationControl());
        this.map.on('zoom', zoom.bind(this));
        this.map.on('load', loaded.bind(this));
    }

    return {
        disableZoomAndReset: function () {
            this.map.scrollZoom.disable();
            this.map.doubleClickZoom.disable();
            this.map.flyTo({ center: this.center, zoom: this.zoom });
        },

        enableZoom: function () {
            this.map.scrollZoom.enable();
            this.map.doubleClickZoom.enable();
        },

        switchMode: function (mode) {
            this.layers.switchMode.call(this.layers, mode);
            this.closePopup();

            for (var key in this.interfaces) {
                if (this.interfaces.hasOwnProperty(key)) {
                    this.interfaces[key].disable();
                }
            }

            this.interfaces[mode].enable();
        },

        closePopup: function () {
            if (this.currentPopup) {
                this.currentPopup.remove();
            }
        },

        init: function () {
            if ($("#map").length < 1) { return; }

            mapboxgl.accessToken = $(".hidden .mapbox-api-key").text();

            this.layers       = new Areas.Layers(this);
            this.searchBox    = new Areas.Search(this, $("form#search"));
            this.toggle       = new Areas.Toggle(this);

            this.interfaces   = {
                chart:            new Areas.VisualMode(this),
                dataset_selector: new Areas.ChartSelector(this)
            };

            drawMap.call(this);

            return this;
        }
    }
}());
