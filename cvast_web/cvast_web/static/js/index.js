require([
    'jquery',
    'flexslider'
], function($, arches) {
    $(document).ready(function() {
        $('.flexslider').flexslider({
            animation: "slide",
            controlsContainer: '.flexslider'
        });
    });
});