import QtQuick 2.4
import Ubuntu.Web 0.2
import Ubuntu.Components 1.3
import com.canonical.Oxide 1.19 as Oxide
import "UCSComponents"
import Ubuntu.Content 1.1
//import "actions" as Actions
import QtMultimedia 5.0
import QtFeedback 5.0
import QtQuick.Window 2.2

import "."
import "../config.js" as Conf

MainView {
    objectName: "mainView"

anchors {
            fill: parent
        }

    applicationName: "ebay.rubrncarneiri"
    anchorToKeyboard: true
    automaticOrientation: true

    property string myUrl: Conf.webappUrl
    property string myPattern: Conf.webappUrlPattern

    property string myUA: Conf.webappUA ? Conf.webappUA : "Mozilla/5.0 (Linux; Android 5.0; Nexus 5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/38.0.2125.102 Mobile Safari/537.36"

    Page {
        id: page
        header: Rectangle {
        color: "#000000"
            width: parent.width
            height: units.dp(0)
            z: 1
            }
        anchors {
            fill: parent
            bottom: parent.bottom
        }


        HapticsEffect {
            id: vibration
            attackIntensity: 0.0
            attackTime: 50
            intensity: 1.0
            duration: 10
            fadeTime: 50
            fadeIntensity: 0.0
        }

        SoundEffect {
            id: clicksound
            source: "../sounds/Click.wav"
        }
        WebContext {
                id: webcontext
                userAgent: myUA
        }

        WebView {

            id: webview
            width: parent.width + units.dp(2)
            anchors {
                horizontalCenter: parent.horizontalCenter
                     top: parent.top
                     bottom: parent.bottom
            }

            context: webcontext
            url: myUrl

            preferences.localStorageEnabled: true
            preferences.allowFileAccessFromFileUrls: true
            preferences.allowUniversalAccessFromFileUrls: true
            preferences.appCacheEnabled: true
            preferences.javascriptCanAccessClipboard: true
            filePicker: filePickerLoader.item

    contextualActions: ActionList {
             Action {
                 text: i18n.tr(webview.contextualData.href.toString())
                 enabled: contextualData.herf.toString()
             }

             Action {
                 text: i18n.tr("Copy Link")
                 enabled: webview.contextualData.href.toString()
                 onTriggered: Clipboard.push([webview.contextualData.href])
             }

             Action {
                 text: i18n.tr("Share Link")
                 enabled: webview.contextualData.href.toString()
                 onTriggered: {
                     var component = Qt.createComponent("Share.qml")
                     console.log("component..."+component.status)
                     if (component.status == Component.Ready) {
                         var share = component.createObject(webview)
                         share.onDone.connect(share.destroy)
                         share.shareLink(webview.contextualData.href.toString(), webview.contextualData.title)
                     } else {
                         console.log(component.errorString())
                     }
                  }
             }

                  Action {
                      text: i18n.tr("Copy Image")
                      enabled: webview.contextualData.img.toString()
                      onTriggered: Clipboard.push([webview.contextualData.img])
                  }

                  Action {
                      text: i18n.tr("Download Image")
                      enabled: webview.contextualData.img.toString() && downloadLoader.status == Loader.Ready
                      onTriggered: downloadLoader.item.downloadPicture(webview.contextualData.img)
                  }
    }

             function navigationRequestedDelegate(request) {
                var url = request.url.toString();

                if (Conf.hapticLinks) {
                    vibration.start()
                }

                if (Conf.audibleLinks) {
                    clicksound.play()
                }

                if(isValid(url) == false) {
                    console.warn("Opening remote: " + url);
                    Qt.openUrlExternally(url)
                    request.action = Oxide.NavigationRequest.ActionReject
                }
            }
            Component.onCompleted: {
                preferences.localStorageEnabled = true
                if (Qt.application.arguments[2] != undefined ) {
                    console.warn("got argument: " + Qt.application.arguments[1])
                    if(isValid(Qt.application.arguments[1]) == true) {
                        url = Qt.application.arguments[1]
                    }
                }
                console.warn("url is: " + url)
            }
            onGeolocationPermissionRequested: { request.accept() }

           Loader {
                id: downloadLoader
                source: "Downloader.qml"
                asynchronous: true
            }

            Loader {
                id: filePickerLoader
                source: "ContentPickerDialog.qml"
                asynchronous: true
            }
            function isValid (url){
                var pattern = myPattern.split(',');
                for (var i=0; i<pattern.length; i++) {
                    var tmpsearch = pattern[i].replace(/\*/g,'(.*)')
                    var search = tmpsearch.replace(/^https\?:\/\//g, '(http|https):\/\/');
                    if (url.match(search)) {
                       return true;
                    }
                }
                return false;
            }
        }

        ThinProgressBar {
            webview: webview
            width: parent.width + units.gu(5)
            z: 2
            anchors {
               horizontalCenter: parent.horizontalCenter
               top: parent.top
            }
        }
         RadialBottomEdge {
            id: nav
            visible: true
            actions: [
                RadialAction {
                    id: reload
                    iconName: "reload"
                    onTriggered: {
                        webview.reload()
                    }
                    text: qsTr("Reload")
                },

                RadialAction {
                    id: forward
                    enabled: webview.canGoForward
                    iconName: "go-next"
                    onTriggered: {
                        webview.goForward()
                    }
                   text: qsTr("Forward")
                 },
                RadialAction {
                    id: home
                    iconName: "home"
                    onTriggered: {
                        webview.url = myUrl
                    }
                    text: qsTr("Home")
                },
                  RadialAction {
                    id: back
                    enabled: webview.canGoBack
                    iconName: "go-previous"
                    onTriggered: {
                        webview.goBack()
                    }
                    text: qsTr("Back")
                }
            ]
        }
    }

 Connections {
    target: Qt.inputMethod
    onVisibleChanged: nav.visible = !nav.visible
  }
    Connections {
        target: webview
        onFullscreenRequested: webview.fullscreen = fullscreen

        onFullscreenChanged: {
                nav.visible = !webview.fullscreen
                if (webview.fullscreen == true) {
                    window.visibility = 5
                                width: parent.width + units.dp(2)
                } else {
                    window.visibility = 4
                                width: parent.width + units.dp(2)
                }
            }
    }
    Connections {
        target: UriHandler
        onOpened: {
            if (uris.length === 0 ) {
                return;
            }
            webview.url = uris[0]
        }
    }
}
