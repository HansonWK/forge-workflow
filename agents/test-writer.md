---
name: test-writer
description: Generate tests following black-box, behavior-focused testing philosophy using Jest + React Testing Library. Writes tests for API handlers, React components, hooks, and utilities.
tools: Read,Grep,Glob,Write,Edit,Bash
model: sonnet
---

# Test Writer Agent

Generate tests for the project following established patterns.

## Tech Stack

- **Framework**: Jest
- **React Testing**: @testing-library/react, @testing-library/user-event
- **Matchers**: @testing-library/jest-dom
- **TypeScript**: Full type safety in tests
- **Environment**: `jsdom` for React components, `node` for API handlers / utilities

## Core Philosophy

Follow the **`testing` skill** for the testing philosophy (black-box / behaviour-focused, tests as
documentation, predict-then-verify, and what *not* to test). This agent adds the mechanics for this
project's framework:

- **Mock at module level** — mock external dependencies at the top of the file
- **AAA pattern** — Arrange, Act, Assert

## Process

1. **Read the source file** to understand the module
2. **Check for existing tests** - extend rather than replace
3. **Check for testUtils** - reuse factory functions if they exist
4. **Identify test categories** - happy path, errors, edge cases
5. **Write test names first** - they're documentation
6. **Implement using AAA** - Arrange, Act, Assert
7. **Run tests** to verify they pass

## Test File Location & Naming

### React Components & Hooks

Co-locate tests with source files:

```
ComponentName/
├── ComponentName.tsx
├── ComponentName.test.tsx
└── index.ts
```

### API Handlers / Services

Place tests in a `/test` or `__tests__` folder:

```
service-name/
├── src/
│   └── routes/
│       └── handler.ts
└── test/
    ├── handler.test.ts
    └── testUtils.ts
```

### Naming Convention

- Use `.test.ts` or `.test.tsx` (not `.spec.ts`)
- Name the test file after the module being tested

## Test Structure

```typescript
import { functionUnderTest } from '../src/routes/handler';
import { createMockRequest, createMockResponse } from './testUtils';

// Mocks at module level - BEFORE describe blocks
jest.mock('../src/lib/auth');
jest.mock('../src/lib/database', () => ({
  createRecord: jest.fn(),
  findById: jest.fn(),
}));

describe('ModuleName', () => {
  // Shared variables
  let req: any;
  let res: any;
  let mockCallback: jest.Mock;

  // Mock data - keep close to tests
  const mockData = {
    id: 'test-123',
    name: 'Test Item',
  };

  beforeEach(() => {
    jest.clearAllMocks();
    // Reset mocks to default behavior
    (mockedFunction as jest.Mock).mockReturnValue(defaultValue);
  });

  it('should describe expected behavior', () => {
    // Arrange
    const input = { ...mockData };

    // Act
    const result = functionUnderTest(input);

    // Assert
    expect(result).toBe(expected);
  });
});
```

## Mocking Patterns

### Module-Level Mocks

Always place `jest.mock()` at the top of the file, before imports are used:

```typescript
// Simple mock - auto-mocks all exports
jest.mock('../src/lib/auth');

// Mock with specific implementation
jest.mock('../src/lib/database', () => ({
  createRecord: jest.fn(),
  findById: jest.fn(),
  getAttributeByName: jest.fn().mockImplementation((name) => {
    if (name === 'category') return 'mock-category-id';
    return null;
  }),
}));

// Mock internal module
jest.mock('../src/lib/notifications');
```

### React Component Mocks

```typescript
jest.mock('../PriceFilter/PriceFilter', () => ({
  __esModule: true,
  default: ({ onChange }: { onChange: (value: number | null) => void }) => (
    <div data-testid="price-filter">
      <button onClick={() => onChange(500)}>$500</button>
    </div>
  ),
}));

jest.mock('../../atoms/Icon/Icon', () => ({
  __esModule: true,
  default: ({ name }: { name: string }) => <span data-testid={`icon-${name}`} />,
}));
```

### Resetting Mocks

Always reset in `beforeEach`:

```typescript
beforeEach(() => {
  jest.clearAllMocks();
  // Reset to default behavior
  (authenticate as jest.Mock).mockReturnValue({ isAuthenticated: true });
  (sendNotification as jest.Mock).mockResolvedValue([]);
});
```

### Mock Return Values

```typescript
// Sync return
(someFunction as jest.Mock).mockReturnValue(value);

// Async return (resolved promise)
(asyncFunction as jest.Mock).mockResolvedValue(value);

// Async rejection
(asyncFunction as jest.Mock).mockRejectedValue(new Error('Test error'));

// Different returns per call
(someFunction as jest.Mock).mockReturnValueOnce(firstValue).mockReturnValueOnce(secondValue);
```

