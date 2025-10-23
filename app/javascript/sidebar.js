const initializeSidebarToggle = () => {
  const sidebar = document.querySelector('#appSidebar');
  const toggleButton = document.querySelector('.js-sidebar-toggle');

  if (!sidebar || !toggleButton) {
    return;
  }

  const icon = toggleButton.querySelector('.toggle-icon');
  const label = toggleButton.querySelector('.toggle-label');

  const updateState = () => {
    const isCollapsed = sidebar.classList.contains('collapsed');
    toggleButton.setAttribute('aria-expanded', (!isCollapsed).toString());

    if (icon) {
      icon.textContent = isCollapsed ? 'chevron_right' : 'chevron_left';
    }

    if (label) {
      label.textContent = isCollapsed ? '拡張' : '折りたたむ';
    }
  };

  toggleButton.addEventListener('click', () => {
    sidebar.classList.toggle('collapsed');
    document.body.classList.toggle('sidebar-collapsed', sidebar.classList.contains('collapsed'));
    updateState();
  });

  updateState();
};

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initializeSidebarToggle);
} else {
  initializeSidebarToggle();
}
