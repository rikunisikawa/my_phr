const GOOGLE_CHART_LOADER = "https://www.gstatic.com/charts/loader.js";
let googleChartsPromise;
let chartInstance;
let chartDataTable;
let chartOptions;
let chartContainerRef;
let resizeListenerRegistered = false;

function loadGoogleCharts() {
  if (window.google && window.google.charts) {
    return Promise.resolve();
  }

  if (!googleChartsPromise) {
    googleChartsPromise = new Promise((resolve, reject) => {
      const script = document.createElement("script");
      script.src = GOOGLE_CHART_LOADER;
      script.async = true;
      script.onload = () => resolve();
      script.onerror = () => reject(new Error("Failed to load Google Charts"));
      document.head.appendChild(script);
    }).then(() => {
      window.google.charts.load("current", { packages: ["corechart"] });
      return new Promise((resolve) => {
        window.google.charts.setOnLoadCallback(resolve);
      });
    });
  }

  return googleChartsPromise;
}

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
  const periodLabelMap = { daily: "日次", hourly: "時間別", weekly: "週次", monthly: "月次" };
  const hAxisTitleMap = { hourly: "時間帯", daily: "日付", weekly: "週", monthly: "月" };
  const periodLabel = periodLabelMap[periodKey] || periodKey;
  const hAxisTitle = hAxisTitleMap[periodKey] || "期間";
  const options = {
    title: periodLabel ? `${periodLabel}の指標推移` : "指標推移",
    legend: { position: "bottom" },
    seriesType: "line",
    series: {
      3: { type: "bars", targetAxisIndex: 1 }
    },
    vAxes: {
      0: { title: "平均値 (1-5)" },
      1: { title: "運動時間 (分)" }
    },
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
