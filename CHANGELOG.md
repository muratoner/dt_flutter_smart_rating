## 0.0.2

### ✨ New Features
* **Failure Tracking System**: Track network failures with `failureCount`, `hasFailures` getters
* **Smart Manual Triggering**: New parameters for `showRatingDialog()`:
  - `onlyIfNoFailures`: Only show dialog if no failures occurred
  - `requireMinimumSuccess`: Only show if minimum success count reached
  - `maximumAllowedFailures`: Set a tolerance level for failures
* **Session Management**: New `resetCounters()` method to reset all counters
* **Public Getters**: Access `successCount`, `failureCount`, and `hasFailures`

### 🔧 Improvements
* Enhanced `reportNetworkFailure()` to track failure count
* Better debug logging with failure counts
* Improved documentation with use cases and examples

### ⚠️ Breaking Changes
* **NONE** - All new features are backward compatible with default parameter values

## 0.0.1

* Initial release
* Smart rating dialog based on network success
* Automatic and manual triggering modes
* Configurable theming and localization
* Dio interceptor for automatic network monitoring

