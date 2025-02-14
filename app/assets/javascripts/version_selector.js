document.addEventListener("DOMContentLoaded", function () {
  const selectedVersionSpan = document.getElementById("selected-version");
  const versionToggle       = document.querySelector(".version-select");
  const versionDropdown     = versionToggle.closest(".dropdown");
  const dropdownMenu        = versionDropdown.querySelector(".dropdown-menu");

  function hideSelectedVersion() {
    const current = selectedVersionSpan.textContent.replace(/^#/, "");
    dropdownMenu.querySelectorAll("li").forEach((li) => {
      const linkVersion = li.querySelector(".version-link")?.dataset.version_name;
      li.style.display = (linkVersion === current) ? "none" : "block";
    });
  }

  function updateVersion(versionName) {
    fetch("/select_version", {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").getAttribute("content")
      },
      body: JSON.stringify({ version_name: versionName })
    })
      .then(async (response) => {
        if (!response.ok) {
          const text = await response.text();
          throw new Error(`Server error: ${response.status}, Response: ${text}`);
        }
      })
      .then(() => {
        localStorage.setItem("selectedVersion", versionName);
        window.location.reload();
      })
      .catch((error) => {
        console.error("Fetch error:", error);
        alert("Failed to update dataset. Check console for details.");
      });
  }

  // Handle dropdown version link clicks
  document.addEventListener("click", function (event) {
    const link = event.target.closest(".version-link");
    if (link) {
      event.preventDefault();
      updateVersion(link.getAttribute("data-version_name"));
      dropdownMenu.style.display = "none";
    }
  });

  // Show/hide dropdown on click
  versionToggle.addEventListener("click", function (event) {
    event.preventDefault();
    dropdownMenu.style.display =
      (dropdownMenu.style.display === "block") ? "none" : "block";
  });

  // Close dropdown if user clicks elsewhere
  document.addEventListener("click", function (event) {
    if (!event.target.closest(".dropdown")) {
      dropdownMenu.style.display = "none";
    }
  });

  // Restore previously selected version from localStorage
  const savedVersion = localStorage.getItem("selectedVersion");
  if (savedVersion) {
    selectedVersionSpan.textContent = `#${savedVersion}`;
  }

  hideSelectedVersion();
});
