var DatasetInterface = (function () {
    'use strict';

    return {
        enable: function () {
            $("div.input").on("click.enable", function () {
                $("div.editable").removeClass("enabled");

                $(this).parents(".editable").addClass("enabled");
            });

            $("div.editable .button.cancel").on("click.disable", function (e) {
                e.preventDefault();

                $(this).parents(".editable").removeClass("enabled");
            });
        }
    }
}());
