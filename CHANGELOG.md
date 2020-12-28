# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Security
* Escape XML special characters in `transaction_locator_id` to prevent XML injection.

## [3.3.0] - 2020-12-28
### Added
* Lots of new AAMVA fields
### Fixed
* Removed extra whitespace from `transaction_locator_id` and `auth_token`