var videoInputDevices;
var publisher;
var screenPublisher;
var previewStream;
var publisherOptions;
var subscriberOptions;
var session;
var currDeviceID = "";
var first_clicked;
var videoOn = true
var audioOn = true
var connectionCount = 0;
var token = ""
var endCall= false;
var subscriberOptions = {
  resolution: '1280x720',
  frameRate: 30,
  height: '100%',
  width: '100%',
  insertMode: 'append',
  showControls: true
};
var endCallTimer;
var syncClockTimer;

$(document).ready(function () {
  function disablePreview() {
    if (previewStream) {
      previewStream.getTracks().forEach(t => t.stop());
    }
    var videoPrev = document.getElementById("video-preview");
    if (videoPrev) {
      videoPrev.pause();
      videoPrev.srcObject = undefined;
    }
  }

  function disableVideo() {
    $("[data-toggle=video]").addClass('active');
    $("[data-toggle=video] .icon-btm-txt").text("enable")

    var tooltip = $("div[data-original-title='Turn off camera']");
    if (tooltip.length > 0) {
      tooltip[0].dataset.originalTitle = "Turn on camera";
    }
    videoOn = false;
    publisher && publisher.publishVideo(videoOn);
    disablePreview();
  }

  function enableVideo() {
    $("[data-toggle=video]").removeClass('active');
    $("[data-toggle=video] .icon-btm-txt").text("disable")

    var tooltip = $("div[data-original-title='Turn on camera']");
    if (tooltip.length > 0) {
      tooltip[0].dataset.originalTitle = "Turn off camera";
    }
    videoOn = true;
    publisher && publisher.publishVideo(videoOn);
    previewVideo("video-preview");
  }

  function disableMic() {
    $("[data-toggle=audio]").addClass('active');
    $("[data-toggle=audio] .icon-btm-txt").text("unmute")
    $(".fa-microphone").addClass('fa-microphone-slash').removeClass('fa-microphone');

    var tooltip = $("div[data-original-title='Turn off microphone']");
    if (tooltip.length > 0) {
      tooltip[0].dataset.originalTitle = "Turn on microphone";
    }
    audioOn = false
    publisher && publisher.publishAudio(audioOn);
  }

  function enableMic() {
    $("[data-toggle=audio]").removeClass('active');
    $("[data-toggle=audio] .icon-btm-txt").text("mute")
    $(".fa-microphone-slash").addClass('fa-microphone').removeClass('fa-microphone-slash');
    var tooltip = $("div[data-original-title='Turn on microphone']");
    if (tooltip.length > 0) {
      tooltip[0].dataset.originalTitle = "Turn off microphone";
    }
    audioOn = true
    publisher && publisher.publishAudio(audioOn);
  }

  function endCall() {
    var time_spent = $('#videochat_clock').text().trim();
    if (time_spent.length) {
      $("#time_spent").val(time_spent);
      if(session.connection != null){
        $("#connection_id").val(session.connection.connectionId);
      }
      $("#time_spent").parent().submit();
    } else {
      window.location.reload();
    }
  }

  function moveThumbnail(e) {
    var thumb = $("#publisher");
    var watermark = $(".watermark");
    var img = $(".watermark img");

    thumb.removeClass("initial-right");
    img.removeClass("fade-in-watermark");
    if (thumb.css("left") === "20px") {
      thumb.removeClass("go-left").removeClass("go-left-portrait");

      var portrait = isPortrait();
      if (portrait) {
        thumb.addClass("go-right-portrait");
      } else {
        thumb.addClass("go-right");
      }

      watermark.css("right", "unset");
      watermark.css("left", "20px");
    } else {
      thumb.removeClass("go-right").removeClass("go-right-portrait");

      var portrait = isPortrait();
      if (portrait) {
        thumb.addClass("go-left-portrait");
      } else {
        thumb.addClass("go-left");
      }

      watermark.css("left", "unset");
      watermark.css("right", "20px");
    }
    img.addClass("fade-in-watermark");
  }

  $(document).on("click", "#publisher", function (e) {
    moveThumbnail();
  });

  function startVideo() {
    $("#start_video").attr('disabled', true);
    $("#start_video").css("opacity", 0.4);
    $("#start_video").text("Starting Call...");

    setTimeout(function () {
      $(document.body).css("background", "#f4f4f4")
      $("nav").remove();
      $(".slicknav_menu").remove();
      $("#precall").hide();
      $("#video").removeClass("hide");
    }, 10);

    setTimeout(function () {
      disablePreview();
      $("#precall").remove();
      startCall();
    }, 100)
  }

  $(document).on('click', '#start_video', function (e) {
    e.preventDefault();
    if (session === undefined) {
      initSession(startVideo);
      return
    }

    startVideo();
  });

  $(document).on('click', '#messageModal .close', function () {
    $("#messageModal").hide();
  });

  function isPortrait() {
    return window.innerHeight > window.innerWidth;
  }

  $(document).on('click', '[data-toggle=video]', function () {
    if ($(this).hasClass("active")) {
      enableVideo();
    } else {
      disableVideo();
    }
  });

  $(document).on('click', '[data-toggle=audio]', function () {
    if ($(this).hasClass("active")) {
      enableMic();
    } else {
      disableMic();
    }
  });

  $(document).on('click', '#end_call', function () {
    let confirmAction = confirm("Are you sure to end chat?");
    if (confirmAction) {
      clearInterval(syncClockTimer);
      endCall();
    };
  });

  $(document).on('click', '#switch_camera', function () {
    switchToCamera();
  });

  $(document).on('click', '#help', function () {
    $('#messageModal .modal-header-text').text("Browser Requirements");
    $('#messageModal .modal-body').html("<ul style='text-align:left'><li>Google Chrome (latest release version)</li> <li>Google Chrome for Android (latest release version)</li> <li>Firefox (latest release version)</li> <li>Firefox for Android (latest release version)</li> <li>Firefox for iOS (latest release version)</li><li>Internet Explorer 11</li> <li>Microsoft Edge 17</li> <li>Safari 11 on macOS</li> <li>Safari on iOS 11</li> <li>Opera (latest release version)</li> </ul>");
    $('#messageModal').show();
  });

  function handleError(error) {
    if (error) {
      if (error.message === "Stream was destroyed before it could be subscribed to") {
        return;
      }
      $('#messageModal .modal-header-text').text("Error");
      $('#messageModal .modal-body').text(error.message);
      $('#messageModal').show();
    }
  }

  function switchToCamera() {
    OT.getDevices(function (error, devices) {
      videoInputDevices = devices.filter(function (element) {
        return element.kind == "videoInput";
      });

      if (videoInputDevices.length > 1) {
        publisher.cycleVideo();
      } else {
        $('#messageModal .modal-header-text').text("Error");
        $('#messageModal .modal-body').text('Cannot switch cameras. You only have one camera');
        $('#messageModal').show();
      }
    });
  }

  function shareScreen() {
    OT.checkScreenSharingCapability(function (response) {
      if (!response.supported || response.extensionRegistered === false) {
        console.log("This browser does not support screen sharing.")
      } else if (response.extensionInstalled === false) {
        conosole.log("Extension is required for this browser")
      } else {
        publisherOptions = {
          resolution: '1280x720',
          frameRate: 30,
          mirror: false,
          insertMode: 'append',
          height: '100%',
          width: '100%',
          fitMode: "contain",
          showControls: true,
          videoSource: "screen",
          audioFallbackEnabled: true,
          publishAudio: audioOn,
          publishVideo: true,
          style: { archiveStatusDisplayMode: 'off', buttonDisplayMode: 'off' }
        };

        screenPublisher = OT.initPublisher('publisher', publisherOptions, function (error) {
          if (error) {
            console.log("error before pub")
            handleError(error)
          }
        });

        setTimeout(function () {
          session.publish(screenPublisher, handleError);
        }, 5000);
      }
    });
  }


  function startCall() {
    publisherOptions = {
      resolution: '1280x720',
      frameRate: 30,
      mirror: false,
      insertMode: 'append',
      height: '100%',
      width: '100%',
      showControls: true,
      audioFallbackEnabled: true,
      fitMode: "contain",
      publishAudio: audioOn,
      publishVideo: videoOn,
      style: { archiveStatusDisplayMode: 'off', buttonDisplayMode: 'off' }
    };

    publisher = OT.initPublisher('publisher', publisherOptions, handleError);
    publisher.on('streamDestroyed', function (event) {
      event.preventDefault();
    });

    session.connect(token, function callback(error) {
      if (error) {
        handleError(error);
      } else {
        session.publish(publisher, handleError);
      }
    });
  }

  function connectionDestroyedHandler(event) {
    connectionCount--;
    if ( (event.reason === "clientDisconnected" || event.reason === "forceDisconnected" ) && event.connection.data !== session.connection.data && connectionCount < 2) {
      clearTimeout(endCallTimer);
      endCall();
    }
  }

  function connctionCreated(event) {
    if (connectionCount > 0) {
      if (event.connection.data === session.connection.data && event.connection.creationTime > session.connection.creationTime) {
        // You logged in on another device
        session.destroy();
        window.location = '/'
        return;
      }
    }

    connectionCount++;
    if (event.connection.data !== session.connection.data) {
      startClock();
    }
  }

  function syncClock() {
    $.ajax(window.location.pathname + "/sync_clock", {
      contentType: 'application/json',
      dataType: 'json',
      success: function (data) {
        var start_time = data.start_time
        if (start_time) {
          var start = new Date(start_time)
          var seconds = Number(((new Date - start) / 1000).toFixed())

          $(".total-booked-time").text(`Total Booked Time is ${data.total_time} minutes`);

          var time = $('#videochat_clock').text();
          $('#videochat_clock').countimer('destroy');
          $("#videochat_clock").text(time);

          $('#videochat_clock').countimer({
            initSeconds: seconds,
            enableEvents: true
          }).on('second', function(evt, time){
            var seconds = time_to_seconds(time);

            if (data.chat_type == "Booking" && !data.free_charge) {
              if ( data.user_type == "Client" && data.booked_time-300 == seconds ) {
                $('.alert-5-min').text('You have approx '+( (data.booked_time - seconds) / 60 ).toFixed(1)+' minutes left. For resume call please add more time before call time completed.');
                $("#extendTimeModal").show();
              }
              if ( data.user_type == "Client" && data.booked_time-120 == seconds ) {
                $('.alert-5-min').text('You have approx '+( (data.booked_time - seconds) / 60 ).toFixed(1)+' minutes left. For resume call please add more time before call time completed.');
                $("#extendTimeModal").show();
              }

              if (data.booked_time-10 == seconds) {
                $('#extend_time').prop('disabled', true);
              }

              if (data.booked_time-5 == seconds) { syncClock(); }

              if(session.connection == null && endCall == false){
                endCall();
                endCall = true;
              }
              if (data.booked_time <= seconds) {
                $('#videochat_clock').countimer('stop');
                $('#monetize_chat_clock').countimer('stop');
                clearInterval(syncClockTimer);
                $("#endCall_type").val("autocut");
                endCall();

                // if (data.user_type == "Client" ) {
                //   endCallTimer = setTimeout(endCall, 20000);
                // }
                return;
              }
            } else if(data.chat_type == "VideoChat" || data.free_charge) {

              if(session.connection == null && endCall == false){
                endCall();
                endCall = true;
              }
              if (data.booked_time <= seconds) {
                $('#videochat_clock').countimer('stop');
                $('#monetize_chat_clock').countimer('stop');
                clearInterval(syncClockTimer);
                $("#endCall_type").val("autocut");
                endCall();

                // if (data.user_type == "Client" ) {
                //   endCallTimer = setTimeout(endCall, 20000);
                // }
                return;
              }
            }
          });
        }
      },
      error: function (data) {
        console.log("Error -> " + data );
      }
    });
  }

  function startClock() {
    $.ajax(window.location.pathname + "/start_clock?connectionId=" + session.connection.connectionId , {
      contentType: 'application/json',
      method: "POST",
      dataType: 'json',
      success: function (data) {
        
        $('#monetize_chat_clock').countimer({
          initSeconds: data.time_used,
          enableEvents: true
        });
        $('#monetize_chat_clock').countimer('start');

        $('#videochat_clock').countimer({
          autoStart: false,
          enableEvents: true
        }).on('second', function(evt, time){
          var seconds = time_to_seconds(time);
          
          if (data.booked_time <= seconds ){
            $('#videochat_clock').countimer('stop');
            endCall();
            return;
          }
        });

        syncClockTimer = setInterval(syncClock, 30000);
        setTimeout(syncClock, 1000);
      },
      error: function (data) {
      }
    });
  }

  function time_to_seconds (time) {
    hms = time.displayedMode.formatted;
    split_time = hms.split(':'); // split it at the colons
    // minutes are worth 60 seconds. Hours are worth 60 minutes.
    seconds = (+split_time[0]) * 60 * 60 + (+split_time[1]) * 60 + (+split_time[2]);
    return seconds;
  }

  function previewVideo(domID) {
    var video = document.getElementById(domID);
    if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
      navigator.mediaDevices.getUserMedia({ audio: true, video: true }).then(function (stream) {
        if (stream) {
          previewStream = stream;
          if (video) {
            video.srcObject = previewStream;
            video.play();
          }
        }
      });
    }
  }

  function initSession(callback) {
    $.ajax(window.location.pathname + "/start", {
      contentType: 'application/json',
      dataType: 'json',
      success: function (data) {
        token = data.token
        session = OT.initSession(data.apiKey, data.sessionId);
        session.on('streamCreated', function streamCreated(event) {
          session.subscribe(event.stream, 'subscriber', subscriberOptions, handleError);
        });

        session.on("sessionDisconnected", function(event) {
          console.log( "Session Disconnected" + event);
        });

        session.on({
          connectionCreated: connctionCreated,
          connectionDestroyed: connectionDestroyedHandler,
        });

        if (callback) {
          callback();
        }
      },
      error: function (data) {
        var err = new Error(data.responseJSON.error);
        if (err.message === "Your Time is not started yet.") {
          $("#start_video").prop("disabled", true)
        } else {
          handleError(err);
        }
      }
    });
  }

  function showEarlyTimer() {
    if ($("#time-until-call").length) {
      var timestring = $("#time-until-call").data("time")
      var time = moment(parseFloat(timestring));
      var i;
      i = setInterval(function () {
        var duration = moment.duration(time.diff(moment()));
        var secondsLeft = duration.as('seconds');

        if (secondsLeft <= 0) {
          clearInterval(i);
          $("#start_video").prop("disabled", false)
          $("#time-until-call").remove()
        } else {
          if (secondsLeft < 60) {
            var second = secondsLeft.toFixed() === "1" ? " second" : " seconds";
            $("#time-until-call").text("Call starts in " + secondsLeft.toFixed() + second);
          } else {
            $("#time-until-call").text("Call starts in " + duration.humanize())
          }
        }
      }, 1000);
    }
  }

  if ($("#publisher").length) {
    $(document).on('keydown', function (e) {
      if (String(e.code) === 'KeyS' && e.shiftKey) {
        shareScreen();
      }
    });

    showEarlyTimer();
    initSession();
    previewVideo("video-preview");
  }

  $(document).on('click', '#extendTimeModal .close', function () {
    $("#extendTimeModal").hide();
  });

  $(document).on('click', '#extend_time', function () {
    $('.alert-5-min').text('Add more time of call.');
    $("#extendTimeModal").show();
  });

  $('#extendTimeForm').on('ajax:success', function(e, data, status, xhr){
    if(data.status !== 200){
      alert(data.message);
    }else{
      $(".total-booked-time").text(`Total Booked Time is ${data.total_time} minutes`);
      $("#extendTimeModal").hide();
      alert("Time added successfully.");
    }
  }).on('ajax:error',function(e, xhr, status, error){
    alert(error)
  });

});
