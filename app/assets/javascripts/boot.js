$(document).on('turbolinks:load', function () {
    'use strict';

    DatasetInterface.enable();

    $("ul.tab-nav").each(function (i) {
        var localSettings = new LocalSettings("t" + i);
        new Tab(this, localSettings).enable();
    });
});
