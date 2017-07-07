/*globals Areas,Toggle*/

Areas.Toggle = (function () {
    'use strict';

    function clickHandle(e) {
        var scope = $(e.target).data('interface');

        this.buttons.removeClass("enabled");

        this.areas.switchMode(scope);

        $(e.target).addClass("enabled");

        $("#interfaces .interface, #dataset-overlay").hide();
        $("#interfaces .interface." + scope).show();

        if (scope === 'dataset_selector') {
            $(".legend .colors").css({ "display": "none"});
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
