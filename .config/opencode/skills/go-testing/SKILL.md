---
name: go-testing
description: Go testing standards and conventions for writing behavioral, well-structured tests
---

# Go Testing Standards

## Testing Philosophy (CRITICAL)

### Behavioral Testing Over Implementation
- Test **behavior only**, NOT implementation
- **NO call count assertions** like `assert.Len()`, `assert.Called()`, or counting how many times a function was called
- Focus on verifying data correctness and state changes, not internal mechanics

### Mocking Strategy
- Use mocks to **verify data correctness written to DB**, not to verify how many times something was called
- **Don't mock service functions** - only mock repository/client interfaces
- **Verify assertions INSIDE mock functions** when checking inputs, not after
- Pattern:
  ```go
  repoMock := &MockTransactionRepository{
      SomeFunc: func(ctx context.Context, arg string) error {
          require.Equal(t, expectedValue, arg)  // Verify inside mock
          return nil
      },
  }
  ```

### Test Execution
- Use `synctest.Test()` for all tests (provides goroutine-safe test execution)
- Minimal comments - code should be self-documenting
- **NO time-based range checks** (3 min +/- 100ms is wrong; separate TTL validation into dedicated test)

## Test Structure Pattern

### Happy Path
- Single test per function verifying success scenario
- Verify all expected side effects (data stored, fields set correctly)

### Error Paths
- Table-driven subtests grouping related error scenarios
- Each error test case:
  - Returns error from mock
  - Asserts `require.Error(t, err)` 
  - Verifies error doesn't cause side effects (data not written to DB, etc.)

### Example Structure
```go
func TestFunctionName(t *testing.T) {
    synctest.Test(t, func(t *testing.T) {
        // Setup
        // Execute
        // Assert
    })
}

func TestFunctionName_Errors(t *testing.T) {
    tests := []struct {
        name string
        // fields for test case
    }{
        {
            name: "error scenario 1",
            // setup specific to this error
        },
        // more test cases
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            synctest.Test(t, func(t *testing.T) {
                // Setup with error mock
                // Execute
                require.Error(t, err)
            })
        })
    }
}
```

## Code Knowledge

### Repository vs Service Session Types
- `repositories/mtp.Session` - Contains only fields stored in DB
- `services/mtp.Session` - Transformed version with `Challenge` field and `State` enum
- `ToSession()` function transforms repo Session to service Session

### Testing Utilities Available
- `mockSession()` - Helper creates valid test session
- `generateTestData()` - Helper creates valid Connective user data
- `mockRepo()` - Helper creates pre-configured mock repository
- `db.NewFakeTransaction()` - Available for transaction testing

### Error Grouping
- Use table-driven subtests for related error scenarios
- Each error type gets its own subtest within `TestFunctionName_Errors`
- Do NOT combine different error types into one test function

## Key Patterns to Avoid
- `assert.Len()` or similar call count assertions
- Mocking service functions (only mock repositories/clients)
- Time-based range checks in assertions
- Comments explaining obvious code
- Combining different error types into single test
- Verifying assertions after mock execution (verify inside mock functions)
- **Conditional logic in tests** - If table-driven test cases require different setup branches (if/else), split them into separate test functions instead
- **Asserting unexported error values** - For unexported/internal errors, only assert `require.Error(t, err)`. Do NOT use `Contains`, `ErrorIs`, or similar to check unexported error messages or values. The exact error is an implementation detail. Only assert specific error values for exported errors.

## Key Patterns to Use
- Behavioral assertions (verify data stored, state changed)
- Mock repository/client interfaces only
- `synctest.Test()` for all tests
- Table-driven error subtests
- Assertions inside mock functions for input verification
- Self-documenting code with minimal comments

## Workflow
- Always run `make lint` after writing tests and fix any lint issues in test files before presenting results
