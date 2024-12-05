/*
    SPDX-FileCopyrightText: 2012-2016 Eike Hein <hein@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts 1.15
import QtQml 2.15

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.core as PlasmaCore
import org.kde.ksvg 1.0 as KSvg
import org.kde.plasma.private.mpris as Mpris
import org.kde.kirigami 2.20 as Kirigami
import org.kde.kitemmodels as KItemModels

import org.kde.plasma.workspace.trianglemousefilter 1.0

import org.kde.taskmanager 0.1 as TaskManager
import org.kde.plasma.private.taskmanager 0.1 as TaskManagerApplet
import org.kde.plasma.workspace.dbus as DBus

import "code/layoutmetrics.js" as LayoutMetrics
import "code/tools.js" as TaskTools

PlasmoidItem {
    id: tasks

    // For making a bottom to top layout since qml flow can't do that.
    // We just hang the task manager upside down to achieve that.
    // This mirrors the tasks as well, so we just rotate them again to fix that (see Task.qml).
    rotation: Plasmoid.configuration.reverseMode && Plasmoid.formFactor === PlasmaCore.Types.Vertical ? 180 : 0

    readonly property bool shouldShrinkToZero: tasksModel.count === 0
    property bool vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
    property bool iconsOnly: !Plasmoid.configuration.showLabels //Plasmoid.pluginName === "org.kde.plasma.icontasks"

    onIconsOnlyChanged: {
        iconGeometryTimer.start();
    }

    property var toolTipOpenedByClick: null
    property var toolTipAreaItem: null
    property var jumpListItem: null
    onJumpListItemChanged: {
        taskList.forceMouseEvent();
    }

    property QtObject jumpListComponent: Qt.createComponent("TasksMenu.qml");
    property QtObject contextMenuComponent: Qt.createComponent("ContextMenu.qml")
    property QtObject pulseAudioComponent: Qt.createComponent("PulseAudio.qml")

    property bool needLayoutRefresh: false;
    property var taskClosedWithMouseMiddleButton: []
    property alias taskList: taskList
    property alias animationManager: animationManager

    property alias taskBackend: backend
    property alias mediaBackend: mpris2Source

    Item {
        id: animationManager
        property var finishAnimation: {}

        function addItem(id) {
            if(typeof finishAnimation === "undefined")
                finishAnimation = {};
            finishAnimation[id] = true;
        }
        function getItem(id) {
            if(typeof finishAnimation[id] === "undefined") return false;
            return finishAnimation[id];
        }
        function removeItem(id) {
            if(typeof finishAnimation[id] === "undefined") return;
            delete finishAnimation[id];
        }
        Component.onCompleted: {
            finishAnimation = {};
        }
    }

    preferredRepresentation: fullRepresentation

    Plasmoid.constraintHints: Plasmoid.CanFillArea

    Plasmoid.onUserConfiguringChanged: {
        if (Plasmoid.userConfiguring && !!tasks.groupDialog) {
            tasks.groupDialog.visible = false;
        }
    }

    Layout.fillWidth: tasks.vertical ? true : Plasmoid.configuration.fill
    Layout.fillHeight: !tasks.vertical ? true : Plasmoid.configuration.fill
    Layout.minimumWidth: {
        if (shouldShrinkToZero) {
            return Kirigami.Units.iconSizes.small; // For edit mode
        }
        return tasks.vertical ? 0 : LayoutMetrics.preferredMinWidth();
    }
    Layout.minimumHeight: {
        if (shouldShrinkToZero) {
            return Kirigami.Units.iconSizes.small; // For edit mode
        }
        return !tasks.vertical ? 0 : LayoutMetrics.preferredMinHeight();
    }

/*//BEGIN TODO: this is not precise enough: launchers are smaller than full tasks
    Layout.preferredWidth: {
        if (shouldShrinkToZero) {
            return 0.01;
        }
        if (tasks.vertical) {
            return Kirigami.Units.iconSizes.small * 10;
        }
        return taskList.Layout.maximumWidth
    }
    Layout.preferredHeight: {
        if (shouldShrinkToZero) {
            return 0.01;
        }
        if (tasks.vertical) {
            return taskList.Layout.maximumHeight
        }
        return Kirigami.Units.iconSizes.small * 2;
    }