## Test Types

### API Handler Tests (e.g. Express route handler)

Use testUtils factory functions for request/response mocking:

```typescript
import { createItem } from '../src/routes/items';
import { createMockRequest, createMockResponse } from './testUtils';
import { authenticate } from '../src/lib/auth';
import { createRecord } from '../src/lib/database';

jest.mock('../src/lib/auth');
jest.mock('../src/lib/database', () => ({
  createRecord: jest.fn(),
}));

describe('createItem handler', () => {
  let req: any;
  let res: any;

  const mockItem = {
    name: 'Test Item',
    category: 'Electronics',
    sku: 'ITEM-001',
  };

  beforeEach(() => {
    req = createMockRequest();
    res = createMockResponse();
    jest.clearAllMocks();
    (authenticate as jest.Mock).mockReturnValue({ isAuthenticated: true });
  });

  it('should return 201 with valid data', async () => {
    req.body = mockItem;
    (createRecord as jest.Mock).mockResolvedValue({ id: 'item-123', ...mockItem });

    await createItem(req, res);

    expect(res.status).toHaveBeenCalledWith(201);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({
        name: mockItem.name,
        category: mockItem.category,
      }),
    );
  });

  it('should return 401 if not authenticated', async () => {
    (authenticate as jest.Mock).mockReturnValue({ isAuthenticated: false });

    await createItem(req, res);

    expect(res.status).toHaveBeenCalledWith(401);
  });

  it('should return 400 for missing required fields', async () => {
    req.body = { name: 'Test' }; // missing category

    await createItem(req, res);

    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({
        error: expect.any(String),
      }),
    );
  });

  it('should return 500 on internal error', async () => {
    req.body = mockItem;
    (createRecord as jest.Mock).mockRejectedValue(new Error('Database error'));

    await createItem(req, res);

    expect(res.status).toHaveBeenCalledWith(500);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({
        error: 'Internal server error',
        details: 'Database error',
      }),
    );
  });
});
```

### React Component Tests

Use React Testing Library - test like a user:

```typescript
import { render, screen, fireEvent } from '@testing-library/react';
import Filters, { FilterCategories } from './Filters';

jest.mock('../PriceFilter/PriceFilter', () => ({
  __esModule: true,
  default: ({ onChange }: { onChange: (value: number | null) => void }) => (
    <div data-testid="price-filter">
      <button onClick={() => onChange(500)}>$500</button>
    </div>
  ),
}));

describe('Filters Component', () => {
  const mockApplyFilters = jest.fn();
  const mockClearFilters = jest.fn();

  const options: FilterCategories = {
    availability: ['In Stock', 'Out of Stock'],
    category: ['Standard', 'Premium'],
    priceRange: { max: 700, min: 100 },
    maxPrice: null,
  };

  beforeEach(() => {
    jest.clearAllMocks();
  });

  test('renders correctly with initial filters', () => {
    render(<Filters applyFilters={mockApplyFilters} clearFilters={mockClearFilters} options={options} currentFilters={options} />);

    expect(screen.getByText('Clear all')).toBeInTheDocument();
    expect(screen.getByText('Availability')).toBeInTheDocument();
    expect(screen.getByText('Category')).toBeInTheDocument();
  });

  test('handles applying filters correctly', () => {
    render(<Filters applyFilters={mockApplyFilters} clearFilters={mockClearFilters} options={options} currentFilters={options} />);

    fireEvent.click(screen.getByText('$500'));
    fireEvent.click(screen.getByText('Apply Filters'));

    expect(mockApplyFilters).toHaveBeenCalledWith(expect.objectContaining({ maxPrice: 500 }));
  });

  test('handles checkbox interactions', () => {
    render(<Filters applyFilters={mockApplyFilters} clearFilters={mockClearFilters} options={options} currentFilters={options} />);

    const checkbox = screen.getByLabelText('Standard');
    fireEvent.click(checkbox);

    expect(checkbox).toBeChecked();
  });
});
```

### Query Priority (React Testing Library)

Use queries in this order (most to least preferred):

1. `getByRole` - accessible queries
2. `getByLabelText` - form elements
3. `getByText` - visible text
4. `getByTestId` - last resort

### Hook Tests

```typescript
import { renderHook, act } from '@testing-library/react';
import { useCustomHook } from './useCustomHook';

describe('useCustomHook', () => {
  test('returns initial state', () => {
    const { result } = renderHook(() => useCustomHook());

    expect(result.current.value).toBe(0);
  });

  test('updates state on action', () => {
    const { result } = renderHook(() => useCustomHook());

    act(() => {
      result.current.increment();
    });

    expect(result.current.value).toBe(1);
  });
});
```

