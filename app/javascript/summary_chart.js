import { loadGoogleCharts } from "./lib/google_charts_loader";
let chartInstance;
let chartDataTable;
let chartOptions;
let chartContainerRef;
let resizeListenerRegistered = false;

function formatNoDataMessage(container) {
  container.innerHTML = "<p class='text-muted small mb-0'>表示できるデータがありません。</p>";
}

function drawChart(chartData, container) {
  const dataTable = new window.google.visualization.DataTable();
  chartData.columns.forEach((column) => {
    dataTable.addColumn(column.type, column.label);
  });
  chartData.rows.forEach((row) => {
    dataTable.addRow(row);
  });

  const periodKey = container.dataset.chartPeriod || "";
  const timeframeValue = parseInt(container.dataset.chartTimeframe || "", 10);
  const periodLabelMap = { daily: "日次", short_term: "短期推移", weekly: "週次", monthly: "月次" };
  const hAxisTitleMap = { short_term: "時刻", daily: "日付", weekly: "週", monthly: "月" };
  const periodLabel = periodLabelMap[periodKey] || periodKey;
  const hAxisTitle = hAxisTitleMap[periodKey] || "期間";
  const isShortTerm = periodKey === "short_term";
  const shouldShowMarkers = !isShortTerm || Number.isNaN(timeframeValue) || timeframeValue <= 12;
  const primaryPointSize = shouldShowMarkers ? 6 : 0;
  const sensorPointSize = shouldShowMarkers ? 5 : 0;

  const seriesConfig = {
    0: { type: "line", targetAxisIndex: 0, pointSize: primaryPointSize, color: "#1a73e8" },
    1: { type: "line", targetAxisIndex: 0, pointSize: primaryPointSize, color: "#fbbc04" },
    2: { type: "line", targetAxisIndex: 0, pointSize: primaryPointSize, color: "#d81b60" },
    3: { type: "bars", targetAxisIndex: 1, color: "#43a047" }
  };

  if (dataTable.getNumberOfColumns() >= 6) {
    seriesConfig[4] = { type: "line", targetAxisIndex: 2, pointSize: sensorPointSize, color: "#ef5350" };
  }
  if (dataTable.getNumberOfColumns() >= 7) {
    seriesConfig[5] = { type: "line", targetAxisIndex: 2, pointSize: sensorPointSize, color: "#1e88e5" };
  }
  if (dataTable.getNumberOfColumns() >= 8) {
    seriesConfig[6] = { type: "line", targetAxisIndex: 3, pointSize: sensorPointSize, color: "#6d4c41" };
  }

  const vAxesConfig = {
    0: { title: "平均値 (1-5)" },
    1: { title: "運動時間 (分)" }
  };

  if (dataTable.getNumberOfColumns() >= 6) {
    vAxesConfig[2] = { title: "温湿度 (°C / %)" };
  }
  if (dataTable.getNumberOfColumns() >= 8) {
    vAxesConfig[3] = { title: "CO₂ (ppm)" };
  }

  const options = {
    title: periodLabel ? `${periodLabel}の指標推移` : "指標推移",
    legend: { position: "bottom" },
    seriesType: "line",
    series: seriesConfig,
    vAxes: vAxesConfig,
    hAxis: { title: hAxisTitle },
    focusTarget: "category",
    chartArea: { width: "80%", height: "65%" },
    height: Math.max(container.offsetHeight, 360)
  };

  const chart = new window.google.visualization.ComboChart(container);
  chart.draw(dataTable, options);

  chartInstance = chart;
  chartDataTable = dataTable;
  chartOptions = options;
  chartContainerRef = container;
}

function redrawChart() {
  if (chartInstance && chartDataTable && chartOptions) {
    chartInstance.draw(chartDataTable, chartOptions);
  }
}

function renderSummaryChart() {
  const container = document.getElementById("summary-chart");
  if (!container) {
    return;
  }

  const chartDataRaw = container.dataset.chartData;
  if (!chartDataRaw) {
    formatNoDataMessage(container);
    return;
  }

  let chartData;
  try {
    chartData = JSON.parse(chartDataRaw);
  } catch (error) {
    console.error("Failed to parse chart data", error);
    formatNoDataMessage(container);
    return;
  }

  if (!chartData.rows || chartData.rows.length === 0) {
    formatNoDataMessage(container);
    return;
  }

  loadGoogleCharts()
    .then(() => {
      drawChart(chartData, container);
      if (!resizeListenerRegistered) {
        window.addEventListener("resize", redrawChart);
        resizeListenerRegistered = true;
      }
    })
    .catch((error) => {
      console.error(error);
      formatNoDataMessage(container);
    });
}

function resetChartState() {
  if (resizeListenerRegistered) {
    window.removeEventListener("resize", redrawChart);
    resizeListenerRegistered = false;
  }
  chartInstance = null;
  chartDataTable = null;
  chartOptions = null;
  chartContainerRef = null;
}

document.addEventListener("turbo:load", () => {
  renderSummaryChart();
});

document.addEventListener("turbo:before-cache", () => {
  if (chartContainerRef) {
    chartContainerRef.innerHTML = "";
  }
  resetChartState();
});
