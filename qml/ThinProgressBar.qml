/*
 * Copyright 2014 Canonical Ltd.
 *
 * This file is part of webbrowser-app.
 *
 * webbrowser-app is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * webbrowser-app is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.4
import Ubuntu.Components 1.3

    ProgressBar {
    property var webview
 id: progressbar

 property int minimum: 0
 property int maximum: 100
 property int value: webview.loadProgress
 property color color: "#19B6ED"
     showProgressPercentage: false
  visible: webview ? webview.loading
                       // Workaround for https://bugs.launchpad.net/oxide/+bug/1290821.
                       // Note: this also works with a QtWebKit webview by chance,
                       // because !undefined evaluates to true.
                       && !webview.lastLoadStopped
                     : false
 height: units.dp(2.5)
 clip: true
 
 Rectangle {
 id: border
 anchors.fill: parent

 color: "#CDCDCD"
 border.width: 0
 border.color: parent.color
 }

 Rectangle {
 id: highlight
 property int widthDest: ( ( progressbar.width * ( value- minimum ) ) / ( maximum - minimum ) - 4 )
 width: highlight.widthDest

anchors {
 left: parent.left
 top: parent.top
 bottom: parent.bottom
 margins: 0
 }
 color: parent.color
 }
}