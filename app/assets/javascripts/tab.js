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
            var target      = $(e.target),
                group       = target.data('group'),
                current     = target.attr("href"),
                isSubItem   = (target.parents("ul.sub-nav").length > 0),
                currentTab  = this.tabScope.find("div.tab[data-tab='" + current + "']");

            deactivateMenuItems.call(this);

            currentTab.add(target).addClass("active");

            this.localSettings.set('current', current);

            if (isSubItem) {
                $(this.nav).find("ul.sub-nav#" + group).addClass("active");
            } else {
                $(this.nav).find("ul.sub-nav").removeClass("active");

                $(this.nav).find("ul.sub-nav" + current).addClass("active");
            }

            this.toggleCallback(current, currentTab);
        },

        enable: function () {
            var current = this.localSettings.get('current'),
                currentDefault = current ?
                    this.nav.find("a[href='" + current + "']") :
                    this.menuItems.first();

            this.toggleTab({ target: currentDefault });
            this.menuItems.on("click", clickToggleTab.bind(this));
        }
    };

    function Tab(nav, toggleCallback, localSettings) {
        this.nav            = nav;
        this.key            = $(this.nav).data('key');
        this.tabScope       = $("div[data-tab-key='" + this.key + "']");
        this.menuItems      = $(this.nav).find("a");
        this.toggleCallback = toggleCallback || function () { return; };
        this.localSettings  = localSettings;
    }

    return Tab;
}());
