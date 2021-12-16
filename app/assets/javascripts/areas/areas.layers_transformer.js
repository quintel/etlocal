/*globals Areas,LayersTransformer,ol*/

Areas.LayersTransformer = (function () {
    'use strict';

    LayersTransformer.prototype = {
        sources: {
            mvt: function (layer) {
                return new ol.source.VectorTile({
                    format: new ol.format.MVT(),
                    tilePixelRatio: 16,
                    url: layer.url.interpolate({
                        layer_id: layer.id,
                        access_token: this.mapboxGlToken
                    })
                });
            },

            wfs: function (layer) {
                return new ol.source.Vector({
                    format: new ol.format.GeoJSON(),
                    strategy: ol.loadingstrategy.tile(ol.tilegrid.createXYZ({ maxZoom: 16 })),
                    url: function (extent) {
                        return layer.url.interpolate({
                            bbox: extent.join(',')
                        });
                    }
                });
            },

            wms: function (layer) {
                return new ol.source.TileWMS({
                    url:    layer.url,
                    params: layer.params
                });
            }
        },

        // Each layer type (mvt, wms, wfs, etc.) is accompanied by a layer
        // source with an equal type in the sources.
        layers: {
            mvt: function (layer, source) {
                return new ol.layer.VectorTile({
                    name_attr:     layer.name_attr,
                    extent:        layer.extent,
                    minResolution: layer.minres,
                    maxResolution: layer.maxres,
                    visible:       false,
                    style:         this.scope.styles.normal,
                    source:        source
                });
            },

            wfs: function (layer, source) {
                return new ol.layer.Vector({
                    name:          layer.name,
                    id:            layer.id,
                    minResolution: layer.minres,
                    maxResolution: layer.maxres,
                    visible:       false,
                    style:         this.scope.styles.normal,
                    source:        source
                });
            },

            wms: function (layer, source) {
                return new ol.layer.Tile({
                    name:    layer.name,
                    id:      layer.id,
                    visible: false,
                    opacity: 0.7,
                    source:  source
                });
            }
        },

        transform: function () {
            var source;

            return this.layerData.map(function (layer) {
                source = this.sources[layer.type];

                if (!source) {
                    throw "No source for layer type: " + layer.type;
                }

                return this.layers[layer.type]
                    .call(this, layer, source.call(this, layer));
            }.bind(this));
        }
    };

    function LayersTransformer(scope, layerData) {
        this.mapboxGlToken = $(".hidden .mapbox-api-key").text();
        this.scope         = scope;
        this.layerData     = layerData;
    }

    return LayersTransformer;
}());
