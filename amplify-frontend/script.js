const fileInput = document.getElementById("fileInput");
const fileName = document.getElementById("fileName");
const form = document.getElementById("uploadForm");

fileInput.addEventListener("change", function () {
  if (fileInput.files.length > 0) {
    fileName.textContent = fileInput.files[0].name;
  } else {
    fileName.textContent = "No file selected";
  }
});

form.addEventListener("submit", function (e) {
  e.preventDefault();
  if (!fileInput.files[0]) {
    alert("Please select a file to upload.");
    return;
  }

  alert("Upload triggered. (Connect to S3 later)");
});
