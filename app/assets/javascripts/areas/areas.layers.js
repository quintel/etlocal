Areas.Layers = (function () {
    'use strict';

    var styles = {
        normal: {
            "fill-outline-color": "#87a0a0",
            "fill-color":         "rgba(0,0,0,0.0)"
        },
        filled: {
            "fill-outline-color": "#87a0a0",
            "fill-color":         "rgba(135,160,160,0.75)"
        },
        visual: {
            "fill-color":         "rgba(135,160,160,0.25)"
        }
    };

    function addSource(layer) {
        this.areas.map.addSource(layer.name, {
            type: 'vector',
            url: 'mapbox://' + layer.id
        });
    }

    function buildLayer(layer, type, level) {
        if (level === 'filled') {
            layer.mapFilter = ["==", layer.filter, ''];
        }

        return {
            id:             [layer.name, level].join(''),
            type:           'fill',
            source:         layer.name,
            minzoom:        layer.minzoom || 0,
            maxzoom:        layer.maxzoom || 12,
            'source-layer': layer.source,
            paint:          $.extend(styles[level], layer.styles),
            filter:         layer.mapFilter ? layer.mapFilter : ['all'],
            layout: {
                visibility: 'none'
            }
        }
    }

    function addLayer(layer, type) {
        addSource.call(this, layer);

        this.layerStyles[type].forEach(function (level) {
            this.areas.map.addLayer(buildLayer(layer, type, level));
        }.bind(this));
    }

    Layers.prototype = {
        setVisibilityLayers: function (layers, property) {
            this.layers[layers].forEach(function (layer) {
                this.layerStyles[layers].forEach(function(style) {
                    this.areas.map.setLayoutProperty(
                        [layer.name, style].join(''), 'visibility', property);
                }.bind(this));
            }.bind(this));
        },

        setVisibility: function (layers, layerId, property) {
            this.setVisibilityLayers(layers, 'none');

            this.areas.map.setLayoutProperty(layerId, 'visibility', property);
        },

        setCurrent: function (layer) {
            this.currentLayer = layer;
        },

        switchMode: function (mode) {
            if (mode === "chart") {
                this.setVisibilityLayers('dataset_selector', 'none');
            } else if (mode === "dataset_selector") {
                this.setVisibilityLayers(mode, 'visible');
                this.setVisibilityLayers('chart', 'none');
            }
        },

        current: function () {
            return this.currentLayer;
        },

        filter: function (method) {
            return this.layers.dataset_selector.filter(method);
        },

        eachDatasetLayer: function (method) {
            this.layers.dataset_selector.forEach(method);
        },

        draw: function () {
            for (var layerKey in this.layers) {
                if (this.layers.hasOwnProperty(layerKey)) {
                    this.layers[layerKey].forEach(function (layer) {
                        addLayer.call(this, layer, layerKey);
                    }.bind(this));
                }
            }

            this.setCurrent(this.layers.dataset_selector[0]);
        }
    };

    function Layers(areas) {
        this.layers      = JSON.parse($(".hidden .layers").html());
        this.areas       = areas;
        this.layerStyles = {
            dataset_selector: ['normal', 'filled'],
            chart:            ['']
        };
    }

    return Layers;
}());
