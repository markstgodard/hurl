/**
 * This is based on sample Chromecast app
 * Please see for more details: https://github.com/googlecast/CastHelloVideo-chrome
 */


/**
 * global variables
 */
var currentMedia = null;
var currentVolume = 0.9;
var progressFlag = 1;
var mediaCurrentTime = 0;
var session = null;
var currentMediaURL = null;

var timer = null;

if (!chrome.cast || !chrome.cast.isAvailable) {
  setTimeout(initializeCastApi, 1000);
}

/**
 * Call initialization
 */
function initializeCastApi() {

  var applicationID = chrome.cast.media.DEFAULT_MEDIA_RECEIVER_APP_ID;
  var sessionRequest = new chrome.cast.SessionRequest(applicationID);
  var apiConfig = new chrome.cast.ApiConfig(sessionRequest,
    sessionListener,
    receiverListener);

  chrome.cast.initialize(apiConfig, onInitSuccess, onError);

};

/**
 * initialization
 */
function onInitSuccess() {
  appendMessage("init success");
}

/**
 * initialization error callback
 */
function onError() {
  console.log("error");
  appendMessage("error");
}

/**
 * generic success callback
 */
function onSuccess(message) {
  console.log(message);
}

/**
 * callback on success for stopping app
 */
function onStopAppSuccess() {
  console.log('Session stopped');
  appendMessage('Session stopped');
  document.getElementById("casticon").src = '/assets/cast_icon_idle.png';
}

/**
 * session listener during initialization
 */
function sessionListener(e) {
  console.log('New session ID: ' + e.sessionId);
  appendMessage('New session ID:' + e.sessionId);
  session = e;
  if (session.media.length != 0) {
    appendMessage(
        'Found ' + session.media.length + ' existing media sessions.');
    onMediaDiscovered('sessionListener', session.media[0]);
  }
  session.addMediaListener(
    onMediaDiscovered.bind(this, 'addMediaListener'));
  session.addUpdateListener(sessionUpdateListener.bind(this));
}

/**
 * session update listener
 */
function sessionUpdateListener(isAlive) {
  var message = isAlive ? 'Session Updated' : 'Session Removed';
  message += ': ' + session.sessionId;
  appendMessage(message);
  if (!isAlive) {
    session = null;
    document.getElementById("casticon").src = '/assets/cast_icon_idle.png';
    var playpauseresume = document.getElementById("playpauseresume");
    playpauseresume.innerHTML = 'Play';
    if( timer ) {
      clearInterval(timer);
    }
    else {
      timer = setInterval(updateCurrentTime.bind(this), 1000);
      playpauseresume.innerHTML = 'Pause';
    }
  }
};

/**
 * receiver listener during initialization
 */
function receiverListener(e) {
  if( e === 'available' ) {
    console.log("receiver found");
    appendMessage("receiver found");
  }
  else {
    console.log("receiver list empty");
    appendMessage("receiver list empty");
  }
}

/**
 * launch app and request session
 */
function launchApp() {
  console.log("launching app...");
  appendMessage("launching app...");
  chrome.cast.requestSession(onRequestSessionSuccess, onLaunchError);
  if( timer ) {
    clearInterval(timer);
  }
}

/**
 * callback on success for requestSession call
 * @param {Object} e A non-null new session.
 */
function onRequestSessionSuccess(e) {
  console.log("session success: " + e.sessionId);
  appendMessage("session success: " + e.sessionId);
  session = e;
  document.getElementById("casticon").src = '/assets/cast_icon_active.png';

  session.addUpdateListener(sessionUpdateListener.bind(this));
  if (session.media.length != 0) {
    onMediaDiscovered('onRequestSession', session.media[0]);
  }
  session.addMediaListener(
    onMediaDiscovered.bind(this, 'addMediaListener'));
  session.addUpdateListener(sessionUpdateListener.bind(this));
}

/**
 * callback on launch error
 */
function onLaunchError() {
  console.log("launch error");
  appendMessage("launch error");
}

/**
 * stop app/session
 */
function stopApp() {
  session.stop(onStopAppSuccess, onError);
  if( timer ) {
    clearInterval(timer);
  }
}

/**
 * load media
 * @param {string} i An index for media
 */
