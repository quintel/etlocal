var GraphDefaults = {
    fetch: function (geoId) {
        if (this.defaults) {
            // When it's done loading, don't return a promise.
            // Just return nothing.
            return null;
        } else {
            // If not pending and no data yet, request it.
            // If it's still pending. Return the Ajax request itself.
            if (!this.request) {
                this.request = $.ajax({
                    url: "/datasets/" + geoId + "/defaults",
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

            return this.request;
        }
    }
};
