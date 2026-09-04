import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "jbtechnix.disk"

  property string used: "--"
  property string total: "--"
  property string free: "--"
  property string percent: "--"
  property string mount: "/"
  property bool popupOpen: false

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  function refresh() {
    if (!statsProcess.running) statsProcess.running = true
  }

  function parseStats(output) {
    var fields = String(output || "").trim().split(/\s+/)
    if (fields.length < 4) return
    root.used = formatBytes(Number(fields[0]))
    root.total = formatBytes(Number(fields[1]))
    root.free = formatBytes(Number(fields[2]))
    root.percent = fields[3]
  }

  function formatBytes(value) {
    if (!isFinite(value) || value < 0) return "--"
    var units = ["B", "K", "M", "G", "T"]
    var index = 0
    var amount = value
    while (amount >= 1024 && index < units.length - 1) {
      amount /= 1024
      index++
    }
    return (index === 0 ? String(Math.round(amount)) : amount.toFixed(1)) + units[index]
  }

  Process {
    id: statsProcess
    command: ["bash", "-c", "df -B1 --output=used,size,avail,pcent / | awk 'NR==2 {printf \"%d %d %d %s\\n\", $1, $2, $3, $4}'"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.parseStats(text)
    }
  }

  Timer {
    interval: 5000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰋊 " + root.used + "/" + root.total
    labelVisible: true
    tooltipText: "Disk " + root.percent + " used · click for details"
    horizontalMargin: 8
    verticalPadding: 8
  }

  MouseArea {
    anchors.fill: button
    cursorShape: Qt.PointingHandCursor
    onClicked: root.popupOpen = !root.popupOpen
  }

  PopupCard {
    id: popup
    anchorItem: root
    bar: root.bar
    owner: root
    open: root.popupOpen
    contentWidth: popup.fittedContentWidth(Style.space(300))
    contentHeight: popup.fittedContentHeight(column.implicitHeight)

    Column {
      id: column
      anchors.fill: parent
      spacing: Style.space(10)

      Text {
        text: "Root storage"
        color: root.bar.barForeground
        font.family: root.bar.fontFamily
        font.pixelSize: Style.font.heading
        font.bold: true
      }

      Text {
        text: root.used + " / " + root.total + "  (" + root.percent + ")"
        color: Color.accent
        font.family: root.bar.fontFamily
        font.pixelSize: Style.font.displaySmall
      }

      Text {
        text: "Free         " + root.free + "\nMount        " + root.mount
        color: root.bar.barForeground
        font.family: root.bar.fontFamily
        font.pixelSize: Style.font.body
        lineHeight: 1.3
      }
    }
  }
}
