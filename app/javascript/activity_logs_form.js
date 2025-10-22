const initActivityLogsForm = () => {
  const containers = document.querySelectorAll("[data-activity-logs-container]");
  if (!containers.length) return;

  containers.forEach((container) => {
    const list = container.querySelector("[data-activity-logs-list]");
    const template = container.querySelector("[data-activity-logs-template]");
    const addButton = container.querySelector("[data-activity-logs-add-button]");

    if (!list || !template || !addButton) return;

    const updateButtonState = () => {
      addButton.disabled = template.innerHTML.trim().length === 0;
    };

    addButton.addEventListener("click", () => {
      const uniqueId =
        typeof window.crypto !== "undefined" && typeof window.crypto.randomUUID === "function"
          ? window.crypto.randomUUID()
          : `${Date.now()}_${Math.floor(Math.random() * 1_000_000)}`;
      const content = template.innerHTML.replace(/NEW_RECORD/g, uniqueId);
      list.insertAdjacentHTML("beforeend", content);
    });

    container.addEventListener("click", (event) => {
      const removeButton = event.target.closest("[data-activity-logs-remove]");
      if (!removeButton) return;

      const card = removeButton.closest("[data-activity-logs-item]");
      if (card) {
        card.remove();
      }
    });

    updateButtonState();
  });
};

window.addEventListener("turbo:load", initActivityLogsForm);
