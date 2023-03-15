locals {
  timestamp = timestamp()

  apis = tomap({

    sample : {
      "method" : "POST",
      "api_version" : var.sample_api_version
    }
    # Add more api metadata to get the required apis created
    #
    # , sample2 : {
    #     "method" : "GET", or any other HTTP method
    #     "api_version" : var.sample2_api_version
    #   }
    # ...
  })
}