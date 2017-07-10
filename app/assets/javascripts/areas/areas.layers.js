/*globals Areas,Layers,ol*/

Areas.Layers = (function () {
    'use strict';

    var NL_EXTENT = [378486.2686971302, 6568397.781293049,
                     801500.3337115699, 7094762.123545771],
        COLOR     = [210, 115, 115];

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

    function transformLayers(layers) {
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
                visible:       false,
                style:         this.styles.normal,
                filter:        layer.filter,
                name:          layer.name,
                name_attr:     layer.name_attr
            });
        }.bind(this));
    }

    function transformChartLayers(layers) {
        return layers.map(function (layer) {
            var olLayer;

            if (layer.type === 'wms') {
                olLayer = new ol.layer.Tile({
                    name:    layer.name,
                    id:      layer.id,
                    visible: false,
                    opacity: 0.7,
                    source:  new ol.source.TileWMS({
                        url: layer.url,
                        params: layer.params
                    })
                });
            } else if (layer.type === 'wfs') {
                var source = new ol.source.Vector({
                    format: new ol.format.GeoJSON(),
                    strategy: ol.loadingstrategy.tile(ol.tilegrid.createXYZ({ maxZoom: 16 })),
                    url: function (extent, resolution, projection) {
                        return layer.url.interpolate({
                            bbox: extent.join(',')
                        });
                    }
                });

                olLayer = new ol.layer.Vector({
                    name:          layer.name,
                    id:            layer.id,
                    minResolution: layer.minres,
                    maxResolution: layer.maxres,
                    visible:       false,
                    style:         this.styles.normal,
                    source:        source
                });
            } else {
                throw "Uknown chart type: " + layer.type;
            }

            return olLayer;
        }.bind(this));
    }

    function setLayers() {
        return [
            new ol.layer.Tile({
                source: new ol.source.OSM()
            }),
            new ol.layer.Group({
                group: 'dataset_selector',
                layers: transformLayers.call(this, this.layers.dataset_selector)
            }),
            new ol.layer.Group({
                layers: transformChartLayers.call(this, this.layers.chart)
            })
        ];
    }

    Layers.prototype = {
        setCurrent: function (layer) {
            this.currentLayer = layer;
        },

        switchMode: function (mode) {
            var group;

            this.areas.map.getLayers().forEach(function (layer) {
                group = layer.get('group');

                if (group) {
                    layer.getLayers().forEach(function (layer) {
                        layer.setVisible(group === mode);
                        layer.setStyle(this.styles.normal);
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
