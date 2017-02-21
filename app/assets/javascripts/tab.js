var Tab = (function () {
    "use strict";

    function clickToggleTab (e) {
        e.preventDefault();

        var current = $(e.target).attr("href");

        this.localSettings.set("current", current);
        this.toggleTab(current);
    }

    Tab.prototype = {
        toggleTab: function (current) {
            var currentLink = this.menuItems.filter(function () {
                return $(this).attr("href") === current;
            });

            $(".tab").add(this.menuItems)
                .removeClass("active");

            $(".tab[data-tab='" + current + "'").add(currentLink)
                .addClass("active");
        },

        enable: function () {
            this.toggleTab(this.localSettings.get("current"));

            this.menuItems.on("click", clickToggleTab.bind(this));
        }
    };

    function Tab(nav, localSettings) {
        this.nav           = nav;
        this.menuItems     = $(this.nav).find("li a");
        this.localSettings = localSettings;
    }

    return Tab;
}());