function loadMedia(mediaURL) {
  if (!session) {
    console.log("no session");
    appendMessage("no session");
    return;
  }

  if( mediaURL ) {
    var mediaInfo = new chrome.cast.media.MediaInfo(mediaURL);
  }
  else {
    console.log("loading..." + currentMediaURL);
    appendMessage("loading..." + currentMediaURL);
    var mediaInfo = new chrome.cast.media.MediaInfo(currentMediaURL);
  }
  mediaInfo.contentType = 'video/mp4';
  var request = new chrome.cast.media.LoadRequest(mediaInfo);
  request.autoplay = true;
  request.currentTime = 0;

  session.loadMedia(request,
    onMediaDiscovered.bind(this, 'loadMedia'),
    onMediaError);

}

/**
 * callback on success for loading media
 * @param {Object} e A non-null media object
 */
function onMediaDiscovered(how, media) {
  console.log("new media session ID:" + media.mediaSessionId);
  appendMessage("new media session ID:" + media.mediaSessionId + ' (' + how + ')');
  currentMedia = media;
  currentMedia.addUpdateListener(onMediaStatusUpdate);
  mediaCurrentTime = currentMedia.currentTime;
  playpauseresume.innerHTML = 'Play';
  document.getElementById("casticon").src = '/assets/cast_icon_active.png';
  if( !timer ) {
    timer = setInterval(updateCurrentTime.bind(this), 1000);
    playpauseresume.innerHTML = 'Pause';
  }
}

/**
 * callback on media loading error
 * @param {Object} e A non-null media object
 */
function onMediaError(e) {
  console.log("media error");
  appendMessage("media error");
  document.getElementById("casticon").src = '/assets/cast_icon_warning.png';
}

/**
 * callback for media status event
 * @param {Object} e A non-null media object
 */
function onMediaStatusUpdate(isAlive) {
  if( progressFlag ) {
    document.getElementById("progress").value = parseInt(100 * currentMedia.currentTime / currentMedia.media.duration);
    document.getElementById("progress_tick").innerHTML = currentMedia.currentTime;
    document.getElementById("duration").innerHTML = currentMedia.media.duration;
  }
  document.getElementById("playerstate").innerHTML = currentMedia.playerState;
}

/**
 * Updates the progress bar shown for each media item.
 */
function updateCurrentTime() {
  if (!session || !currentMedia) {
    return;
  }

  if (currentMedia.media && currentMedia.media.duration != null) {
    var cTime = currentMedia.getEstimatedTime();
    document.getElementById("progress").value = parseInt(100 * cTime / currentMedia.media.duration);
    document.getElementById("progress_tick").innerHTML = cTime;
  }
  else {
    document.getElementById("progress").value = 0;
    document.getElementById("progress_tick").innerHTML = 0;
    if( timer ) {
      clearInterval(timer);
    }
  }
};

/**
 * play media
 */
function playMedia() {
  if( !currentMedia )
    return;

  if( timer ) {
    clearInterval(timer);
  }

  var playpauseresume = document.getElementById("playpauseresume");
  if( playpauseresume.innerHTML == 'Play' ) {
    currentMedia.play(null,
      mediaCommandSuccessCallback.bind(this,"playing started for " + currentMedia.sessionId),
      onError);
      playpauseresume.innerHTML = 'Pause';
      appendMessage("play started");
      timer = setInterval(updateCurrentTime.bind(this), 1000);
  }
  else {
    if( playpauseresume.innerHTML == 'Pause' ) {
      currentMedia.pause(null,
        mediaCommandSuccessCallback.bind(this,"paused " + currentMedia.sessionId),
        onError);
      playpauseresume.innerHTML = 'Resume';
      appendMessage("paused");
    }
    else {
      if( playpauseresume.innerHTML == 'Resume' ) {
        currentMedia.play(null,
          mediaCommandSuccessCallback.bind(this,"resumed " + currentMedia.sessionId),
          onError);
        playpauseresume.innerHTML = 'Pause';
        appendMessage("resumed");
        timer = setInterval(updateCurrentTime.bind(this), 1000);
      }
    }
  }
}

/**
 * stop media
 */
