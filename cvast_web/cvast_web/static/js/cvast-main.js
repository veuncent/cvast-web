require([
    'jquery',
    'cvast-video',
], function($, cvast_video) {

    $(document).ready(function() {
        cvast_video.loadVideoplayer();

        // Make all external links open in new browser window
        $('a[href^="http://"]').attr('target', '_blank');
        $('a[href^="https://"]').attr('target', '_blank');
    });

});