/*globals Areas,Layers,ol*/

Areas.Layers = (function () {
    'use strict';

    var NL_EXTENT = [378486.2686971302, 6568397.781293049,
                     801500.3337115699, 7094762.123545771];

    function setStyles() {
        return {
            normal: new ol.style.Style({
                stroke: new ol.style.Stroke({
                    color: "#CC6060",
                    width: 2
                })
            }),
            filled: {
                stroke: new ol.style.Stroke({
                    color: "#FFFFFF"
                }),
                fill: new ol.style.Fill({
                    color: 'rgba(135,160,160,0.75)'
                })
            }
        };
    }

    function transformLayers(layers, visible) {
        return layers.map(function (layer) {
            var source = new ol.source.VectorTile({
                format: new ol.format.MVT(),
                tilePixelRatio: 16,
                url: 'https://{a-d}.tiles.mapbox.com/v4/' + layer.id + '/{z}/{x}/{y}.vector.pbf?access_token=' + this.mapboxGlToken
            });

            return new ol.layer.VectorTile({
                source:        source,
                extent:        NL_EXTENT,
                minResolution: layer.minres,
                maxResolution: layer.maxres,
                visible:       visible,
                style:         this.styles.normal,
                filter:        layer.filter,
                name:          layer.name,
                name_attr:     layer.name_attr
            });
        }.bind(this));
    }

    function transformChartLayers(layers) {
        return layers.map(function (layer) {
            return new ol.layer.Tile({
                name: layer.name,
                id: layer.id,
                visible: false,
                opacity: 0.7,
                source: new ol.source.TileWMS({
                    url: layer.url,
                    params: layer.params
                })
            })
        });
    }

    function setLayers() {
        var base = [new ol.layer.Tile({
            source: new ol.source.OSM()
        })];

        return {
            dataset_selector: new ol.layer.Group({
                layers: base.concat(transformLayers.call(this, this.layers.dataset_selector, true))
            }),
            chart: new ol.layer.Group({
                layers: base
                    .concat(transformLayers.call(this, this.layers.dataset_selector, false))
                    .concat(transformChartLayers.call(this, this.layers.chart))
            })
        };
    }

    Layers.prototype = {
        setCurrent: function (layer) {
            this.currentLayer = layer;
        },

        switchMode: function (mode) {
            this.areas.map.setLayerGroup(this.layerGroups[mode]);
        },

        current: function () {
            return this.currentLayer;
        },

        filter: function (method) {
            return this.layers.dataset_selector.filter(method);
        },

        eachDatasetLayer: function (method) {
            this.layers.dataset_selector.forEach(method);
        }
    };

    function Layers(areas) {
        this.areas         = areas;
        this.mapboxGlToken = $(".hidden .mapbox-api-key").text();
        this.layers        = JSON.parse($(".hidden .layers").html());
        this.styles        = setStyles.call(this);
        this.layerGroups   = setLayers.call(this);
    }

    return Layers;
}());
