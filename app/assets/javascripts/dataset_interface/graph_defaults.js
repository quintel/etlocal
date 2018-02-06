var GraphDefaults = {
    fetch: function (datasetId) {
        'use strict';

        var result = null;

        if (!this.defaults) {
            // If not pending and no data yet, request it.
            // If it's still pending. Return the Ajax request itself.
            if (!this.request) {
                this.request = $.ajax({
                    url: "/datasets/" + datasetId + "/defaults",
                    dataType: "json",
                    success: function (data) {
                        this.defaults = data;
                        delete this.request;
                    }.bind(this),
                    error: function (e) {
                        console.log(e);
                        delete this.request;
                    }.bind(this)
                });
            }

            result = this.request;
        }

        return result;
    }
};
