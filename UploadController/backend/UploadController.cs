// UploadController.cs
using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Storage;
using Microsoft.Azure.Storage.Blob;

namespace CatService
{
    // The UploadController handles the upload function
    [ApiController]
    [Route("[controller]")]
    public class UploadController : ControllerBase
    {
        // The connection string to the Azure Storage account
        private const string connectionString = System.Environment.GetEnvironmentVariable("CONNECTION_STRING");

        // The name of the container where the cat pictures are stored
        private const string containerName = System.Environment.GetEnvironmentVariable("CONTAINER_NAME");

        // The constructor initializes the CloudBlobClient and the CloudBlobContainer objects
        public UploadController()
        {
            // Create a CloudStorageAccount object from the connection string
            CloudStorageAccount storageAccount = CloudStorageAccount.Parse(connectionString);

            // Create a CloudBlobClient object that represents the Blob service endpoint
            CloudBlobClient blobClient = storageAccount.CreateCloudBlobClient();

            // Create a CloudBlobContainer object that represents the container
            CloudBlobContainer container = blobClient.GetContainerReference(containerName);
        }

        // The POST method uploads a cat picture to the container
        [HttpPost]
        public async Task<IActionResult> Post()
        {
            // Get the file from the request body
            var file = Request.Form.Files[0];

            // Check if the file is not null and has a valid content type
            if (file != null && file.ContentType.StartsWith("image/"))
            {
                // Generate a unique name for the blob
                string blobName = Guid.NewGuid().ToString() + Path.GetExtension(file.FileName);

                // Get a reference to the blob
                CloudBlockBlob blob = container.GetBlockBlobReference(blobName);

                // Set the blob content type
                blob.Properties.ContentType = file.ContentType;

                // Upload the file to the blob
                await blob.UploadFromStreamAsync(file.OpenReadStream());

                // Return a success message with the blob URL
                return Ok($"Cat picture uploaded successfully. You can view it at {urlPrefix}{blobName}");
            }
            else
            {
                // Return a bad request message if the file is invalid
                return BadRequest("Invalid file. Please upload an image file.");
            }
        }
    }
}
