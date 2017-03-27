$(document).on('turbolinks:load', function () {
    'use strict';

    FileUpload.setFields();
    DatasetInterface.enable();
    Areas.init();
});
