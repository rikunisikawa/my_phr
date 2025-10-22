document.addEventListener("turbo:load", () => {
  document.querySelectorAll("[data-custom-field-form]").forEach((form) => {
    const typeSelect = form.querySelector("[data-field-type]")
    const optionsGroup = form.querySelector("[data-options-group]")
    const optionsInput = form.querySelector("[data-options-input]")

    if (!typeSelect || !optionsGroup) return

    const toggleOptions = () => {
      if (typeSelect.value === "select") {
        optionsGroup.classList.remove("d-none")
        if (optionsInput) optionsInput.removeAttribute("disabled")
      } else {
        optionsGroup.classList.add("d-none")
        if (optionsInput) optionsInput.setAttribute("disabled", "disabled")
      }
    }

    typeSelect.addEventListener("change", toggleOptions)
    toggleOptions()
  })
})
