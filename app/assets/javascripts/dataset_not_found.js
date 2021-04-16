var DatasetNotFound = (function () {
  'use strict';

  return {
    open: function (geoId) {
      $.ajax({
          type: "GET",
          dataType: 'script',
          url: '/datasets/not_found.js',
          data: {'geo_id': geoId}
      });
    }
  }
}());