//END TODO*/

    function setRequestedInhibitDnd(value) {
        // This is modifying the value in the panel containment that
        // inhibits accepting drag and drop, so that we don't accidentally
        // drop the task on this panel.
        let item = this;
        while (item.parent) {
            item = item.parent;
            if (item.appletRequestsInhibitDnD !== undefined) {
                item.appletRequestsInhibitDnD = value
            }
        }
    }
    property Item dragSource: null
    property Item dragItem: null

    signal requestLayout
    signal windowsHovered(variant winIds, bool hovered)
    signal activateWindowView(variant winIds)

    Timer {
        id: syncDelay
        interval: 100
        onTriggered: { tasksModel.syncLaunchers(); }
    }
    onDragItemChanged: {
        if (dragItem == null) {
            syncDelay.start();
            tasks.publishIconGeometries(null, tasks);
        }
    }

    function publishIconGeometries(taskItems) {
        if (TaskTools.taskManagerInstanceCount >= 2) {
            return;
        }
        for(var i = 0; i < tasksModel.count; ++i) {
            var task = taskList.itemAtIndex(i);
            if (!task.model.IsLauncher && !task.model.IsStartup) {
                tasks.tasksModel.requestPublishDelegateGeometry(tasks.tasksModel.makeModelIndex(task.index),
                    backend.globalRect(task), task);
            }

        }
    }

    function taskInLauncherList(launcher) {
        for(var i = 0; i < tasksModel.launcherList.length; i++) {
            if(tasksModel.launcherList[i].includes(launcher)) {
                return true;
            }
        }
        return false;
    }
    // Hack that prevents tasks overlapping each other sometimes. Programs that mess around with the system tray like VLC tend to cause this
    Timer {
        id: layoutDelay
        interval: 1000
        onTriggered: {
            taskList.width += 1;
            taskList.width -= 1;
        }
    }

    property TaskManager.TasksModel tasksModel: TaskManager.TasksModel {
        id: tasksModel

        readonly property int logicalLauncherCount: {
            if (Plasmoid.configuration.separateLaunchers) {
                return launcherCount;
            }

            var startupsWithLaunchers = 0;

            for(var i = 0; i < tasksModel.count; ++i) {
                var item = taskList.itemAtIndex(i);

                if (item?.model?.IsStartup && item.model.HasLauncher) {
                    ++startupsWithLaunchers;
                }
            }
            return launcherCount + startupsWithLaunchers;
        }

        virtualDesktop: virtualDesktopInfo.currentDesktop
        screenGeometry: Plasmoid.containment.screenGeometry
        activity: activityInfo.currentActivity

        filterByVirtualDesktop: Plasmoid.configuration.showOnlyCurrentDesktop
        filterByScreen: Plasmoid.configuration.showOnlyCurrentScreen
        filterByActivity: Plasmoid.configuration.showOnlyCurrentActivity
        filterNotMinimized: Plasmoid.configuration.showOnlyMinimized

        hideActivatedLaunchers: true //tasks.iconsOnly || Plasmoid.configuration.hideLauncherOnStart
        sortMode: sortModeEnumValue(Plasmoid.configuration.sortingStrategy)
        launchInPlace: tasks.iconsOnly && Plasmoid.configuration.sortingStrategy === 1
        separateLaunchers: false
        groupMode: Plasmoid.configuration.groupPopups ? TaskManager.TasksModel.GroupApplications : TaskManager.TasksModel.GroupDisabled
        groupInline: !Plasmoid.configuration.groupPopups && !tasks.iconsOnly
        groupingWindowTasksThreshold: (Plasmoid.configuration.onlyGroupWhenFull && !tasks.iconsOnly
            ? LayoutMetrics.optimumCapacity(width, height) + 1 : -1)

        onLauncherListChanged: {
            Plasmoid.configuration.launchers = launcherList;
        }

        onGroupingAppIdBlacklistChanged: {
            Plasmoid.configuration.groupingAppIdBlacklist = groupingAppIdBlacklist;
        }

        onGroupingLauncherUrlBlacklistChanged: {
            Plasmoid.configuration.groupingLauncherUrlBlacklist = groupingLauncherUrlBlacklist;
        }

        function sortModeEnumValue(index) {
            switch (index) {
                case 0:
                    return TaskManager.TasksModel.SortDisabled;
                case 1:
                    return TaskManager.TasksModel.SortManual;
                case 2:
                    return TaskManager.TasksModel.SortAlpha;
                case 3:
                    return TaskManager.TasksModel.SortVirtualDesktop;
                case 4:
                    return TaskManager.TasksModel.SortActivity;
                default:
                    return TaskManager.TasksModel.SortDisabled;
            }
        }

        function groupModeEnumValue(index) {
            switch (index) {
                case 0:
                    return TaskManager.TasksModel.GroupDisabled;
                case 1:
                    return TaskManager.TasksModel.GroupApplications;
            }
        }

        Component.onCompleted: {
            launcherList = Plasmoid.configuration.launchers;
            groupingAppIdBlacklist = Plasmoid.configuration.groupingAppIdBlacklist;
            groupingLauncherUrlBlacklist = Plasmoid.configuration.groupingLauncherUrlBlacklist;

            // Only hook up view only after the above churn is done.
            //taskRepeater.model = tasksModel;
            //taskList.model = tasksModel;
        }
    }

    property TaskManagerApplet.Backend backend: TaskManagerApplet.Backend {
        id: backend
        highlightWindows: Plasmoid.configuration.highlightWindows

        onAddLauncher: {
            tasks.addLauncher(url);
        }
    }

    DBus.DBusServiceWatcher {
        id: effectWatcher
        busType: DBus.BusType.Session
        watchedService: "org.kde.KWin.Effect.WindowView1"
    }

    property Component taskInitComponent: Component {
        Timer {
            id: timer

            interval: Kirigami.Units.longDuration
            running: true

            onTriggered: {
                tasksModel.requestPublishDelegateGeometry(parent.modelIndex(), backend.globalRect(parent), parent);
                timer.destroy();
            }
        }
    }

    Connections {
        target: Plasmoid

        function onLocationChanged() {
            if (TaskTools.taskManagerInstanceCount >= 2) {
                return;
            }
            // This is on a timer because the panel may not have
            // settled into position yet when the location prop-
            // erty updates.
            iconGeometryTimer.start();
        }
    }

    Connections {
        target: Plasmoid.containment

        function onScreenGeometryChanged() {
            iconGeometryTimer.start();
        }
    }

    Mpris.Mpris2Model {
        id: mpris2Source
    }

    Item {
        anchors.fill: parent

        TaskManager.VirtualDesktopInfo {
            id: virtualDesktopInfo
        }

        TaskManager.ActivityInfo {
            id: activityInfo
            readonly property string nullUuid: "00000000-0000-0000-0000-000000000000"
        }

        Loader {
            id: pulseAudio
            sourceComponent: pulseAudioComponent
            active: pulseAudioComponent.status === Component.Ready
        }

        Timer {
            id: iconGeometryTimer

            interval: 500
            repeat: false

            onTriggered: {
                tasks.publishIconGeometries(taskList.visibleChildren, tasks);
            }
        }

        Binding {
            target: Plasmoid
            property: "status"
            value: (tasksModel.anyTaskDemandsAttention && Plasmoid.configuration.unhideOnAttention
                ? PlasmaCore.Types.NeedsAttentionStatus : PlasmaCore.Types.PassiveStatus)
            restoreMode: Binding.RestoreBinding
        }

        Connections {
            target: Plasmoid.configuration

            function onLaunchersChanged() {
                tasksModel.launcherList = Plasmoid.configuration.launchers
            }
            function onGroupingAppIdBlacklistChanged() {
                tasksModel.groupingAppIdBlacklist = Plasmoid.configuration.groupingAppIdBlacklist;
            }
            function onGroupingLauncherUrlBlacklistChanged() {
                tasksModel.groupingLauncherUrlBlacklist = Plasmoid.configuration.groupingLauncherUrlBlacklist;
            }
        }

        Component {
            id: busyIndicator
            PlasmaComponents3.BusyIndicator { visible: false}
        }

        // Save drag data
        Item {
            id: dragHelper

            Drag.dragType: Drag.Automatic
            Drag.supportedActions: Qt.CopyAction | Qt.MoveAction | Qt.LinkAction
            Drag.onDragFinished: tasks.dragSource = null;
        }

        KSvg.FrameSvgItem {
            id: taskFrame

            visible: false;

            imagePath: "widgets/tasks";
            prefix: TaskTools.taskPrefix("normal", Plasmoid.location)
        }

        MouseHandler {
            id: mouseHandler

            anchors.fill: parent
            target: taskList
            onUrlsDropped: (urls) => {
                // If all dropped URLs point to application desktop files, we'll add a launcher for each of them.
                var createLaunchers = urls.every(function (item) {
                    return backend.isApplication(item)
                });

                if (createLaunchers) {
                    urls.forEach(function (item) {
                        addLauncher(item);
                    });
                    return;
                }

                if (!hoveredItem) {
                    return;
                }

                // Otherwise we'll just start a new instance of the application with the URLs as argument,
                // as you probably don't expect some of your files to open in the app and others to spawn launchers.
                tasksModel.requestOpenUrls(hoveredItem.modelIndex(), urls);
            }
        }

        ToolTipDelegate {
            id: openWindowToolTipDelegate
            visible: false
        }

        ToolTipDelegate {
            id: pinnedAppToolTipDelegate
            visible: false
        }

        TriangleMouseFilter {
            id: tmf
            filterTimeOut: 300
            active: tasks.toolTipAreaItem && tasks.toolTipAreaItem.toolTipOpen
            blockFirstEnter: false

            edge: {
                switch (Plasmoid.location) {
                    case PlasmaCore.Types.BottomEdge:
                        return Qt.TopEdge;
                    case PlasmaCore.Types.TopEdge:
                        return Qt.BottomEdge;
                    case PlasmaCore.Types.LeftEdge:
                        return Qt.RightEdge;
                    case PlasmaCore.Types.RightEdge:
                        return Qt.LeftEdge;
                    default:
                        return Qt.TopEdge;
                }
            }

            secondaryPoint: {
                if (tasks.toolTipAreaItem === null) {
                    return Qt.point(0, 0);
                }
                const x = tasks.toolTipAreaItem.x;
                const y = tasks.toolTipAreaItem.y;
                const height = tasks.toolTipAreaItem.height;
                const width = tasks.toolTipAreaItem.width;
                return Qt.point(x+width/2, height);
            }

            anchors {
                left: parent.left
                top: parent.top
            }

            height: taskList.childrenRect.height
            width: taskList.childrenRect.width

            TaskList {
                id: taskList

                Rectangle {
                    id: testRe
                    color: "red"
                    opacity: 0
                    anchors.fill: parent
                    z: -1
                }
                anchors {
                    left: parent.left
                    leftMargin: 1
                    top: parent.top
                }
                width: tasks.width
                height: tasks.height
                orientation: {
                    if(tasks.vertical) {
                        return ListView.Vertical
                    }
                    return ListView.Horizontal
                }

                // Is this really needed?
                // It apparently is, this somehow resets MouseArea and makes stuff actually work
                function forceMouseEvent() {
                    for(var child in taskList.contentItem.children) {
                        var t = taskList.contentItem.children[child];
                        if(typeof t !== "undefined") {
                            if(t.isLauncher) {
                                t.visible = false;
                                t.visible = true;
                            }
                        }
                    }
                }
                onAnimatingChanged: {
                    if (!animating) {
                        tasks.publishIconGeometries(visibleChildren, tasks);
                    }
                }
                delegate: Task {
                    tasksRoot: tasks
                }
                model: tasksModel
                /*model: KItemModels.KSortFilterProxyModel {
                    sourceModel: tasksModel

                    filterRowCallback: function(source_row, source_parent) {
                        const IsStartup = sourceModel.KItemModels.KRoleNames.role("IsStartup");
                        const IsLauncher = sourceModel.KItemModels.KRoleNames.role("AppId");
                        const launcher = sourceModel.data(sourceModel.index(source_row, 0, source_parent), IsLauncher);
                        const startup = sourceModel.data(sourceModel.index(source_row, 0, source_parent), IsStartup);
                        var inLauncherList = false;
                        for(var i = 0; i < tasksModel.launcherList.length; i++) {
                            if(sourceModel.launcherList[i].includes(launcher)) {
                                inLauncherList = true;
                                break;
                            }
                        }
                        return !(startup && !inLauncherList); // Removes startups that do not belong to launchers
                    }

                }*/
            }
        }
    }

    readonly property Component groupDialogComponent: Qt.createComponent("GroupDialog.qml")
    property GroupDialog groupDialog: null

    readonly property bool supportsLaunchers: true

    function hasLauncher(url) {
        return tasksModel.launcherPosition(url) != -1;
    }

    function addLauncher(url) {
        if (Plasmoid.immutability !== PlasmaCore.Types.SystemImmutable) {
            tasksModel.requestAddLauncher(url);
        }
    }

    function removeLauncher(url) {
        if (Plasmoid.immutability !== PlasmaCore.Types.SystemImmutable) {
            tasksModel.requestRemoveLauncher(url);
        }
    }

    // This is called by plasmashell in response to a Meta+number shortcut.
    function activateTaskAtIndex(index) {
        if (typeof index !== "number") {
            return;
        }

        var task = taskRepeater.itemAt(index);
        if (task) {
            TaskTools.activateTask(task.modelIndex(), task.model, null, task, Plasmoid, tasks, effectWatcher.registered);
        }
    }

    function createJumpList(rootTask, modelIndex, args = {}) {
        const initialArgs = Object.assign(args, {
            visualParent: rootTask,
            modelIndex: modelIndex,
            mpris2Source: mpris2Source,
            backend: backend,
            taskWidth: rootTask.width,
            taskHeight: rootTask.height,
            taskX: rootTask.x,
            taskY: rootTask.y
        });
        return jumpListComponent.createObject(rootTask, initialArgs);
    }

    function createContextMenu(rootTask, modelIndex, args = {}) {
        const initialArgs = Object.assign(args, {
            visualParent: rootTask,
            modelIndex,
            mpris2Source,
            backend,
        });
        return contextMenuComponent.createObject(rootTask, initialArgs);
    }

    Component.onCompleted: {
        TaskTools.taskManagerInstanceCount += 1;
        tasks.requestLayout.connect(iconGeometryTimer.restart);
        tasks.windowsHovered.connect(backend.windowsHovered);
        tasks.activateWindowView.connect(backend.activateWindowView);
    }

    Component.onDestruction: {
        TaskTools.taskManagerInstanceCount -= 1;
    }
}
