/*globals Areas,VisualMode*/

Areas.VisualMode = (function () {
    'use strict';

    function selectDisplayOption(e) {
        this.chartType = $(e.target).val();

        new Areas.ChartRenderer(this).render();
    }

    VisualMode.prototype = {
        enable: function () {
            this.displaySelect
                .on("change", selectDisplayOption.bind(this));

            this.areas.layers.eachLayer(function (layer, group) {
                if (group === 'dataset_selector') {
                    layer.setVisible(false);
                }
            });

            selectDisplayOption.call(this, { target: this.displaySelect });
        },

        disable: function () {
            this.displaySelect.off("change");
            this.scope.find("button.apply-options").off("click");
        }
    };

    function VisualMode(areas) {
        this.areas         = areas;
        this.scope         = $(".interface.chart");
        this.displaySelect = this.scope.find("select#display_options");
    }

    return VisualMode;
}());
