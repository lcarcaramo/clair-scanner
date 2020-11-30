# Tags
> _Built from [`quay.io/ibmz/golang:1.14`](https://quay.io/repository/ibmz/golang?tab=tags)_
-	[`13.0`](https://github.com/lcarcaramo/clair-scanner/blob/master/s390x/Dockerfile) - [![Build Status](https://travis-ci.com/lcarcaramo/clair-scanner.svg?branch=master)](https://travis-ci.com/lcarcaramo/clair-scanner)
# What is Clair scanner

## Docker containers vulnerability scan

When you work with containers (Docker) you are not only packaging your application but also part of the OS. It is crucial to know what kind of libraries might be vulnerable in your container. One way to find this information is to look at the Docker registry [Hub or Quay.io] security scan. This means your vulnerable image is already on the Docker registry.

What you want is a scan as a part of CI/CD pipeline that stops the Docker image push on vulnerabilities:

1. Build and test your application
1. Build the container
1. Test the container for vulnerabilities
1. Check the vulnerabilities against allowed ones, if everything is allowed then pass otherwise fail

This straightforward process is not that easy to achieve when using the services like Docker Hub or Quay.io. This is because they work asynchronously which makes it harder to do straightforward CI/CD pipeline.

## Clair to the rescue

CoreOS has created an awesome container scan tool called Clair. Clair is also used by Quay.io. What clair does not have is a simple tool that scans your image and compares the vulnerabilities against a whitelist to see if they are approved or not.

This is where clair-scanner comes into place. The clair-scanner does the following:

* Scans an image against Clair server
* Compares the vulnerabilities against a whitelist
* Tells you if there are vulnerabilities that are not in the whitelist and fails
* If everything is fine it completes correctly

## Credits

The clair-scanner is a copy of the Clair 'analyze-local-images' <https://github.com/coreos/analyze-local-images> with changes/improvements and addition that checks the vulnerabilities against a whitelist.

# How to use this image

* Start a [Clair database](https://quay.io/repository/ibmz/clair) container.

* Run Clair Scanner.
> _Note that `docker.sock` needs to be mounted to the container because this image runs [Docker](https://quay.io/repository/ibmz/docker) inside a container._

```console
$ docker run --network container:clair --rm -v /var/run/docker.sock:/var/run/docker.sock:ro \
                       quay.io/ibmz/clair-scanner:13.0 --threshold="Negligible" --clair="http://localhost:6060" <local image that you want to scan with clair>
...
Scan report will be printed to the console.
...
```

## Help information

```console
$ docker run --rm -v /var/run/docker.sock:/var/run/docker.sock:ro quay.io/ibmz/clair-scanner:13.0 -h

Usage: clair-scanner [OPTIONS] IMAGE

Scan local Docker images for vulnerabilities with Clair

Arguments:
  IMAGE=""     Name of the Docker image to scan

Options:
  -w, --whitelist=""                    Path to the whitelist file
  -t, --threshold="Unknown"             CVE severity threshold. Valid values; 'Defcon1', 'Critical', 'High', 'Medium', 'Low', 'Negligible', 'Unknown'
  -c, --clair="http://127.0.0.1:6060"   Clair URL
  --ip="localhost"                      IP address where clair-scanner is running on
  -l, --log=""                          Log to a file
  --all, --reportAll=true               Display all vulnerabilities, even if they are approved
  -r, --report=""                       Report output file, as JSON
  --exit-when-no-features=false         Exit with status code 5 when no features are found for a particular image
```

## Example whitelist yaml file

This is an example yaml file. You can have an empty file or a mix with only `generalwhitelist` or `images`.

```yaml
generalwhitelist: #Approve CVE for any image
  CVE-2017-6055: XML
  CVE-2017-5586: OpenText
images:
  ubuntu: #Approve CVE only for ubuntu image, regardles of the version. If it is a private registry with a custom port registry:777/ubuntu:tag this won't work due to a bug.
    CVE-2017-5230: Java
    CVE-2017-5230: XSX
  alpine:
    CVE-2017-3261: SE
```
## Troubleshooting

If you get `[CRIT] ▶ Could not save Docker image [image:version]: Error response from daemon: reference does not exist`, this means that image `image:version` is not locally present. You should have this image present locally before trying to analyze it (e.g.: `docker pull image:version`).

Errors like `[CRIT] ▶ Could not analyze layer: Clair responded with a failure: Got response 400 with message {"Error":{"Message":"could not find layer"}}` indicates that Clair can not retrieve a layer from `clair-scanner`. This means that you probably specified a wrong IP address in options (`--ip`). Note that you should use a publicly accessible IP when clair is running in a container, or it wont be able to connect to `clair-scanner`. If Clair and Clair Scanner are running on the same zCX appliance, use Docker networks as shown in the example in the __How to use this image__ section.

`[CRIT] ▶ Could not read Docker image layers: manifest.json is not valid` fires when image version is not specified and is required. Try to add `:version` (.e.g. `:latest`) after the image name.

`[CRIT] ▶ Could not analyze layer: POST to Clair failed Post http://localhost:6060/v1/layers: dial tcp: lookup docker on 127.0.0.1:6060: no such host` indicates that clair server could ne be reached. Double check hostname and port in `-c` argument, and your clair settings.

## License

Apache 2.0 License. See license [here](https://github.com/arminc/clair-scanner/blob/master/LICENSE)
