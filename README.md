# Labtec/ruby-docker-images

The Dockerfile is available in [this repository](https://github.com/Labtec/ruby-docker-images/blob/master/Dockerfile).

Built images are available here:

* https://github.com/Labtec/ruby-docker-images/pkgs/container/ruby

## What is this?

This repository consists of two kinds of images. One is for production use, and the other is for development.

An image for development is based on the image for production of the same ruby and FreeBSD versions and installed development tools such as lldb, in addition. It has `-dev` suffix after the version number, like `labtec/ruby:3.3.0-dev-15.0`.

The list of image names in this repository is below:

## Images

### FreeBSD 15.0-CURRENT

- master
  - labtec/ruby:master-15.0
  - labtec/ruby:master-dev-15.0
  - labtec/ruby:master-debug-15.0
  - labtec/ruby:master-debug-dev-15.0
- 3.3
  - labtec/ruby:latest-15.0
  - labtec/ruby:3.3-15.0
  - labtec/ruby:3.3.5-15.0
- 3.2
  - labtec/ruby:3.2-15.0
  - labtec/ruby:3.2.5-15.0
- 3.1
  - labtec/ruby:3.1-15.0
  - labtec/ruby:3.1.6-15.0

### FreeBSD 14.2-RELEASE

- master
  - labtec/ruby:master-14.2
  - labtec/ruby:master-dev-14.2
  - labtec/ruby:master-debug-14.2
  - labtec/ruby:master-debug-dev-14.2
- 3.3
  - labtec/ruby:latest-14.2
  - labtec/ruby:3.3-14.2
  - labtec/ruby:3.3.5-14.2
- 3.2
  - labtec/ruby:3.2-14.2
  - labtec/ruby:3.2.5-14.2
- 3.1
  - labtec/ruby:3.1-14.2
  - labtec/ruby:3.1.6-14.2

### Misc

We have some other images for special purposes.

- Preview or Release-candidate versions (e.g. `labtec/ruby:2.7.0-preview1-14.2`)
- Nightly built master (e.g. `labtec/ruby:master-nightly-14.2`)
- Nightly debug built master (e.g. `labtec/ruby:master-debug-nightly-14.2`)
- EOL versions (e.g. `labtec/ruby:2.4.10-14.2`)

All the images are based on `freebsd:14.2`, and made from just doing `make install` and installing bundler.

## How to build images

```
rake docker:build ruby_version=<Ruby version you want to build>
```

You can specify the specific revision in the master branch like:

```
rake docker:build ruby_version=master:ce798d08de
```

## Build and push for the specific ruby and FreeBSD versions

Trigger GitHub Actions workflow with `ruby_version` and `freebsd_version` pipeline parameters.
Nightly build workflow is triggered if the workflow triggered with `ruby_version` of `"nightly"`.
The nightly build workflow only builds images of FreeBSD/amd64 platform.

## Nightly build workflow

Nightly build workflow is performed by GitHub Action's scheduled pipeline system.
The build is triggered at 16:00 UTC (01:00 JST) every night.

## Author

Kenta Murata

## License

MIT
