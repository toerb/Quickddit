/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2014  Dickson Leong

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see [http://www.gnu.org/licenses/].
*/

import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: commentDelegate

    property alias menu: mainItem.menu
    signal clicked

    function showMenu(properties) {
        return mainItem.showMenu(properties);
    }

    function highlight() {
        highlightAnimation.start();
    }

    function remorseAction(title, action, timeout) {
        mainItem.remorseAction(title, action, timeout);
    }

    width: ListView.view.width
    height: moreChildrenLoader.status == Loader.Null ? mainItem.height : moreChildrenLoader.height + constant.paddingMedium

    Row {
        id: lineRow
        anchors { left: parent.left; top: parent.top; bottom: parent.bottom }

        Repeater {
            model: depth

            Item {
                anchors { top: parent.top; bottom: parent.bottom }
                width: constant.commentRepliesIndentWidth

                Rectangle {
                    anchors { top: parent.top; bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
                    width: 2
                    color: {
                        switch (index) {
                        case 0: case 1: case 2: case 3: case 4:
                        case 5: case 6: case 7: case 8:
                            return constant.commentRepliesColor[index];
                        default: return constant.commentRepliesColor[9];
                        }
                    }
                }
            }
        }
    }

    ListItem {
        id: mainItem
        anchors { left: lineRow.right; right: parent.right }
        contentHeight: mainColumn.height + 2 * constant.paddingMedium
        showMenuOnPressAndHold: false
        enabled: model.isValid
        visible: moreChildrenLoader.status == Loader.Null

        Rectangle {
            id: highlightRect
            anchors.fill: parent
            color: "transparent"

            SequentialAnimation {
                id: highlightAnimation

                ColorAnimation {
                    target: highlightRect; property: "color"
                    to: Theme.highlightColor; duration: 300
                    easing.type: Easing.OutQuart
                }
                ColorAnimation {
                    target: highlightRect; property: "color"
                    to: "transparent"; duration: 300
                    easing.type: Easing.InQuint
                }
            }
        }

        Column {
            id: mainColumn
            anchors {
                left: parent.left; right: parent.right; margins: constant.paddingMedium
                verticalCenter: parent.verticalCenter
            }
            height: authorTextWrapper.height + commentBodyText.paintedHeight
            spacing: constant.paddingSmall

            Item {
                id: authorTextWrapper
                anchors { left: parent.left; right: parent.right }
                height: scoreLoader.height

                Text {
                    id: commentAuthorText
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                    font.pixelSize: constant.fontSizeDefault
                    color: mainItem.enabled ? (mainItem.highlighted ? Theme.highlightColor : constant.colorLight)
                                            : constant.colorDisabled
                    font.bold: true
                    text: model.author
                }

                Loader {
                    id: scoreLoader
                    anchors { left: commentAuthorText.right; leftMargin: constant.paddingSmall }
                    sourceComponent: model.isScoreHidden ? scoreHiddenComponent : scoreValueComponent

                    Component {
                        id: scoreValueComponent

                        Text {
                            font.pixelSize: constant.fontSizeDefault
                            color: {
                                if (!mainItem.enabled)
                                    return constant.colorDisabled;
                                if (model.likes > 0)
                                    return constant.colorLikes;
                                else if (model.likes < 0)
                                    return constant.colorDislikes;
                                else
                                    return mainItem.highlighted ? Theme.secondaryHighlightColor : constant.colorMid;
                            }
                            text: model.score + " pts"
                        }
                    }

                    Component {
                        id: scoreHiddenComponent
                        Text {
                            font.pixelSize: constant.fontSizeDefault
                            color: mainItem.enabled ? (mainItem.highlighted ? Theme.secondaryHighlightColor : constant.colorMid)
                                                    : constant.colorDisabled
                            text: "[score hidden]"
                        }
                    }
                }

                Text {
                    anchors {
                        left: scoreLoader.right
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        margins: constant.paddingSmall
                    }
                    font.pixelSize: constant.fontSizeDefault
                    color: mainItem.enabled ? (mainItem.highlighted ? Theme.secondaryHighlightColor : constant.colorMid)
                                            : constant.colorDisabled
                    elide: Text.ElideRight
                    text: " · " + model.created
                }
            }

            Text {
                id: commentBodyText
                anchors { left: parent.left; right: parent.right }
                font.pixelSize: constant.fontSizeDefault
                color: mainItem.enabled ? (mainItem.highlighted ? Theme.highlightColor : constant.colorLight)
                                        : constant.colorDisabled
                wrapMode: Text.Wrap
                textFormat: Text.RichText
                text: "<style>a:link { color: " + Theme.highlightColor + "; }</style>" + model.body
                onLinkActivated: globalUtils.openInTextLink(link);
            }
        }

        onClicked: commentDelegate.clicked();
    }

    Loader {
        id: moreChildrenLoader
        anchors { left: lineRow.right; right: parent.right; top: parent.top; margins: constant.paddingMedium }
        sourceComponent: model.isMoreChildren ? moreChildrenComponent : undefined

        Component {
            id: moreChildrenComponent

            Column {
                height: childrenRect.height

                Label {
                    anchors { left: loadMoreButton.left; right: loadMoreButton.right }
                    color: constant.colorMid
                    font.pixelSize: constant.fontSizeMedium
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                    visible: model.moreChildrenCount > 0
                    text: qsTr("%n replies hidden", "", model.moreChildrenCount)
                }

                Button {
                    id: loadMoreButton
                    text: model.moreChildrenCount > 0 ? qsTr("Load more comments") : qsTr("Continue this thread");
                    onClicked: {
                        if (model.moreChildrenCount > 0) {
                            infoBanner.alert("Not implemented yet"); // TODO
                        } else {
                            var link = QMLUtils.toAbsoluteUrl(linkPermalink + model.fullname.substring(3));
                            globalUtils.openInTextLink(link);
                        }
                    }
                }
            }
        }
    }

    ListView.onRemove: mainItem.animateRemoval(commentDelegate);
}
