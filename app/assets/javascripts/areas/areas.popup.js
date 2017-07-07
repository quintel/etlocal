/*globals Areas,Popup*/

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

            $(closer).on('click', this.close.bind(this));

            return overlay;
        },

        close: function () {
            var closer = document.getElementById("popup-closer"),
                popup  = this.scope.map.getOverlays().item(0);

            popup.setPosition(undefined);
            closer.blur();
            return false;
        },

        open: function () {}
    };

    function Popup(scope) {
        this.scope = scope
    }

    return Popup;
}());
