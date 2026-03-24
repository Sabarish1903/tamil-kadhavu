<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Security Check: Redirect to login if session is empty
    String userName = (String) session.getAttribute("userName");
    if (userName == null) {
        userName = "Guest Student"; // Fallback
    }

    String room = request.getParameter("room");
    if (room == null || room.isEmpty()) {
        room = "TamilKadhavu_GeneralClass"; // Default room
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Live Class | தமிழ் கதவு</title>
    <link rel="icon" type="image/x-icon" href="./images/tamil_kadhavu.jpg">
    <style>
        body, html { margin: 0; padding: 0; height: 100%; overflow: hidden; background: #000; }
        #meet { height: 100%; width: 100%; }
    </style>
    <script src="https://meet.jit.si/external_api.js"></script>
</head>
<body>
    <div id="meet"></div>

    <script>
        const domain = "meet.jit.si";
        const options = {
            roomName: "<%= room %>", 
            width: "100%",
            height: "100%",
            parentNode: document.querySelector('#meet'),
            userInfo: {
                // Now uses the actual name from your database session!
                displayName: "<%= userName %>" 
            },
            configOverwrite: {
                startWithAudioMuted: true,
                disableThirdPartyRequests: true
            },
            interfaceConfigOverwrite: {
                TOOLBAR_BUTTONS: [
                    'microphone', 'camera', 'closedcaptions', 'desktop', 
                    'fullscreen', 'fodeviceselection', 'hangup', 'profile', 
                    'chat', 'recording', 'livestreaming', 'etherpad', 
                    'sharedvideo', 'settings', 'raisehand', 'videoquality', 
                    'filmstrip', 'invite', 'feedback', 'stats', 'shortcuts', 
                    'tileview', 'videobackgroundblur', 'download', 'help', 'mute-everyone'
                ]
            }
        };
        const api = new JitsiMeetExternalAPI(domain, options);
    </script>
</body>
</html>
