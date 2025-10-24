const STORAGE_PREFIX = "health-log-activity-";

const generateUniqueId = () => {
  if (typeof window.crypto !== "undefined" && typeof window.crypto.randomUUID === "function") {
    return window.crypto.randomUUID();
  }
  return `${Date.now()}_${Math.floor(Math.random() * 1_000_000)}`;
};

const computeDateKey = (recordedAtInput) => {
  if (!recordedAtInput || !recordedAtInput.value) return null;
  const [datePart] = recordedAtInput.value.split("T");
  if (!datePart) return null;
  return `${STORAGE_PREFIX}${datePart}`;
};

const initActivityLogsForm = () => {
  const containers = document.querySelectorAll("[data-activity-logs-container]");
  if (!containers.length) return;

  containers.forEach((container) => {
    const list = container.querySelector("[data-activity-logs-list]");
    const template = container.querySelector("[data-activity-logs-template]");
    const addButton = container.querySelector("[data-activity-logs-add-button]");

    if (!list || !template || !addButton) return;

    const form = container.closest("form");
    const recordedAtInput = form ? form.querySelector('[name="health_log[recorded_at]"]') : null;
    const persistEnabled = container.dataset.activityLogsPersist === "true";
    const storageAvailable = (() => {
      try {
        const testKey = "__storage_test__";
        window.localStorage.setItem(testKey, testKey);
        window.localStorage.removeItem(testKey);
        return true;
      } catch (error) {
        return false;
      }
    })();

    const canPersist = persistEnabled && storageAvailable;
    let currentStorageKey = canPersist ? computeDateKey(recordedAtInput) : null;

    const updateButtonState = () => {
      addButton.disabled = template.innerHTML.trim().length === 0;
    };

    const addEntry = (data = {}) => {
      const uniqueId = generateUniqueId();
      const content = template.innerHTML.replace(/NEW_RECORD/g, uniqueId);
      list.insertAdjacentHTML("beforeend", content);
      const items = list.querySelectorAll("[data-activity-logs-item]");
      const card = items[items.length - 1];
      if (!card) return null;

      const typeInput = card.querySelector('input[name$="[activity_type]"]');
      const durationInput = card.querySelector('input[name$="[duration_minutes]"]');
      const intensitySelect = card.querySelector('select[name$="[intensity]"]');
      const customFieldsInput = card.querySelector('textarea[name$="[custom_fields_raw]"]');

      if (typeInput && Object.prototype.hasOwnProperty.call(data, "activity_type")) {
        typeInput.value = data.activity_type || "";
      }
      if (durationInput && Object.prototype.hasOwnProperty.call(data, "duration_minutes")) {
        durationInput.value = data.duration_minutes || "";
      }
      if (intensitySelect && Object.prototype.hasOwnProperty.call(data, "intensity")) {
        intensitySelect.value = data.intensity || "";
      }
      if (customFieldsInput && Object.prototype.hasOwnProperty.call(data, "custom_fields_raw")) {
        const value = data.custom_fields_raw;
        customFieldsInput.value = typeof value === "string" && value.length > 0 ? value : "";
      }

      return card;
    };

    const serializeEntries = () => {
      if (!canPersist || !currentStorageKey) return [];
      const entries = [];
      list.querySelectorAll("[data-activity-logs-item]").forEach((card) => {
        const typeInput = card.querySelector('input[name$="[activity_type]"]');
        const durationInput = card.querySelector('input[name$="[duration_minutes]"]');
        const intensitySelect = card.querySelector('select[name$="[intensity]"]');
        const customFieldsInput = card.querySelector('textarea[name$="[custom_fields_raw]"]');

        const entry = {
          activity_type: typeInput ? typeInput.value.trim() : "",
          duration_minutes: durationInput ? durationInput.value : "",
          intensity: intensitySelect ? intensitySelect.value : "",
          custom_fields_raw: customFieldsInput ? customFieldsInput.value : "",
        };

        if (
          entry.activity_type ||
          entry.duration_minutes ||
          entry.intensity ||
          (entry.custom_fields_raw && entry.custom_fields_raw.trim() !== "{}" && entry.custom_fields_raw.trim() !== "")
        ) {
          entries.push(entry);
        }
      });
      return entries;
    };

    const persistState = () => {
      if (!canPersist) return;
      currentStorageKey = computeDateKey(recordedAtInput);
      if (!currentStorageKey) return;

      const entries = serializeEntries();
      if (entries.length === 0) {
        window.localStorage.removeItem(currentStorageKey);
      } else {
        window.localStorage.setItem(currentStorageKey, JSON.stringify(entries));
      }
    };

    const loadState = () => {
      if (!canPersist) return;
      currentStorageKey = computeDateKey(recordedAtInput);
      if (!currentStorageKey) return;

      const raw = window.localStorage.getItem(currentStorageKey);
      if (!raw) return;

      let entries;
      try {
        entries = JSON.parse(raw);
      } catch (error) {
        entries = [];
      }

      if (!Array.isArray(entries)) return;

      list.innerHTML = "";
      entries.forEach((entry) => {
        addEntry(entry);
      });
      updateButtonState();
    };

    addButton.addEventListener("click", () => {
      addEntry({ custom_fields_raw: "{}" });
      updateButtonState();
      persistState();
    });

    container.addEventListener("click", (event) => {
      const removeButton = event.target.closest("[data-activity-logs-remove]");
      if (!removeButton) return;

      const card = removeButton.closest("[data-activity-logs-item]");
      if (card) {
        card.remove();
        persistState();
        updateButtonState();
      }
    });

    if (canPersist && !list.querySelector("[data-activity-logs-item]")) {
      loadState();
    }

    if (canPersist) {
      list.addEventListener("input", persistState);
      list.addEventListener("change", persistState);

      if (recordedAtInput) {
        recordedAtInput.addEventListener("change", () => {
          loadState();
        });
      }

      if (form) {
        form.addEventListener("turbo:submit-end", (event) => {
          if (event.detail.success) {
            currentStorageKey = computeDateKey(recordedAtInput);
            if (currentStorageKey) {
              window.localStorage.removeItem(currentStorageKey);
            }
          }
        });
      }
    }

    updateButtonState();
  });
};

window.addEventListener("turbo:load", initActivityLogsForm);
