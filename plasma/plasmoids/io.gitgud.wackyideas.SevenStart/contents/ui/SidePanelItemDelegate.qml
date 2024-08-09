import QtQuick 2.4
import QtQuick.Controls
import QtQuick.Layouts 1.1
import QtQuick.Dialogs
import QtQuick.Window 2.1

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import org.kde.ksvg as KSvg
import org.kde.kirigami as Kirigami

Item {
    id: sidePanelDelegate
    objectName: "SidePanelItemDelegate"
    property int iconSizeSide: Kirigami.Units.iconSizes.smallMedium
    property string itemText: ""
    property string itemIcon: ""
    property string executableString: ""
    property bool executeProgram: false
    property alias textLabel: label
    //text: itemText

    //icon: itemIcon
    width: label.implicitWidth + Kirigami.Units.largeSpacing*2
    //Layout.preferredWidth: label.implicitWidth
    height: 33

    KeyNavigation.backtab: findPrevious();
    KeyNavigation.tab: findNext();

    function findItem() {
        for(var i = 1; i < parent.visibleChildren.length-1; i++) {
            if(sidePanelDelegate == parent.visibleChildren[i])
                return i;
        }
        return -1;
    }
    function findPrevious() {
        var i = findItem()-1;
        if(i < 1) {
            return root.m_searchField;
        }
        if(parent.visibleChildren[i].objectName == "SidePanelItemSeparator") {
            i--;
        }
        return parent.visibleChildren[i];
    }

    function findNext() {
        var i = findItem()+1;
        if(i >= parent.visibleChildren.length-1) {
            return root.m_shutDownButton;
        }
        if(parent.visibleChildren[i].objectName == "SidePanelItemSeparator") {
            i++;
        }
        return parent.visibleChildren[i];
    }
    Keys.onPressed: event => {
        if(event.key == Qt.Key_Return) {
            sidePanelMouseArea.clicked(null);
        } else if(event.key == Qt.Key_Up) {
            //console.log(findPrevious());
            findPrevious().focus = true;
        } else if(event.key == Qt.Key_Down) {
            //console.log(findNext());
            findNext().focus = true;
        } else if(event.key == Qt.Key_Left) {
            var pos = parent.mapToItem(mainFocusScope, sidePanelDelegate.x, sidePanelDelegate.y);
            var obj = mainFocusScope.childAt(Kirigami.Units.smallSpacing*10, pos.y);
            if(obj.objectName == "") {
                obj = root.m_recents;
            }
            obj.focus = true;
        }
    }
    //For some reason this is the only thing that prevents a width reduction bug, despite it being UB in QML
    /*anchors.left: parent.left;
    anchors.right: parent.right;*/

    KSvg.FrameSvgItem {
        id: itemFrame
        z: -1
        opacity: sidePanelMouseArea.containsMouse || parent.focus

        anchors.fill: parent
        imagePath: Qt.resolvedUrl("svgs/sidebaritem.svg")
        prefix: "menuitem"

    }
    PlasmaComponents.Label {
        id: label
        wrapMode: Text.NoWrap
        //elide: Text.ElideRight
        anchors.left: parent.left
        anchors.leftMargin: Kirigami.Units.smallSpacing * 2
        anchors.verticalCenter: sidePanelDelegate.verticalCenter
        anchors.verticalCenterOffset: -1
        style: Text.Sunken
        styleColor: "transparent"
        text: itemText
    }
    onFocusChanged: {
        /*if(focus) {
            root.m_sidebarIcon.source = itemIcon;
        } else {
            root.m_sidebarIcon.source = "";
        }*/
        if(root.m_delayTimer.running) root.m_delayTimer.restart();
        else root.m_delayTimer.start();
    }
    MouseArea {
        id: sidePanelMouseArea
        enabled: !root.hoverDisabled
        acceptedButtons: Qt.LeftButton
        onEntered: {
            sidePanelDelegate.focus = true;
        }
        onExited: {
            sidePanelDelegate.focus = false;
        }
        onClicked: {
            root.visible = false;
            if(executeProgram)
                executable.exec(executableString);
            else {
                Qt.openUrlExternally(executableString);
            }
        }
        hoverEnabled: true
        anchors.fill: parent
    }
}