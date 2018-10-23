/*globals Areas,Layers,ol*/

Areas.Layers = (function () {
    'use strict';

    var COLOR = [210, 115, 115];

    function setStyles() {
        return {
            normal: new ol.style.Style({
                stroke: new ol.style.Stroke({
                    color: COLOR,
                    width: 2
                })
            }),
            filled: new ol.style.Style({
                stroke: new ol.style.Stroke({
                    color: COLOR,
                    width: 2
                }),
                fill: new ol.style.Fill({
                    color: COLOR.concat([0.75])
                })
            })
        };
    }

    function setLayers() {
        return [
            new ol.layer.Tile({
                source: new ol.source.OSM()
            }),
            new ol.layer.Group({
                group: 'dataset_selector',
                layers: new Areas.LayersTransformer(this, this.layers.dataset_selector).transform()
            }),
            new ol.layer.Group({
                group: 'chart',
                layers: new Areas.LayersTransformer(this, this.layers.chart).transform()
            })
        ];
    }

    Layers.prototype = {
        setCurrent: function (layer) {
            this.currentLayer = layer;
        },

        eachLayer: function (func) {
            var group,
                func = func || function () { return; };

            this.areas.map.getLayers().forEach(function (layer) {
                if (layer instanceof ol.layer.Group) {
                    group = layer.get('group');

                    layer.getLayers().forEach(function (layer) {
                        func.call(this, layer, group);
                    }.bind(this));
                }
            }.bind(this));
        },

        current: function () {
            return this.currentLayer;
        },

        filter: function (method) {
            return this.layers.dataset_selector.filter(method);
        },

        minResolution: function() {
            return Math.min.apply(
                null,
                this.layers.dataset_selector.map(function(layer) {
                    return layer.minres
                })
            );
        }
    };

    function Layers(areas) {
        this.areas         = areas;
        this.layers        = JSON.parse($(".hidden .layers").html());
        this.styles        = setStyles.call(this);
        this.layerGroups   = setLayers.call(this);
    }

    return Layers;
}());
