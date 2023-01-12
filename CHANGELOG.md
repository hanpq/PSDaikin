# Changelog for PSDaikin

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed

- Added back license URI i module manifest as the bug causing PowershellGet to fail packageing the module in beta17 is resolved.

## [1.11.2] - 2022-11-13

### Changed

- Disabled script signing in CI/CD

## [1.11.0] - 2022-11-13

### Changed

- Implemented new CI/CD pipeline

## [1.10.7] - 2022-11-13

### added

- Added deprication message

## [1.10.5] - 2021-11-04

### changed

- Test build process

## [1.10.3] - 2021-04-04

### fixed

- Restricted FQDN lookup to retreive IPv4 address as IPv6 is not supported by daikin aircon

## [1.10.2] - 2021-04-03

### fixed

- Updated function script functions with new psscriptinfo format

## [1.10.1] - 2021-04-03

### fixed

- Updated function script files with new psscriptinfo format

## [1.10.0] - 2021-04-01

### fixed

- Replace Resolve-DNSName with .Net method-call because Resolve-DNSName is Windows only

## [1.9.0] - 2021-04-01

### fixed

- Powershell Core: Resolved an error that occuered when testing connectivity to device

## [1.8.0] - 2021-03-26

### changed

- Changed module manifest to include support for linux and macos platforms

## [1.7.0] - 2021-03-26

### added

- This release is tested with 100% codecoverage

### fixed

- Fixed issue that caused setting of fan speed and direction to fail

## [1.2.0] - 2021-03-23

### changed

- Update module manifest privatedata

## [1.0.0] - 2021-03-01

### added

- First version
