var Tab = (function () {
    "use strict";

    function clickToggleTab (e) {
        e.preventDefault();

        this.toggleTab(e);
    }

    function deactivateMenuItems() {
        var tabScope = this.tabScope;

        this.menuItems.each(function () {
            tabScope
                .find("div.tab[data-tab='" + $(this).attr('href') + "']")
                .add($(this))
                .removeClass('active');
        });
    }

    Tab.prototype = {
        toggleTab: function (e) {
            var target  = $(e.target),
                current = target.attr("href");

            deactivateMenuItems.call(this);

            this.tabScope.find("div.tab[data-tab='" + current + "']")
                .add(target)
                .addClass("active");

            if (target.parents("ul.sub-nav").length < 1) {
                $(this.nav).find("ul.sub-nav").removeClass("active");
            }

            $(this.nav).find("ul.sub-nav" + current).addClass("active");

            this.toggleCallback(current);
        },

        enable: function () {
            var currentDefault = this.menuItems.first();

            this.toggleTab({ target: currentDefault });
            this.menuItems.on("click", clickToggleTab.bind(this));
        }
    };

    function Tab(nav, toggleCallback) {
        this.nav            = nav;
        this.key            = $(this.nav).data('key');
        this.tabScope       = $("div[data-tab-key='" + this.key + "']");
        this.menuItems      = $(this.nav).find("a");
        this.toggleCallback = toggleCallback || function () { return; };
    }

    return Tab;
}());
