require([
    'jquery',
    'cvast-video',
], function($, cvast_video) {

    $(document).ready(function() {
        cvast_video.loadVideoplayer();
    });

});