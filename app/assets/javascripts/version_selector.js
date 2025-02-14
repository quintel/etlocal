document.addEventListener("DOMContentLoaded", function () {
  const selectedVersionSpan = document.getElementById("selected-version");
  const versionToggle = document.querySelector(".version-select");
  const versionDropdown = versionToggle.closest(".dropdown");
  const dropdownMenu = versionDropdown.querySelector(".dropdown-menu");

  // Function to update the selected version
  function updateVersion(versionName) {
    fetch("/select_version", {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").getAttribute("content")
      },
      body: JSON.stringify({ version_name: versionName })
    })
      .then(response => response.json())
      .then(data => {
        if (!data.error) {
          selectedVersionSpan.textContent = `#${versionName}`;
          localStorage.setItem("selectedVersion", versionName);
          alert(`Dataset updated to version: ${versionName}`);
        } else {
          alert(`Error: ${data.error}`);
        }
      })
      .catch(console.error);
  }

  // Event delegation for version selection (click on dropdown links)
  document.addEventListener("click", function (event) {
    const link = event.target.closest(".version-link");

    if (link) {
      event.preventDefault();
      updateVersion(link.getAttribute("data-version_name"));
      dropdownMenu.style.display = "none"; // Hide dropdown after selection
    }
  });

  // Dropdown toggle functionality
  versionToggle.addEventListener("click", function (event) {
    event.preventDefault();
    dropdownMenu.style.display = dropdownMenu.style.display === "block" ? "none" : "block";
  });

  // Close dropdown when clicking outside
  document.addEventListener("click", function (event) {
    if (!event.target.closest(".dropdown")) {
      dropdownMenu.style.display = "none";
    }
  });

  // Load the selected version from localStorage on page load
  const savedVersion = localStorage.getItem("selectedVersion");
  if (savedVersion) {
    selectedVersionSpan.textContent = `#${savedVersion}`;
  }
});
