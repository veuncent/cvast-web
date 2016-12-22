define([
    'jquery'
], function ($) {
    $(document).ready(function () {

		// Allow users to click on thumbnails to play those videos
		var image_carousel = document.getElementById("image-carousel");
		if (image_carousel != null) {
			links = image_carousel.getElementsByTagName('a');
			for (var i = 0; i < links.length; i++) {
				links[i].onclick = showClickedThumbnailImage;
			}
		}


		function showClickedThumbnailImage(e) {
			e.preventDefault();
			imagetarget = this.getElementsByTagName('img')[0].src;
			imagecaption = this.getAttribute("data-caption");
			imagestyle = this.getAttribute("style");
			image = document.querySelector("#image-carousel img");

			image.setAttribute("style", "");
			image[0].src = imagetarget;
			image.setAttribute("style", imagestyle);
			image.onloadedmetadata = function () {
				// Scroll to center the video on screen
				var el = $(document.getElementById("image-carousel"));
				var elOffset = el.offset().top;
				var elHeight = el.height();
				var windowHeight = $(window).height();
				var offset;

				if (elHeight < windowHeight) {
					offset = elOffset - ((windowHeight / 2) - (elHeight / 2));
				}
				else {
					offset = elOffset;
				}
				var speed = 700;
				$('html, body').animate({ scrollTop: offset }, speed);
			}

			setImageCaption(imagecaption);

			image.load();
		}


		function setImageCaption(imagecaption) {
			caption = $(document.getElementById("cvast-image-caption"));
			caption.html(imagecaption);
		}

	});
});






