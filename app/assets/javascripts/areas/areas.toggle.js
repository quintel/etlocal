Areas.Toggle = (function () {
    'use strict'

    function clickHandle(e) {
        var scope = $(e.target).data('interface');

        this.buttons.removeClass("enabled");
        this.areas.switchMode(scope);

        $(e.target).addClass("enabled");

        $("#interfaces .interface, #dataset-overlay").hide();
        $("#interfaces .interface." + scope).show();

        if (scope === 'chart') {
            this.areas.disableZoomAndReset();
            $(".mapboxgl-ctrl-group").hide();
        } else if (scope === 'dataset_selector') {
            this.areas.enableZoom();
            $(".legend .colors").css({ "display": "none"});
            $(".mapboxgl-ctrl-group").show();
        }
    }

    Toggle.prototype = {
        enable: function () {
            this.buttons = this.scope.find("button");

            this.buttons.on("click", clickHandle.bind(this));
        }
    };

    function Toggle(areas) {
        this.areas = areas;
        this.scope = $(".toggle-editor");
    }

    return Toggle;
}());
