var Tab = (function () {
    "use strict";

    function clickToggleTab (e) {
        e.preventDefault();

        var current = $(e.target).attr("href");

        this.localSettings.set("current", current);
        this.toggleTab(current);
    }

    function openSubmenu (e) {
        $("ul.sub-nav" + $(e.target).attr('href')).addClass("active");
    }

    function closeSubmenu (e) {
        $("ul.sub-nav").removeClass("active");
    }

    Tab.prototype = {
        toggleTab: function (current) {
            var currentLink = this.menuItems.filter(function () {
                return $(this).attr("href") === current;
            });

            $("div.tab, ul.sub-nav")
                .add(this.listItems)
                .removeClass("active");

            $("div.tab[data-tab='" + current + "']")
                .add(currentLink.parent())
                .addClass("active");

            this.toggleCallback(current);
        },

        enable: function () {
            var currentDefault = this.menuItems.first().attr("href");

            this.toggleTab(
                this.localSettings.get("current") || currentDefault);

            this.menuItems.on("click", clickToggleTab.bind(this));

            $(this.nav).find("ul.tab-nav li > a")
                .on("mouseover", openSubmenu.bind(this));

            $(this.nav).find("ul.sub-nav")
                .on("mouseleave", closeSubmenu.bind(this));
        }
    };

    function Tab(nav, localSettings, toggleCallback) {
        this.nav            = nav;
        this.listItems      = $(this.nav).find("li");
        this.menuItems      = $(this.nav).find("li a");
        this.localSettings  = localSettings;
        this.toggleCallback = toggleCallback || function () { return; };
    }

    return Tab;
}());
