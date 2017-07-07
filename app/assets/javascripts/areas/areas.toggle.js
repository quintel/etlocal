/*globals Areas,Toggle*/

Areas.Toggle = (function () {
    'use strict';

    function clickHandle(e) {
        var scope = $(e.target).data('interface');

        this.buttons.removeClass("enabled");

        this.switchMode(scope);

        $(e.target).addClass("enabled");

        $("#interfaces .interface, #dataset-overlay").hide();
        $("#interfaces .interface." + scope).show();

        if (scope === 'dataset_selector') {
            $(".legend .colors").css({ "display": "none"});
        }
    }

    Toggle.prototype = {
        switchMode: function (mode) {
            var key,
                modus = this.areas.interfaces[mode];

            this.areas.resetPosition();
            this.areas.layers.switchMode(mode);
            this.areas.popup.close();

            for (key in this.areas.interfaces) {
                if (this.areas.interfaces.hasOwnProperty(key)) {
                    this.areas.interfaces[key].disable();
                }
            }

            modus.enable();
        },

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
