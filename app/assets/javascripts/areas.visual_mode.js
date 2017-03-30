Areas.VisualMode = (function () {
    'use strict';

    function selectLayer(e) {
        var layerId = $(e.target).val();

        this.areas.layers.setVisibility('chart', layerId, 'visible');
    }

    function selectDisplayOption() {

    }

    VisualMode.prototype = {
        enable: function () {
            this.scope.find("select#layers")
                .on("change", selectLayer.bind(this));

            this.scope.find("select#display_options")
                .on("change", selectDisplayOption.bind(this));

            selectLayer.call(this, { target: this.scope.find("select#layers") });
        },

        disable: function () {
            this.scope.find("select#layers").off("change");
            this.scope.find("select#display_options").off("change");
            this.scope.find("button.apply-options").off("click");
        }
    };

    function VisualMode(areas) {
        this.areas = areas;
        this.scope = $(".interface.chart");
    }

    return VisualMode;
}());
