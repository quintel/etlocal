$(document).on('turbolinks:load', function () {
    'use strict';

    $("div.editable strong.key, div.editable span.val").on("click.enable", function () {
        $("div.editable").removeClass("enabled");

        $(this).parents(".editable").addClass("enabled");
    });

    $("div.editable .button.cancel").on("click.disable", function (e) {
        e.preventDefault();

        $(this).parents(".editable").removeClass("enabled");
    });
});
