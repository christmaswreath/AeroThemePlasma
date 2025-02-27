/*
    SPDX-FileCopyrightText: 2013 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2014 Ivan Cukic <ivan.cukic@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.0
import QtQuick.Controls as QQC2

import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.20 as Kirigami
import org.kde.config as KConfig  // KAuthorized
import org.kde.kcmutils  // KCMLauncher


FocusScope {
    id: root
    signal closed()

    function parentClosed() {
        activityBrowser.parentClosed();
    }

    property Item rootItem

    //this is used to perfectly align the filter field and delegates
    property int cellWidth: Kirigami.Units.iconSizes.sizeForLabels * 30
    property int spacing: 2 * Kirigami.Units.smallSpacing

    property bool showSwitcherOnly: false

    width: Kirigami.Units.gridUnit * 18
    implicitWidth: activityBrowser.width
    implicitHeight: activityBrowser.height


    Item {
        id: activityBrowser

        property int spacing: 2 * Kirigami.Units.smallSpacing

        signal closeRequested()

        Keys.onPressed: {
            if (event.key === Qt.Key_Escape) {
                if (heading.searchString.length > 0) {
                    heading.searchString = "";
                } else {
                    activityBrowser.closeRequested();
                }

            } else if (event.key === Qt.Key_Up) {
                activityList.selectPrevious();

            } else if (event.key === Qt.Key_Down) {
                activityList.selectNext();

            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                activityList.openSelected();

            } else if (event.key === Qt.Key_Tab) {
                // console.log("TAB KEY");

            } else  {
                // console.log("OTHER KEY");
                // event.accepted = false;
                // heading.forceActiveFocus();
            }
        }

        // Rectangle {
        //     anchors.fill : parent
        //     opacity      : .4
        //     color        : "white"
        // }

        Heading {
            id: heading

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right

                leftMargin: Kirigami.Units.smallSpacing
                rightMargin: Kirigami.Units.smallSpacing
            }

            visible: !root.showSwitcherOnly

            onCloseRequested: activityBrowser.closeRequested()

        }

        QQC2.ScrollView {
            id: scroll
            clip: true
            anchors {
                top:    heading.visible ? heading.bottom : parent.top
                bottom: bottomPanel.visible ? bottomPanel.top : parent.bottom
                left:   parent.left
                right:  parent.right
                topMargin: activityBrowser.spacing
                leftMargin: 2
                rightMargin: 2
            }

            ActivityList {
                id: activityList
                showSwitcherOnly: root.showSwitcherOnly
                filterString: heading.searchString.toLowerCase()
                itemsWidth: root.width - Kirigami.Units.largeSpacing*3 - Kirigami.Units.mediumSpacing
            }
        }
        Rectangle {
            anchors.fill: scroll
            anchors.margins: -2

            color: "white"
            opacity: 0.3
            border.width: 1
            border.color: "#90000000"
            z: -1
        }

        Item {
            id: bottomPanel

            height: newActivityButton.height + Kirigami.Units.gridUnit

            visible: !root.showSwitcherOnly

            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }

            QQC2.Button {
                id: newActivityButton

                text: i18nd("plasma_shell_org.kde.plasma.desktop", "Create activity…")
                icon.name: "list-add"
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.rightMargin: Kirigami.Units.largeSpacing
                anchors.bottomMargin: Kirigami.Units.largeSpacing
                //width: parent.width

                onClicked: KCMLauncher.openSystemSettings("kcm_activities", "newActivity")

                visible: KConfig.KAuthorized.authorize("plasma-desktop/add_activities")
                opacity: newActivityDialog.status == Loader.Ready ?
                              1 - newActivityDialog.item.opacity : 1
            }

            Loader {
                id: newActivityDialog

                z: 100

                anchors.bottom: newActivityButton.bottom
                anchors.left:   newActivityButton.left
                anchors.right:  newActivityButton.right

            }
        }

        onCloseRequested: root.closed()

        anchors.fill: parent
    }

}

