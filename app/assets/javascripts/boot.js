$(document).on('turbolinks:load', function () {
    'use strict';

    FileUpload.setFields();
    DatasetInterface.enable();

    $("ul.tab-nav").each(function (i) {
        var localSettings = new LocalSettings("t" + i);
        new Tab(this, localSettings).enable();
    });
});
