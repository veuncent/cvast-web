define([
	'jquery'
], function ($) {
	return {
		loadVideoplayer: function () {

			// Allow users to click on thumbnails to play those videos
			var video_player = document.getElementById("video-player");
			if (video_player != null) {
				links = video_player.getElementsByTagName('a');
				for (var i = 0; i < links.length; i++) {
					links[i].onclick = playClickedThumbnailVideo;
				}
			}


			function playClickedThumbnailVideo(e) {
				e.preventDefault();
				videotarget = this.getAttribute("href");
				videocaption = this.getAttribute("data-caption");
				videostyle = this.getAttribute("style");
				video = document.querySelector("#video-player video");
				video.removeAttribute("controls");
				video.removeAttribute("poster");
				video.setAttribute("style", "");
				source = document.querySelectorAll("#video-player video source");
				source[0].src = videotarget;
				video.setAttribute("controls", "true");
				video.setAttribute("style", videostyle);
				video.onloadedmetadata = function () {
					// Scroll to center the video on screen
					var el = $(document.getElementById("video-player"));
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

				setVideoCaption(videocaption);

				video.load();
				video.play();
			}


			function setVideoCaption(videocaption) {
				caption = $(document.getElementById("cvast-video-caption"));
				caption.html(videocaption);
			}
		}
	};
});






