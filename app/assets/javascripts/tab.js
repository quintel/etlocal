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

            $("div.tab").add(this.menuItems)
                .removeClass("active");

            $("div.tab[data-tab='" + current + "']").add(currentLink)
                .addClass("active");

            this.toggleCallback(current);
        },

        enable: function () {
            var currentDefault = this.menuItems.first().attr("href");

            this.toggleTab(
                this.localSettings.get("current") || currentDefault);

            this.menuItems.on("click", clickToggleTab.bind(this));
        }
    };

    function Tab(nav, localSettings, toggleCallback) {
        this.nav            = nav;
        this.menuItems      = $(this.nav).find("li a");
        this.localSettings  = localSettings;
        this.toggleCallback = toggleCallback || function () { return; };
    }

    return Tab;
}());
