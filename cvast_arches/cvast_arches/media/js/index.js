require([
    'jquery',
    'arches',
    'easing',
    'flexslider'
], function($, arches) {
    $(document).ready(function() {
        $('.flexslider').flexslider({
            animation: "slide",
            controlsContainer: '.flexslider'
        });
    });
});