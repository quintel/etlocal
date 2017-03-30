Areas.VisualMode = (function () {
    'use strict';

    function selectLayer(e) {
        this.layerId = $(e.target).val();

        this.areas.layers.setVisibility('chart', this.layerId, 'visible');

        if (!e.skip) {
            new Areas.ChartRenderer(this).render();
        }
    }

    function selectDisplayOption(e) {
        this.chartType = $(e.target).val();

        new Areas.ChartRenderer(this).render();
    }

    VisualMode.prototype = {
        enable: function () {
            this.layersSelect
                .on("change", selectLayer.bind(this));

            this.displaySelect
                .on("change", selectDisplayOption.bind(this));

            selectLayer.call(this, { target: this.layersSelect, skip: true });

            selectDisplayOption.call(this, { target: this.displaySelect });
        },

        disable: function () {
            this.layersSelect.off("change");
            this.displaySelect.off("change");
            this.scope.find("button.apply-options").off("click");
        }
    };

    function VisualMode(areas) {
        this.areas         = areas;
        this.scope         = $(".interface.chart");
        this.layersSelect  = this.scope.find("select#layers");
        this.displaySelect = this.scope.find("select#display_options");
    }

    return VisualMode;
}());
