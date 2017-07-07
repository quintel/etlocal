/*globals Areas,Search,ol*/

Areas.Search = (function () {
    'use strict';

    function flyToMap(data) {
        this.areas.popup.close();

        if (data.length > 0) {
            var boundingBox = data[0].boundingbox.map(function (value) {
                    return parseFloat(value);
                }),
                c1 = ol.proj.fromLonLat([boundingBox[2], boundingBox[0]]),
                c2 = ol.proj.fromLonLat([boundingBox[3], boundingBox[1]]);

            this.areas.view.fit(c1.concat(c2), { duration: 500 });
        } else {
            console.log("No results for: " + this.results.value);
        }
    }

    Search.prototype = {
        hide: function () {
            this.scope.hide();
        },

        show: function () {
            this.scope.show();
        },

        handleSubmit: function (e) {
            e.preventDefault();

            this.result = $(e.target).serializeArray()[0];

            $.ajax({
                url:  "https://nominatim.openstreetmap.org/search",
                type: "GET",
                data: {
                    format: 'json',
                    q: this.result.value,
                    countrycodes: 'nl'
                },
                success: flyToMap.bind(this)
            });
        }
    };

    function Search(areas, scope) {
        this.areas = areas;
        this.scope = scope;
        this.scope.on('submit', this.handleSubmit.bind(this));
    }

    return Search;
}());
