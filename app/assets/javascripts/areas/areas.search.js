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

        var list = $('<ul></ul>').addClass('options');

        // Create an option in the list for each dataset if there were multiple results
        if (data.length >= 1){
            var self = this;

            $.each(data, function(_key, dataset) {
                var option = $('<li>' + dataset.name +' (' + dataset.id +')</li>');
                option.data('id', dataset.id);
                option.on('click', function() {
                    openPopup.call(self, dataset.id);
                });
                option.on('mouseover', function () {
                    $('.options li').removeClass('selected-option');
                    option.addClass('selected-option');
                })
                list.append(option);
            });
            // Highlight first item to show what will open if you press enter
            list.find(">:first-child").addClass('selected-option');
        } else {
            list.append('<li>No results</li>');
            this.scope
                .addClass("no-results")
                .attr('title', "No results for: " + this.result.value)
        }

        this.scope.append(list);
        bindOptionsListener.call(this);
    }

    // Removes options when clicking anywhere in the document
    function bindOptionsListener() {
        var options = this.scope.find('.options');
        $(document).on('mouseup.hideOptionsClick', function(e) {
            if (!options.is(e.target) && options.has(e.target).length === 0){
                options.remove();
                $(document).off('.hideOptionsClick');
            }
        })
    }

    Search.prototype = {
        hide: function () {
            this.scope.hide();
        },

        show: function () {
            this.scope.show();
        },

        search: function (e) {
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
        },

        openSelectedOption: function(e) {
            e.preventDefault();

            var selected = this.scope.find('li.selected-option');

            if (selected.length == 1){
                openPopup.call(this, $(selected[0]).data('id'));
            }
        }
    };

    function Search(areas, scope) {
        this.areas = areas;
        this.scope = scope;
        this.scope.on('submit', this.openSelectedOption.bind(this));
        this.scope.find('#search-bar').on('input', this.search.bind(this));
        this.scope.find('#search-bar').on('click', this.search.bind(this));
        this.scope.find('#search-bar').focus();
    }

    return Search;
}());
