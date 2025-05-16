const SEARCH_API_URL = "https://ryb64vrz2l.execute-api.us-east-1.amazonaws.com/search"; // Replace if needed

// Display selected file name
document.getElementById("file-input").addEventListener("change", function () {
  const fileName = this.files[0]?.name || "No file selected";
  document.getElementById("fileName").textContent = fileName;
});

// Handle file upload
document.getElementById("upload-form").addEventListener("submit", async function (e) {
  e.preventDefault();

  const fileInput = document.getElementById("file-input");
  const file = fileInput.files[0];

  if (!file) {
    alert("Please select a file.");
    return;
  }

  try {
    // Step 1: Get presigned URL
    const response = await fetch("https://ryb64vrz2l.execute-api.us-east-1.amazonaws.com/generate-presigned-url", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ filename: file.name })
    });

    const data = await response.json();
    const uploadUrl = data.upload_url;

    // Step 2: Upload to S3
    const upload = await fetch(uploadUrl, {
      method: "PUT",
      headers: { "Content-Type": "application/octet-stream" },
      body: file
    });

    if (upload.ok) {
      alert("Upload successful!");
      fileInput.value = "";
      document.getElementById("fileName").textContent = "No file selected";
    } else {
      alert("Upload failed.");
      console.error(await upload.text());
    }

  } catch (err) {
    console.error("Error uploading file:", err);
    alert("Something went wrong. Check console.");
  }
});

// Handle search
document.querySelector(".search-btn").addEventListener("click", async () => {
  const query = document.querySelector(".search-input").value.trim();
  if (!query) {
    alert("Please enter a search term.");
    return;
  }

  try {
    const res = await fetch(`${SEARCH_API_URL}?q=${encodeURIComponent(query)}`);
    const data = await res.json();
    displayResults(data.results || []);
  } catch (err) {
    console.error("Search failed:", err);
    alert("Something went wrong with the search.");
  }
});

// Display search results
function displayResults(results) {
  const container = document.getElementById("search-results");
  container.innerHTML = "";

  if (results.length === 0) {
    container.innerHTML = "<p>No results found.</p>";
    return;
  }

  results.forEach(doc => {
    const div = document.createElement("div");
    div.className = "result-item";
    div.innerHTML = `
      <h3>${doc.category || "Unknown Category"}</h3>
      <p><strong>Confidence:</strong> ${doc.confidence}</p>
      <p>${
        Array.isArray(doc.extracted_text)
          ? doc.extracted_text.join("<br>")
          : (doc.extracted_text || "")
      }</p>
      <hr/>
    `;
    container.appendChild(div);
  });
}
