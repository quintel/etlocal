var Introduction = (function () {
  'use strict';

    Introduction.prototype = {
        open: function () {
            $.ajax({
                type: "GET",
                dataType: 'script',
                url: '/introduction.js'
            });
        }
    }

    function Introduction() {

    }

    return {
        init: function () {
            var introduction = new Introduction();
            $('.header .info').on('click', function(){
                introduction.open();
            });
        }
    }
}());
