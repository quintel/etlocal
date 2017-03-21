$(document).on('turbolinks:load', function () {
    'use strict';

    FileUpload.setFields();
    DatasetInterface.enable();
    Areas.init();

    $("#dataset-overlay .button-close a").on("click", function (e) {
        e.preventDefault();

        $("#dataset-overlay").hide();
    });
});
