$(document).on('turbolinks:load', function () {
    'use strict';

    $("div.editable").on("click.enable", function () {
        $("div.editable").removeClass("enabled");

        $(this).addClass("enabled");
    });

    $("div.editable .button.cancel").on("click.disable", function (e) {
        e.preventDefault();
    });
});
