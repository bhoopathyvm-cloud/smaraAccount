## ADDED Requirements

### Requirement: View Model Stream Listeners Are Teardown-Safe
A `ChangeNotifier` view model that subscribes to repository streams SHALL NOT,
after its `dispose()` has run, raise an unhandled error, call
`notifyListeners`, or read from a resource (such as a database connection) that
teardown may have closed. Where a stream listener is `async` and `await`s
mid-callback, the view model SHALL check a disposed flag after each `await`
before touching state, and SHALL attach an `onError` handler to each
subscription so a query that fails because the connection closed during
teardown is not surfaced as an unhandled asynchronous error.

#### Scenario: Emission resolves after dispose
- **WHEN** a repository stream delivers a value to an `async` view-model
  listener, the listener suspends at an `await`, and the view model is disposed
  before that `await` completes
- **THEN** nothing is thrown, no `notifyListeners` fires, and no read is made
  against the closed resource

#### Scenario: Stream errors during teardown are absorbed
- **WHEN** a subscribed repository query is in flight as the database
  connection closes (the view's own disposal, or an acceptance test's
  device reset) and the stream emits an error
- **THEN** the disposed view model absorbs it rather than letting it escape as
  an unhandled async error

#### Scenario: Errors while the view model is alive still surface
- **WHEN** a subscribed stream emits an error while the view model has not been
  disposed
- **THEN** the error is not swallowed
