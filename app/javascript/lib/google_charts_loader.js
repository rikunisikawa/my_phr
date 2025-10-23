const GOOGLE_CHART_LOADER = "https://www.gstatic.com/charts/loader.js"
let googleChartsPromise

export function loadGoogleCharts(packages = ["corechart"]) {
  if (window.google && window.google.charts) {
    return new Promise((resolve) => {
      window.google.charts.load("current", { packages })
      window.google.charts.setOnLoadCallback(resolve)
    })
  }

  if (!googleChartsPromise) {
    googleChartsPromise = new Promise((resolve, reject) => {
      const script = document.createElement("script")
      script.src = GOOGLE_CHART_LOADER
      script.async = true
      script.onload = resolve
      script.onerror = () => reject(new Error("Failed to load Google Charts"))
      document.head.appendChild(script)
    }).then(() => {
      window.google.charts.load("current", { packages })
      return new Promise((resolve) => {
        window.google.charts.setOnLoadCallback(resolve)
      })
    })
  }

  return googleChartsPromise
}
