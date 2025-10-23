import { loadGoogleCharts } from "./lib/google_charts_loader"

let chartInstance
let chartDataTable
let chartOptions
let chartContainer
let resizeListenerRegistered = false

function formatNoDataMessage(container) {
  container.innerHTML = "<p class='text-muted small mb-0'>表示できるデータがありません。</p>"
}

function drawChart(chartData, container) {
  const dataTable = new window.google.visualization.DataTable()
  chartData.columns.forEach((column) => {
    dataTable.addColumn(column.type, column.label)
  })
  dataTable.addRows(chartData.rows)

  const options = {
    title: "環境センサー値の推移",
    legend: { position: "bottom" },
    seriesType: "line",
    series: {
      0: { type: "line", targetAxisIndex: 0, color: "#e53935" },
      1: { type: "line", targetAxisIndex: 0, color: "#1e88e5" },
      2: { type: "bars", targetAxisIndex: 1, color: "#43a047" }
    },
    vAxes: {
      0: { title: "温度 (°C) / 湿度 (%)" },
      1: { title: "CO₂ (ppm)" }
    },
    hAxis: { title: "時刻" },
    chartArea: { width: "80%", height: "65%" },
    height: Math.max(container.offsetHeight, 320),
    focusTarget: "category"
  }

  const chart = new window.google.visualization.ComboChart(container)
  chart.draw(dataTable, options)

  chartInstance = chart
  chartDataTable = dataTable
  chartOptions = options
  chartContainer = container
}

function redrawChart() {
  if (chartInstance && chartDataTable && chartOptions) {
    chartInstance.draw(chartDataTable, chartOptions)
  }
}

function renderEnvironmentChart() {
  const container = document.getElementById("environment-chart")
  if (!container) {
    return
  }

  const rawData = container.dataset.chartData
  if (!rawData) {
    formatNoDataMessage(container)
    return
  }

  let chartData
  try {
    chartData = JSON.parse(rawData)
  } catch (error) {
    console.error("Failed to parse environment chart data", error)
    formatNoDataMessage(container)
    return
  }

  if (!chartData.rows || chartData.rows.length === 0) {
    formatNoDataMessage(container)
    return
  }

  loadGoogleCharts()
    .then(() => {
      drawChart(chartData, container)
      if (!resizeListenerRegistered) {
        window.addEventListener("resize", redrawChart)
        resizeListenerRegistered = true
      }
    })
    .catch((error) => {
      console.error(error)
      formatNoDataMessage(container)
    })
}

function resetState() {
  if (resizeListenerRegistered) {
    window.removeEventListener("resize", redrawChart)
    resizeListenerRegistered = false
  }
  chartInstance = null
  chartDataTable = null
  chartOptions = null
  chartContainer = null
}

document.addEventListener("turbo:load", () => {
  renderEnvironmentChart()
})

document.addEventListener("turbo:before-cache", () => {
  if (chartContainer) {
    chartContainer.innerHTML = ""
  }
  resetState()
})
