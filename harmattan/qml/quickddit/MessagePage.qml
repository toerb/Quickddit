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

import QtQuick 1.1
import com.nokia.meego 1.0
import Quickddit.Core 1.0

AbstractPage {
    id: messagePage
    title: "Messages - " + sectionModel[messageModel.section]
    busy: messageModel.busy
    onHeaderClicked: messageListView.positionViewAtBeginning();

    /*readonly*/ property variant sectionModel: ["All", "Unread", "Message", "Comment Replies", "Post Replies", "Sent"]

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }
        ToolIcon {
            platformIconId: "toolbar-list"
            onClicked: {
                globalUtils.createSelectionDialog("Section", sectionModel, messageModel.section,
                function(selectedIndex) {
                    messageModel.section = selectedIndex;
                    messageModel.refresh(false);
                })
            }
        }
        ToolIcon {
            platformIconId: "toolbar-refresh"
            onClicked: messageModel.refresh(false);
        }
    }

    ListView {
        id: messageListView
        anchors.fill: parent
        model: messageModel

        // TODO: implements onClicked action and menu for onPressAndHold
        delegate: MessageDelegate {
            onClicked: {
                if (model.isComment)
                    pageStack.push(Qt.resolvedUrl("CommentPage.qml"), {linkPermalink: model.context})
            }
        }

        footer: Item {
            width: ListView.view.width
            height: loadMoreButton.height + 2 * constant.paddingLarge
            visible: ListView.view.count > 0

            Button {
                id: loadMoreButton
                anchors.centerIn: parent
                enabled: !messageModel.busy
                width: parent.width * 0.75
                text: "Load More"
                onClicked: messageModel.refresh(true);
            }
        }

        ViewPlaceholder { enabled: messageListView.count == 0 && !messageModel.busy }
    }

    ScrollDecorator { flickableItem: messageListView }

    MessageModel {
        id: messageModel
        manager: quickdditManager
        onError: infoBanner.alert(errorString);
    }
}