// ViewController.cs
using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Storage;
using Microsoft.Azure.Storage.Blob;

namespace CatService
{
    // The ViewController handles the view function
    [ApiController]
    [Route("[controller]")]
    public class ViewController : ControllerBase
    {
        // The connection string to the Azure Storage account
        private const string connectionString = System.Environment.GetEnvironmentVariable("CONNECTION_STRING");

        // The name of the container where the cat pictures are stored
        private const string containerName = System.Environment.GetEnvironmentVariable("CONTAINER_NAME");

        // The constructor initializes the CloudBlobClient and the CloudBlobContainer objects
        public ViewController()
        {
            // Create a CloudStorageAccount object from the connection string
            CloudStorageAccount storageAccount = CloudStorageAccount.Parse(connectionString);

            // Create a CloudBlobClient object that represents the Blob service endpoint
            CloudBlobClient blobClient = storageAccount.CreateCloudBlobClient();

            // Create a CloudBlobContainer object that represents the container
            CloudBlobContainer container = blobClient.GetContainerReference(containerName);
        }

        // The GET method returns a random cat picture URL
        [HttpGet]
        public async Task<string> Get()
        {
            // Get the list of blobs in the container
            BlobResultSegment resultSegment = await container.ListBlobsSegmentedAsync(null);

            // Get the number of blobs in the container
            int count = resultSegment.Results.Count;

            // Generate a random index between 0 and count - 1
            Random random = new Random();
            int index = random.Next(0, count);

            // Get the blob name at the index
            string blobName = resultSegment.Results[index].Uri.Segments[3];
        }
    }
}
