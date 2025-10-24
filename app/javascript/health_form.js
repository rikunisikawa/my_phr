const initHealthSliders = (scope) => {
  scope.querySelectorAll("[data-health-slider]").forEach((container) => {
    const input = container.querySelector("[data-health-slider-input]");
    const valueEl = container.querySelector("[data-health-slider-value]");
    if (!input || !valueEl) return;

    const update = () => {
      valueEl.textContent = input.value;
    };

    input.addEventListener("input", update);
    update();
  });
};

const clearInputValue = (element) => {
  if (element.type === "checkbox" || element.type === "radio") {
    element.checked = false;
  } else if (element.tagName === "SELECT") {
    const blankOption = Array.from(element.options).find((option) => option.value === "");
    if (blankOption) {
      blankOption.selected = true;
    } else {
      element.selectedIndex = -1;
    }
  } else {
    element.value = "";
  }
};

const initCustomFieldToggles = (scope) => {
  scope.querySelectorAll("[data-custom-field]").forEach((container) => {
    const toggle = container.querySelector("[data-custom-field-toggle]");
    const body = container.querySelector("[data-custom-field-body]");
    const resetInput = container.querySelector("[data-custom-field-reset]");
    const fieldType = container.dataset.customFieldType;
    if (!toggle || !body) return;

    const inputs = Array.from(
      body.querySelectorAll("[data-custom-field-element], input, select, textarea")
    );

    const setEnabled = (enabled) => {
      if (enabled) {
        body.classList.remove("d-none");
        inputs.forEach((input) => {
          input.removeAttribute("disabled");
        });
        if (resetInput) {
          resetInput.setAttribute("disabled", "disabled");
        }
        const focusable = inputs.find((input) => !input.hidden && input.type !== "hidden");
        if (focusable) {
          focusable.focus({ preventScroll: true });
        }
      } else {
        body.classList.add("d-none");
        inputs.forEach((input) => {
          input.setAttribute("disabled", "disabled");
          if (input.type !== "hidden") {
            clearInputValue(input);
          }
        });
        if (resetInput) {
          if (fieldType === "boolean") {
            resetInput.setAttribute("disabled", "disabled");
          } else {
            resetInput.removeAttribute("disabled");
            resetInput.value = "";
          }
        }
      }
    };

    toggle.addEventListener("change", () => {
      setEnabled(toggle.checked);
    });

    setEnabled(toggle.checked);
  });
};

const initHealthForm = () => {
  const scope = document;
  initHealthSliders(scope);
  initCustomFieldToggles(scope);
};

document.addEventListener("turbo:load", initHealthForm);
