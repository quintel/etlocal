var Header = (function () {
  'use strict';

  function hideOnAnyClick(element) {
    $(document.body).on('click.toggleElement', function() {
      element.hide();
      $(document.body).off('click.toggleElement')
    });
  }

  return {
      init: function () {
          var name = $('.header .current-user .name'),
              logout = $('.header .log-out');

          name.on('click', function(e) {
            e.stopPropagation();

            if (logout.is(":hidden")) {
              hideOnAnyClick(logout);
            }

            logout.toggle();
          });
      }
  }
}());