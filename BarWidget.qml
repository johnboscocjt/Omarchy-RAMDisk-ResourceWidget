import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "io.github.johnboscocjt.ramdisk"

  property string ramUsed: "--"
  property string ramTotal: "--"
  property string ramAvailable: "--"
  property string ramPercent: "--"
  property string swapUsed: "--"
  property string swapTotal: "--"
  property string diskUsed: "--"
  property string diskTotal: "--"
  property string diskFree: "--"
  property string diskPercent: "--"
  property bool popupOpen: false

  implicitWidth: row.implicitWidth + Style.space(12)
  implicitHeight: barSize

  function refresh() {
    if (!statsProcess.running) statsProcess.running = true
  }

  function parseStats(output) {
    var fields = String(output || "").trim().split(/\s+/)
    if (fields.length < 10) return
    root.ramUsed = formatBytes(Number(fields[0]))
    root.ramTotal = formatBytes(Number(fields[1]))
    root.ramAvailable = formatBytes(Number(fields[2]))
    root.ramPercent = fields[3]
    root.swapUsed = formatBytes(Number(fields[4]))
    root.swapTotal = formatBytes(Number(fields[5]))
    root.diskUsed = formatBytes(Number(fields[6]))
    root.diskTotal = formatBytes(Number(fields[7]))
    root.diskFree = formatBytes(Number(fields[8]))
    root.diskPercent = fields[9]
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
    command: ["bash", "-c", "awk '/^MemTotal:/ {total=$2*1024} /^MemAvailable:/ {available=$2*1024} /^SwapTotal:/ {swapTotal=$2*1024} /^SwapFree:/ {swapFree=$2*1024} END {used=total-available; swapUsed=swapTotal-swapFree; printf \"%d %d %d %.0f%% %d %d \" , used, total, available, used*100/total, swapUsed, swapTotal}' /proc/meminfo; df -B1 --output=used,size,avail,pcent / | awk 'NR==2 {printf \"%d %d %d %s\\n\", $1, $2, $3, $4}'"]
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

  Row {
    id: row
    anchors.centerIn: parent
    spacing: Style.space(8)

    WidgetButton {
      id: ramButton
      bar: root.bar
      text: "󰍛 " + root.ramUsed + "/" + root.ramTotal
      labelVisible: true
      tooltipText: "RAM " + root.ramPercent + " used · click for details"
      horizontalMargin: 4
      verticalPadding: 6
      onPressed: function(button) {
        if (button === Qt.LeftButton) root.popupOpen = !root.popupOpen
      }
    }

    WidgetButton {
      id: diskButton
      bar: root.bar
      text: "󰋊 " + root.diskUsed + "/" + root.diskTotal
      labelVisible: true
      tooltipText: "Disk " + root.diskPercent + " used · click for details"
      horizontalMargin: 4
      verticalPadding: 6
      onPressed: function(button) {
        if (button === Qt.LeftButton) root.popupOpen = !root.popupOpen
      }
    }
  }

  PopupCard {
    id: popup
    anchorItem: root
    bar: root.bar
    owner: root
    open: root.popupOpen
    contentWidth: popup.fittedContentWidth(Style.space(340))
    contentHeight: popup.fittedContentHeight(column.implicitHeight)

    Column {
      id: column
      anchors.fill: parent
      spacing: Style.space(10)

      Text {
        text: "System resources"
        color: root.bar.barForeground
        font.family: root.bar.fontFamily
        font.pixelSize: Style.font.heading
        font.bold: true
      }

      Text {
        text: "RAM     " + root.ramUsed + " / " + root.ramTotal + "  (" + root.ramPercent + ")\n" +
              "Free    " + root.ramAvailable + "\n" +
              "Swap    " + root.swapUsed + " / " + root.swapTotal
        color: root.bar.barForeground
        font.family: root.bar.fontFamily
        font.pixelSize: Style.font.body
        lineHeight: 1.3
      }

      PanelSeparator {}

      Text {
        text: "Disk    " + root.diskUsed + " / " + root.diskTotal + "  (" + root.diskPercent + ")\n" +
              "Free    " + root.diskFree + "\n" +
              "Mount   /"
        color: root.bar.barForeground
        font.family: root.bar.fontFamily
        font.pixelSize: Style.font.body
        lineHeight: 1.3
      }
    }
  }
}
