var Areas = (function () {
    'use strict';

    var styles = {
        normal: {
            "fill-outline-color": "#888888",
            "fill-color": "rgba(0,0,0,0.0)"
        },
        filled: {
            "fill-outline-color": "#888888",
            "fill-color": "rgba(120,120,120,0.75)"
        }
    };

    function addLayer(layer) {
        this.map.addSource(layer.name, {
            type: 'vector',
            url: 'mapbox://' + layer.id
        });

        layer.mapFilter = ["==", layer.filter, ''];

        ['normal', 'filled'].forEach(function (level) {
            this.map.addLayer({
                id:             layer.name + '-' + level,
                type:           'fill',
                source:         layer.name,
                minzoom:        layer.minzoom,
                maxzoom:        layer.maxzoom,
                'source-layer': layer.source,
                paint:          $.extend(styles[level], layer.styles),
                filter:         level === 'filled' ? layer.mapFilter : ['all']
            });
        }.bind(this));
    }

    function clearLayerFilters() {
        this.layers.forEach(function (l) {
            this.map.setFilter(l.name + '-filled', l.mapFilter);
        }.bind(this));
    }

    function openPopUp(position, feature, layer) {
        var source   = $('#default').html(),
            property = feature.properties[layer.filter];

        feature.properties.geoId = feature.properties[layer.filter];

        if (layer.name === "provinces") {
            feature.properties.geoId = feature.properties.geoId.toLowerCase();
        }

        this.currentPopUp = new mapboxgl.Popup()
            .setLngLat(this.map.unproject(position))
            .setHTML(Handlebars.compile(source)(feature.properties))
            .addTo(this.map);
    }

    function click(e) {
        var layer    = this.currentLayer || this.layers[0],
            bbox     = [[e.point.x - 5, e.point.y - 5],
                        [e.point.x + 5, e.point.y + 5]],
            features = this.map.queryRenderedFeatures(bbox, {
                layers: [ layer.name + '-normal' ]
            });

        if (features.length > 0) {
            openPopUp.call(this, e.point, features[0], layer);
        }

        this.map.setFilter(layer.name + "-filled", features.length > 0
            ? ['==', layer.filter, features[0].properties[layer.filter]]
            : layer.mapFilter);
    }

    function zoom() {
        var currentZoom   = this.map.getZoom(),
            previousLayer = this.currentLayer || this.layers[0],
            filtered      = this.layers.filter(function (layer) {
                return currentZoom > layer.minzoom &&
                       currentZoom < layer.maxzoom
            });

        this.currentLayer = filtered[0];

        if (previousLayer != this.currentLayer && this.currentPopUp) {
            this.currentPopUp.remove();
        }
    }

    function loaded() {
        this.layers.forEach(addLayer.bind(this));

        this.map.on('click', click.bind(this));
    }

    return {
        init: function () {
            if ($("#map").length < 1) { return; }

            mapboxgl.accessToken = $(".hidden .mapbox-api-key").text();

            this.layers = JSON.parse($(".hidden .layers").html()).dataset_selector;

            this.map = new mapboxgl.Map({
                container: 'map',
                style: 'mapbox://styles/grdw/cj0l07vpv004d2qjr4s46hxcq',
                center: [5.594687, 51.831560],
                zoom: 6.5,
                minZoom: 6
            });

            this.map.addControl(new mapboxgl.NavigationControl());
            this.map.on('zoom', zoom.bind(this));
            this.map.on('load', loaded.bind(this));
        }
    }
}());
