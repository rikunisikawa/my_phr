import * as Turbo from "@hotwired/turbo"
Turbo.start()

document.addEventListener('turbo:load', function() {
  const sleepDurationField = document.getElementById('health_record_sleep_duration');

  if (sleepDurationField) {
    sleepDurationField.addEventListener('keydown', function(event) {
      if (event.key === 'Enter') {
        event.preventDefault();
        this.blur(); // フォーカスを外す
      }
    });
  }
});