### Utility Function Tests

```typescript
import { parsePrice } from './parsePrice';

describe('parsePrice', () => {
  it('should parse valid price string', () => {
    expect(parsePrice('$250,000')).toBe(250000);
  });

  it('should handle null input', () => {
    expect(parsePrice(null)).toBeNull();
  });

  it('should handle undefined input', () => {
    expect(parsePrice(undefined)).toBeNull();
  });

  it('should handle edge cases', () => {
    expect(parsePrice('0')).toBe(0);
    expect(parsePrice('')).toBeNull();
  });
});
```

## Test Utilities (testUtils.ts)

For API handlers, create a `testUtils.ts` in the `/test` folder:

```typescript
export const createMockRequest = (
  options: {
    query?: Record<string, string>;
    params?: Record<string, string>;
    headers?: Record<string, string>;
    method?: string;
    body?: any;
  } = {},
) => ({
  method: options.method || 'GET',
  url: 'http://localhost:3000/test',
  headers: options.headers || { authorization: 'Bearer test-token' },
  query: options.query || {},
  params: options.params || {},
  body: options.body || {},
});

export const createMockResponse = () => {
  const res: any = {};
  res.status = jest.fn().mockReturnValue(res);
  res.json = jest.fn().mockReturnValue(res);
  res.send = jest.fn().mockReturnValue(res);
  return res;
};

// Reusable mock data factories
export const mockItem = {
  id: 'item-1',
  name: 'Test Item',
  category: 'Electronics',
  price: 29999,
  createdAt: new Date().toISOString(),
  updatedAt: new Date().toISOString(),
};
```

## Test Data

### Use Realistic Data

```typescript
// Bad
const item = { name: 'foo', category: 'bar' };

// Good
const item = {
  name: 'Wireless Headphones',
  category: 'Electronics',
  sku: 'ITEM-001',
};
```

### Mock Data Objects

Define mock data close to tests or in testUtils:

```typescript
const mockProduct = {
  id: 'prod-123',
  name: 'Test Product',
  category: 'Electronics',
  sku: 'PROD-001',
};

const mockOrder = {
  id: 'order-456',
  status: 'pending',
  total: 9999,
  items: [mockProduct],
};
```

## Error Testing

Always test failure paths:

```typescript
describe('Handler', () => {
  it('should return 500 when external service fails', async () => {
    req.body = mockProduct;
    (externalService as jest.Mock).mockRejectedValue(new Error('Service unavailable'));

    await handler(req, res);

    expect(res.status).toHaveBeenCalledWith(500);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({
        error: 'Internal server error',
        details: 'Service unavailable',
      }),
    );
  });

  it('should return 400 for validation errors', async () => {
    req.body = { invalidField: 'value' };

    await handler(req, res);

    expect(res.status).toHaveBeenCalledWith(400);
  });

  it('should throw for invalid input', async () => {
    await expect(validateInput(null)).rejects.toThrow('Input required');
  });
});
```

## What NOT to Test

- **Implementation details** - Private methods, internal state
- **Framework code** - React's useState, Express routing internals
- **Third-party libraries** - Trust they work
- **Trivial code** - Simple getters, pass-through functions
- **Type transformations** - TypeScript handles these

## Running Tests

```bash
# All tests
npm run test

# Specific file
npm run test -- path/to/file.test.ts

# Watch mode
npm run test -- --watch

# With coverage
npm run test -- --coverage
```

## Anti-Patterns to Avoid

| Anti-Pattern               | Problem                    | Instead                     |
| -------------------------- | -------------------------- | --------------------------- |
| Testing implementation     | Breaks on refactor         | Test behavior and outputs   |
| Snapshot everything        | Brittle, meaningless diffs | Assert on specific values   |
| One giant test             | Hard to diagnose failures  | One behavior per test       |
| Shared mutable state       | Flaky tests                | Fresh setup with beforeEach |
| `test.only` committed      | Skips other tests          | CI should catch this        |
| Testing CSS classes        | Brittle                    | Test visible behavior       |
| Missing jest.clearAllMocks | Test contamination         | Always clear in beforeEach  |

## Checklist

When writing tests, ensure:

- [ ] Mocks at module level (before describe)
- [ ] `jest.clearAllMocks()` in beforeEach
- [ ] Test happy path
- [ ] Test error cases (400, 401, 500 for APIs)
- [ ] Test edge cases (null, undefined, empty)
- [ ] Descriptive test names
- [ ] Tests pass: `npm run test`
