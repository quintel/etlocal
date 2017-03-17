var Areas = (function () {
    'use strict';

    var styles = {
        normal: {
            "fill-outline-color": "rgba(255,0,0,1.0)",
            "fill-color": "rgba(0,0,0,0.0)"
        },
        filled: {
            "fill-outline-color": "#484896",
            "fill-color": "rgba(255,0,0,0.75)",
            "fill-opacity": 0.75
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
                paint:          styles[level],
                filter:         level === 'filled' ? layer.mapFilter : ['all']
            });
        }.bind(this));
    }

    function getFilter(bbox, layer) {
        var features = this.map.queryRenderedFeatures(bbox, {
            layers: [layer.name + '-normal']
        });

        if (features.length > 0) {
            return [
                '==',
                layer.filter,
                features[0].properties[layer.filter]
            ];
        }
    }

    function click(e) {
        var layer = this.currentLayer || this.layers[0],
            bbox  = [[e.point.x - 5, e.point.y - 5],
                     [e.point.x + 5, e.point.y + 5]];

        // Reset all filters
        this.layers.forEach(function (l) {
            this.map.setFilter(l.name + '-filled', layer.mapFilter);
        }.bind(this));

        // Set filter for current filled layer
        this.map.setFilter(layer.name + "-filled",
            getFilter.call(this, bbox, layer));
    }

    function zoom() {
        var currentZoom = this.map.getZoom(),
            filtered    = this.layers.filter(function (layer) {
                return currentZoom > layer.minzoom &&
                       currentZoom < layer.maxzoom
            });

        this.currentLayer = filtered[0];
    }

    function loaded() {
        this.layers.forEach(addLayer.bind(this));

        this.map.on('click', click.bind(this));
    }

    return {
        setColors: function () {
            this.layers.forEach(function (layer) {
                if (layer.name != "provinces") {
                    this.map.setPaintProperty(layer.name + '-normal', 'fill-color',
                        { property: 'AANTAL_HH',
                          stops: [[20000, 'rgba(255, 255, 255, 0.0)'], [200000, 'rgba(0, 0, 255, 0.5)']] }
                    );
                }
            }.bind(this));
        },

        init: function () {
            mapboxgl.accessToken = $(".hidden .mapbox-api-key").text();

            this.layers = JSON.parse($(".hidden .layers").html());

            this.map = new mapboxgl.Map({
                container: 'map',
                style: 'mapbox://styles/mapbox/light-v9',
                center: [5.584687, 52.231560],
                zoom: 6.5,
                minZoom: 6
            });

            this.map.on('zoom', zoom.bind(this));
            this.map.on('load', loaded.bind(this));
        }
    }
}());
