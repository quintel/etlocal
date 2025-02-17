document.addEventListener("DOMContentLoaded", function () {
  const selectedVersionSpan = document.getElementById("selected-version");
  const versionToggle       = document.querySelector(".version-select");
  const versionDropdown     = versionToggle.closest(".dropdown");
  const dropdownMenu        = versionDropdown.querySelector(".dropdown-menu");

  function hideSelectedVersion() {
    const current = selectedVersionSpan.textContent.replace(/^#/, ""); // remove leading #
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
      .then(response => {
        if (!response.ok) {
          return response.text().then(text => { throw new Error(`Server error: ${response.status}, Response: ${text}`); });
        }
        return response.json();
      })
      .then(data => {
        console.log("✅ Server Response:", data); // Debugging log

        if (data.error) {
          alert(`❌ Error: ${data.error}`);
          return;
        }

        selectedVersionSpan.textContent = `#${versionName}`;
        localStorage.setItem("selectedVersion", versionName);
        alert(`✅ Dataset updated to version: ${versionName}`);

        hideSelectedVersion();
      })
      .catch(error => {
        console.error("🚨 Fetch error:", error);
        alert(`⚠️ Failed to update dataset. Check console for details.`);
      });
  }

  document.addEventListener("click", function (event) {
    const link = event.target.closest(".version-link");
    if (link) {
      event.preventDefault();
      updateVersion(link.getAttribute("data-version_name"));
      dropdownMenu.style.display = "none";
    }
  });

  versionToggle.addEventListener("click", function (event) {
    event.preventDefault();
    dropdownMenu.style.display = (dropdownMenu.style.display === "block") ? "none" : "block";
  });

  document.addEventListener("click", function (event) {
    if (!event.target.closest(".dropdown")) {
      dropdownMenu.style.display = "none";
    }
  });

  const savedVersion = localStorage.getItem("selectedVersion");
  if (savedVersion) {
    selectedVersionSpan.textContent = `#${savedVersion}`;
  }

  hideSelectedVersion();
});
