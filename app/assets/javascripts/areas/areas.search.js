/*globals Areas,Search,ol*/

Areas.Search = (function () {
    'use strict';

    function openPopup(geoId) {
        $.ajax({
            url: "/datasets/" + geoId + ".json",
            type: 'GET',
            dataType: 'json',
            success: function (data) {
                if (data) {
                    DatasetInterface.open(data.id);
                } else if (console) {
                    console.log("No dataset with " + geoId + " found");
                }
            }.bind(this),
            error: function (e) {
                alert(e);
            }
        });
    }

    function parseResults(data) {
        this.areas.popup.close();
        this.scope.find('.options').remove();
        this.scope
            .removeClass("no-results")
            .removeAttr("title");

        if (data.length == 1) {
            openPopup.call(this, data[0].id);
        } else if (data.length > 1){
            var list = $('<ul></ul>').addClass('options'),
                self = this;

            // Create an option in the list for each dataset
            $.each(data, function(_key, dataset) {
                var option = $('<li>' + dataset.name +' (' + dataset.id +')</li>');
                option.on('click', function() {
                    openPopup.call(self, dataset.id);
                });
                list.append(option);
            })

            this.scope.append(list);
        } else {
            this.scope
                .addClass("no-results")
                .attr('title', "No results for: " + this.result.value);
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

            // Here we check for a fuzzy match to known dataset codes & names,
            // there can be more than one result
            $.ajax({
                url: "/datasets/search.json",
                type: 'GET',
                dataType: 'json',
                data: { query: this.result.value },
                success: parseResults.bind(this),
                error: function (e) {
                    alert(e);
                }
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
