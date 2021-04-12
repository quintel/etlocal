/*globals Areas,Popup,ol*/

Areas.Popup = (function () {
    'use strict';

    Popup.prototype = {
        get: function () {
            var popup      = document.getElementById("popup"),
                closer     = document.getElementById("popup-closer"),
                overlay    = new ol.Overlay({
                    element: popup,
                    autoPan: true,
                    autoPanAnimation: {
                        duration: 250
                    }
                });

            if ($(closer).length > 0){
                $(closer).on('click', this.close.bind(this));
            }

            return overlay;
        },

        close: function () {
            var closer = document.getElementById("popup-closer"),
                popup  = this.scope.map.getOverlays().item(0);

            popup.setPosition(undefined);
            if ($(closer).length > 0){
                closer.blur();
            }
            return false;
        }
    };

    function Popup(scope) {
        this.scope = scope;
    }

    return Popup;
}());
