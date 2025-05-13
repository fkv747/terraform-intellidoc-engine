document.getElementById("file-input").addEventListener("change", function () {
  const fileName = this.files[0]?.name || "No file selected";
  document.getElementById("fileName").textContent = fileName;
});

document.getElementById("upload-form").addEventListener("submit", async function (e) {
  e.preventDefault();

  const fileInput = document.getElementById("file-input");
  const file = fileInput.files[0];

  if (!file) {
    alert("Please select a file.");
    return;
  }

  try {
    // Step 1: Request presigned URL
    const response = await fetch("https://drjsvcgybd.execute-api.us-east-1.amazonaws.com/generate-presigned-url", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({ filename: file.name })
    });

    const data = await response.json();
    const uploadUrl = data.upload_url;

    // Step 2: Upload file to S3
    const upload = await fetch(uploadUrl, {
      method: "PUT",
      headers: {
        "Content-Type": "application/octet-stream"
      },
      body: file
    });

    if (upload.ok) {
      alert("Upload successful!");
      fileInput.value = "";
    } else {
      alert("Upload failed.");
      console.error(await upload.text());
    }

  } catch (err) {
    console.error("Error uploading file:", err);
    alert("Something went wrong. Check console.");
  }
});
