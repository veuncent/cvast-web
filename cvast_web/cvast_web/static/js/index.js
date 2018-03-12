require([
    'jquery',
    'flexslider',
    'cvast-main'
], function($, arches) {
    $(document).ready(function() {
        $('.flexslider').flexslider({
            animation: "slide",
            controlsContainer: '.flexslider'
        });
    });
});