function stopMedia() {
  if( !currentMedia )
    return;

  currentMedia.stop(null,
    mediaCommandSuccessCallback.bind(this,"stopped " + currentMedia.sessionId),
    onError);


  $.ajax({
    type: "POST",
    url: "/play/stop"
  });

  // reset the background and decorate
  var divBanner = document.getElementById('mainbanner');
  divBanner.style.backgroundImage = "url('/assets/background.jpg')";
  decorateThumbs();

  var playpauseresume = document.getElementById("playpauseresume");
  playpauseresume.innerHTML = 'Play';


  var v = document.getElementById("nowplayingname");
  v.innerHTML = '';


  appendMessage("media stopped");
  if( timer ) {
    clearInterval(timer);
  }
}

/**
 * set media volume
 * @param {Number} level A number for volume level
 * @param {Boolean} mute A true/false for mute/unmute
 */
function setMediaVolume(level, mute) {
  if( !currentMedia )
    return;

  var volume = new chrome.cast.Volume();
  volume.level = level;
  currentVolume = volume.level;
  volume.muted = mute;
  var request = new chrome.cast.media.VolumeRequest();
  request.volume = volume;
  currentMedia.setVolume(request,
    mediaCommandSuccessCallback.bind(this, 'media set-volume done'),
    onError);
}

/**
 * set receiver volume
 * @param {Number} level A number for volume level
 * @param {Boolean} mute A true/false for mute/unmute
 */
function setReceiverVolume(level, mute) {
  if( !session )
    return;

  if( !mute ) {
    session.setReceiverVolumeLevel(level,
      mediaCommandSuccessCallback.bind(this, 'media set-volume done'),
      onError);
    currentVolume = level;
  }
  else {
    session.setReceiverMuted(true,
      mediaCommandSuccessCallback.bind(this, 'media set-volume done'),
      onError);
  }
}

/**
 * mute media
 * @param {DOM Object} cb A checkbox element
 */
function muteMedia(cb) {
  if( cb.checked == true ) {
    document.getElementById('muteText').innerHTML = 'Unmute';
    //setMediaVolume(currentVolume, true);
    setReceiverVolume(currentVolume, true);
    appendMessage("media muted");
  }
  else {
    document.getElementById('muteText').innerHTML = 'Mute';
    //setMediaVolume(currentVolume, false);
    setReceiverVolume(currentVolume, false);
    appendMessage("media unmuted");
  }
}

/**
 * seek media position
 * @param {Number} pos A number to indicate percent
 */
function seekMedia(pos) {
  console.log('Seeking ' + currentMedia.sessionId + ':' +
    currentMedia.mediaSessionId + ' to ' + pos + "%");
  progressFlag = 0;
  var request = new chrome.cast.media.SeekRequest();
  request.currentTime = pos * currentMedia.media.duration / 100;
  currentMedia.seek(request,
    onSeekSuccess.bind(this, 'media seek done'),
    onError);
}

/**
 * callback on success for media commands
 * @param {string} info A message string
 * @param {Object} e A non-null media object
 */
function onSeekSuccess(info) {
  console.log(info);
  appendMessage(info);
  setTimeout(function(){progressFlag = 1},1500);
}

/**
 * callback on success for media commands
 * @param {string} info A message string
 * @param {Object} e A non-null media object
 */
function mediaCommandSuccessCallback(info) {
  console.log(info);
  appendMessage(info);
}


/**
 * append message to debug message window
 * @param {string} message A message string
 */
function appendMessage(message) {
  var dw = document.getElementById("debugmessage");
  dw.innerHTML += '\n' + JSON.stringify(message);
};


function decorateThumbs() {

  // blur thumbnail backgrounds
  $('.blurred-thumbnail').blurjs({
    draggable: false,
    overlay: 'rgba(255,255,255,0.3)',
    radius:10
  });

  // set the tooltips
  $('.tip').tooltip({'placement':'bottom'});

}

function selectAndPlayMedia(m, art_url, media_id, short_name) {

  console.log("media selected" + m);
  appendMessage("media selected" + m);
  currentMediaURL = m;

  //var playpauseresume = document.getElementById("playpauseresume");


  // this needs to copy the image to overwrite local /assets/images/background.jpg
  $.ajax({
    type: "POST",
    url: "/play/" + media_id
  });


  // reset the background and decorate
  var divBanner = document.getElementById('mainbanner');
  divBanner.style.backgroundImage = "url('/assets/background.jpg')";
  decorateThumbs();

  var np = document.getElementById('nowplayingname');
  np.innerHTML = short_name;



  loadMedia();

}
