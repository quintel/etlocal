var GraphDefaults = (function () {
    'use strict';

    GraphDefaults.prototype = {
        fetch: function () {
            if (!this.data) {
                // If not pending and no data yet, request it.
                // If it's still pending. Return the Ajax request itself.
                if (!this.request) {
                    this.request = $.ajax({
                        url: "/datasets/" + this.datasetId + "/defaults",
                        dataType: "json",
                        success: function (data) {
                            this.data = data;
                            delete this.request;
                        }.bind(this),
                        error: function (e) {
                            console.log(e);
                            delete this.request;
                        }.bind(this)
                    });
                }
            }

            return this.request;
        }
    };

    function GraphDefaults(datasetId) {
        this.datasetId = datasetId;
        this.request   = null;
        this.data      = false;
    }

    return GraphDefaults;
}());
