# File: priv/repo/seeds_topics.exs
# Run with: mix run priv/repo/seeds_topics.exs

alias Discuss.Content

topics_data = [
  %{
    title: "Building a Real-Time Chat Application with Phoenix Channels",
    body: """
    # Building a Real-Time Chat Application with Phoenix Channels

    Phoenix Channels provide a powerful way to handle real-time features in your Elixir applications. In this discussion, I'd like to explore approaches to building a chat application that scales well.

    ## The Basics of Phoenix Channels

    Phoenix Channels are based on a simple abstraction: processes communicate over named channels. The implementation gives us several key benefits:

    - **Soft-realtime communication**
    - **Presence tracking** for users
    - **Highly scalable** architecture leveraging the BEAM

    ## A Simple Implementation

    ```elixir
    defmodule MyAppWeb.ChatChannel do
      use Phoenix.Channel

      def join("room:lobby", _message, socket) do
        {:ok, socket}
      end

      def join("room:" <> _private_room_id, _params, _socket) do
        {:error, %{reason: "unauthorized"}}
      end

      def handle_in("new_msg", %{"body" => body}, socket) do
        broadcast!(socket, "new_msg", %{body: body})
        {:noreply, socket}
      end
    end
    ```

    ## Advanced Features to Consider

    1. **Message persistence** - Store messages in the database for history
    2. **Distributed nodes** - How will channels work across multiple servers?
    3. **Presence synchronization** - Keeping track of who's online
    4. **Rate limiting** - Preventing abuse of your real-time system

    ## Discussion Questions

    - What experiences have you had with Phoenix Channels or similar real-time technologies?
    - How would you handle message persistence in a chat application?
    - What strategies would you employ for scaling to 100,000+ simultaneous users?
    - How would you implement features like read receipts or typing indicators?
    """
  },
  %{
    title: "Best Practices for API Design in 2024",
    body: """
    # Best Practices for API Design in 2024

    Designing clean, intuitive APIs is crucial for developer experience and long-term maintainability. Let's explore modern best practices for REST API design.

    ## RESTful Principles

    - **Use HTTP verbs properly** - GET for reading, POST for creating, PUT/PATCH for updating, DELETE for removing
    - **Resource-based URLs** - `/users/123` instead of `/getUser?id=123`
    - **Stateless operations** - Each request should contain all necessary information
    - **Consistent naming conventions** - Use plural nouns for collections

    ## Response Structure

    ```json
    {
      "data": {
        "id": 1,
        "type": "user",
        "attributes": {
          "name": "John Doe",
          "email": "john@example.com"
        }
      },
      "meta": {
        "pagination": {
          "page": 1,
          "per_page": 20,
          "total": 100
        }
      }
    }
    ```

    ## Error Handling

    Always return meaningful error responses:

    ```json
    {
      "error": {
        "code": "VALIDATION_FAILED",
        "message": "The provided data is invalid",
        "details": [
          {
            "field": "email",
            "message": "Email format is invalid"
          }
        ]
      }
    }
    ```

    ## Discussion Questions

    - What API design patterns have worked best for your projects?
    - How do you handle versioning in your APIs?
    - What tools do you use for API documentation and testing?
    - How do you balance flexibility with simplicity in your API design?
    """
  },
  %{
    title: "Understanding Functional Programming Concepts",
    body: """
    # Understanding Functional Programming Concepts

    Functional programming offers a different approach to solving problems, emphasizing immutability, pure functions, and declarative code. Let's explore core concepts.

    ## Pure Functions

    Functions that always return the same output for the same input and have no side effects:

    ```elixir
    # Pure function
    def add(a, b), do: a + b

    # Impure function (has side effects)
    def log_and_add(a, b) do
      IO.puts("Adding numbers")  # Side effect
      a + b
    end
    ```

    ## Immutability

    Data structures that cannot be changed after creation:

    ```elixir
    list = [1, 2, 3]
    new_list = [0 | list]  # Creates new list, original unchanged
    ```

    ## Higher-Order Functions

    Functions that take other functions as arguments or return functions:

    ```elixir
    numbers = [1, 2, 3, 4, 5]
    squared = Enum.map(numbers, &(&1 * &1))
    evens = Enum.filter(numbers, &(rem(&1, 2) == 0))
    ```

    ## Discussion Questions

    - How has functional programming changed your approach to problem-solving?
    - What are the biggest challenges when learning functional programming?
    - How do you explain immutability to developers new to FP?
    - What functional programming concepts do you find most useful in everyday coding?
    """
  },
  %{
    title: "Database Optimization Strategies for Web Applications",
    body: """
    # Database Optimization Strategies for Web Applications

    Database performance is often the bottleneck in web applications. Let's discuss strategies for keeping your database running smoothly.

    ## Indexing Strategies

    Proper indexing can dramatically improve query performance:

    ```sql
    -- Single column index
    CREATE INDEX idx_users_email ON users(email);

    -- Composite index
    CREATE INDEX idx_orders_user_date ON orders(user_id, created_at);

    -- Partial index
    CREATE INDEX idx_active_users ON users(id) WHERE active = true;
    ```

    ## Query Optimization

    ```sql
    -- Bad: N+1 query problem
    SELECT * FROM posts;
    -- Then for each post:
    SELECT * FROM comments WHERE post_id = ?;

    -- Good: Join or eager loading
    SELECT p.*, c.*
    FROM posts p
    LEFT JOIN comments c ON p.id = c.post_id;
    ```

    ## Connection Pooling

    ```elixir
    # In config/config.exs
    config :my_app, MyApp.Repo,
      pool_size: 10,
      queue_target: 50,
      queue_interval: 1000
    ```

    ## Discussion Questions

    - What database optimization techniques have had the biggest impact in your projects?
    - How do you identify and debug slow queries?
    - What's your approach to database migrations in production?
    - How do you balance normalization with performance needs?
    """
  },
  %{
    title: "Building Robust Error Handling in Web Applications",
    body: """
    # Building Robust Error Handling in Web Applications

    Good error handling can make the difference between a frustrating user experience and a resilient application. Let's explore strategies for handling errors gracefully.

    ## Error Classification

    **User Errors**
    - Invalid input
    - Authentication failures
    - Permission denied

    **System Errors**
    - Database connectivity issues
    - Third-party service failures
    - Resource exhaustion

    ## Phoenix Error Handling

    ```elixir
    defmodule MyAppWeb.ErrorView do
      use MyAppWeb, :view

      def render("404.json", _assigns) do
        %{error: %{message: "Resource not found", code: 404}}
      end

      def render("500.json", _assigns) do
        %{error: %{message: "Internal server error", code: 500}}
      end
    end
    ```

    ## Try-Catch vs Pattern Matching

    ```elixir
    # Pattern matching approach (preferred in Elixir)
    case MyApp.Content.create_post(attrs) do
      {:ok, post} ->
        json(conn, %{data: post})
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: changeset_errors(changeset)})
    end
    ```

    ## Discussion Questions

    - How do you structure error handling in your applications?
    - What's your approach to logging and monitoring errors?
    - How do you balance detailed error information with security concerns?
    - What error handling patterns have you found most effective?
    """
  },

  %{
    title: "Database Indexing Strategies for Performance Optimization",
    body: """
    # Database Indexing Strategies for Performance Optimization

    Proper database indexing is one of the most powerful performance optimization techniques available. Let's explore how to use indexes effectively to speed up your queries while avoiding common pitfalls.

    ## Indexing Fundamentals

    At its core, an index is a data structure that improves the speed of data retrieval operations at the cost of additional storage and maintenance overhead.

    ### How Indexes Work

    Conceptually, an index works like a book's index:

    - Maintains a sorted list of values
    - Maps each value to its location in the table
    - Allows the database to find data without scanning the entire table

    ## Types of Indexes

    Common index types and their use cases:

    ### B-tree Indexes

    The most common general-purpose index:

    ```sql
    -- Standard B-tree index
    CREATE INDEX idx_users_email ON users(email);
    ```

    Good for:
    - Equality comparisons (`=`)
    - Range queries (`>`, `<`, `BETWEEN`)
    - `ORDER BY` operations
    - Prefix searches (`LIKE 'abc%'`)

    ### Unique Indexes

    Ensure column values are unique:

    ```sql
    -- Unique index
    CREATE UNIQUE INDEX idx_users_email ON users(email);
    ```

    ### Composite Indexes

    Index multiple columns together:

    ```sql
    -- Composite index
    CREATE INDEX idx_users_name_email ON users(last_name, first_name, email);
    ```

    **Column order matters!** This index is useful for:
    - Queries filtering on `last_name`
    - Queries filtering on `last_name` AND `first_name`
    - Queries filtering on all three columns

    But not particularly useful for:
    - Queries filtering only on `first_name` or `email`

    ### Partial Indexes

    Index only a subset of rows:

    ```sql
    -- Partial index
    CREATE INDEX idx_active_users ON users(email) WHERE status = 'active';
    ```

    Great for tables where queries often filter on the same condition.

    ### Expression Indexes

    Index the result of expressions:

    ```sql
    -- Expression index
    CREATE INDEX idx_users_lower_email ON users(LOWER(email));
    ```

    Use with queries like:
    ```sql
    SELECT * FROM users WHERE LOWER(email) = 'user@example.com';
    ```

    ## PostgreSQL Specialized Indexes

    PostgreSQL offers several specialized index types:

    ### GIN (Generalized Inverted Index)

    ```sql
    -- GIN index for JSON
    CREATE INDEX idx_data_json ON documents USING GIN (data);

    -- GIN index for array
    CREATE INDEX idx_tags ON posts USING GIN (tags);
    ```

    Good for:
    - Full-text search
    - JSON data
    - Array columns

    ### GiST (Generalized Search Tree)

    ```sql
    -- GiST index for geometric data
    CREATE INDEX idx_locations ON stores USING GIST (location);
    ```

    Good for:
    - Geometric data
    - Full-text search
    - Custom data types

    ## Index Strategies for Common Query Patterns

    ### Optimizing JOIN Operations

    ```sql
    -- Index foreign keys
    CREATE INDEX idx_comments_post_id ON comments(post_id);
    ```

    ### Optimizing ORDER BY

    ```sql
    -- Index for sorting
    CREATE INDEX idx_posts_created_at ON posts(created_at DESC);
    ```

    ### Optimizing GROUP BY

    ```sql
    -- Index for grouping
    CREATE INDEX idx_orders_customer_id ON orders(customer_id);
    ```

    ## Indexing Anti-Patterns

    Common mistakes to avoid:

    1. **Over-indexing** - Don't create indexes you don't need
    2. **Under-indexing** - Missing indexes on frequently queried columns
    3. **Not indexing foreign keys** - Slows down JOIN operations
    4. **Creating redundant indexes** - Wastes space and slows updates
    5. **Using function-based queries without matching indexes**

    ## Analyzing Index Usage

    Tools to help you optimize indexing:

    ### EXPLAIN in PostgreSQL

    ```sql
    EXPLAIN ANALYZE
    SELECT * FROM users
    WHERE email = 'user@example.com';
    ```

    Output will show:
    - Whether indexes are being used
    - Estimated and actual execution time
    - Number of rows scanned

    ### Finding Unused Indexes

    ```sql
    SELECT
      indexrelid::regclass AS index,
      relid::regclass AS table,
      idx_scan AS scans
    FROM pg_stat_user_indexes
    ORDER BY idx_scan ASC;
    ```

    ## Practical Guidelines

    Rules of thumb for indexing:

    1. **Index columns used in WHERE clauses**
    2. **Index columns used in JOIN conditions**
    3. **Index columns used in ORDER BY and GROUP BY**
    4. **Consider the selectivity of the column**
    5. **Balance read performance against write overhead**
    6. **Monitor and adjust based on actual query patterns**

    ## Discussion Questions

    - What indexing strategies have given you the biggest performance improvements?
    - How do you decide when to add or remove indexes?
    - What tools do you use to identify missing or ineffective indexes?
    - How do you balance index maintenance overhead with query performance?
    """
  },
  %{
    title: "Advanced Git Workflows for Team Collaboration",
    body: """
    # Advanced Git Workflows for Team Collaboration

    Effective Git workflows are essential for team productivity. Let's explore various Git workflow strategies and advanced techniques that can enhance collaboration.

    ## Common Git Workflows

    ### Centralized Workflow

    Simplest approach, similar to SVN:

    ```
    main
    ↑ ↓
    Developers
    ```

    - Single `main` branch
    - All developers commit directly to `main`
    - Simple but prone to conflicts

    ### Feature Branch Workflow

    ```
    main
     ↑↓
    feature/login → feature/dashboard → feature/settings
    ```

    - `main` branch remains stable
    - Each feature developed in dedicated branch
    - Features merged back to `main` when complete

    ### Gitflow Workflow

    ```
    develop → feature/a → feature/b
      ↓
    release
      ↓
    main → hotfix
    ```

    - `main` contains production code
    - `develop` is integration branch
    - Feature branches come from `develop`
    - Release branches prepare for production
    - Hotfix branches fix production issues

    ### Trunk-Based Development

    ```
    main
     ↑↓
    short-lived feature branches
    ```

    - Frequent, small commits to `main`
    - Short-lived feature branches (1-2 days)
    - Heavy use of feature flags
    - Requires strong testing culture

    ## Advanced Git Techniques

    ### Interactive Rebasing

    Clean up your commits before sharing:

    ```bash
    git rebase -i HEAD~5
    ```

    This opens an editor where you can:
    - Reorder commits
    - Squash multiple commits
    - Edit commit messages
    - Split commits

    ### Cherry-picking

    Apply specific commits to another branch:

    ```bash
    git cherry-pick abc123
    ```

    Useful for:
    - Applying hotfixes to multiple branches
    - Pulling specific features into a release

    ### Bisecting

    Find which commit introduced a bug:

    ```bash
    git bisect start
    git bisect bad  # Current commit is bad
    git bisect good v1.0.0  # This version was good

    # Git will checkout commits for you to test
    # After testing, mark each as good or bad
    git bisect good  # or git bisect bad

    # Eventually git will identify the first bad commit
    ```

    ### Reflog

    Recover lost commits or branches:

    ```bash
    git reflog
    # Find the lost commit hash, then
    git checkout -b recovered-branch abc123
    ```

    ## Effective Pull Requests

    Best practices for PRs:

    1. **Keep them small** - Easier to review and merge
    2. **Clear descriptions** - Explain the what and why
    3. **Link to issues** - Connect code to requirements
    4. **Include tests** - Verify functionality
    5. **Respond to feedback** - Be open to improvements

    Example PR template:

    ```markdown
    ## Description
    Brief description of changes

    ## Related Issues
    Fixes #123

    ## Type of Change
    - [ ] Bug fix
    - [ ] New feature
    - [ ] Breaking change
    - [ ] Documentation update

    ## How Has This Been Tested?
    Describe test cases

    ## Checklist
    - [ ] Code follows style guidelines
    - [ ] Tests added for new functionality
    - [ ] Documentation updated
    - [ ] Changes don't break existing functionality
    ```

    ## Git Hooks

    Automate checks and processes:

    ### Pre-commit Hook Example

    ```bash
    #!/bin/sh
    # .git/hooks/pre-commit

    # Run linter on staged files
    STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.js$')

    if [ "$STAGED_FILES" = "" ]; then
      exit 0
    fi

    echo "Running linter..."
    eslint $STAGED_FILES

    if [ $? -ne 0 ]; then
      echo "Linting failed! Fix errors before committing."
      exit 1
    fi
    ```

    ### Using Husky for Team-wide Hooks

    ```json
    // package.json
    {
      "husky": {
        "hooks": {
          "pre-commit": "lint-staged",
          "pre-push": "npm test"
        }
      },
      "lint-staged": {
        "*.js": ["eslint --fix", "prettier --write"]
      }
    }
    ```

    ## Advanced Branching Strategies

    ### Release Trains

    ```
    main
     ↓
    release/2023-06 → hotfix/critical-bug
     ↓
    release/2023-07
    ```

    - Regular release schedule
    - Features that miss a train catch the next one
    - Parallel maintenance of multiple releases

    ### Environment Branches

    ```
    main → staging → production
    ```

    - Each environment has a dedicated branch
    - Changes flow from less stable to more stable
    - Easy to see what's deployed where

    ## Monorepo Strategies

    For repositories containing multiple projects:

    ### Selective Checkout

    ```bash
    # Sparse checkout only what you need
    git clone --filter=blob:none --sparse https://github.com/org/monorepo
    cd monorepo
    git sparse-checkout init --cone
    git sparse-checkout set project1 project2
    ```

    ### Splitting Commits

    ```bash
    # For commits affecting multiple projects
    git add project1/
    git commit -m "Project 1 changes"

    git add project2/
    git commit -m "Project 2 changes"
    ```

    ## Discussion Questions

    - Which Git workflow has worked best for your team and why?
    - How do you handle conflicts in your workflow?
    - What Git-related tools have improved your team's productivity?
    - How do you onboard new team members to your Git workflow?
    """
  },
  %{
    title: "Scaling Web Applications: From Zero to Millions of Users",
    body: """
    # Scaling Web Applications: From Zero to Millions of Users

    Scaling a web application to handle growth is a multifaceted challenge. Let's explore strategies and architectural patterns for scaling from a single server to a robust system serving millions of users.

    ## The Scaling Journey

    ### Stage 1: Single Server (0-10K users)

    ```
    Users → Nginx → Application → Database
               ↓
             Static
             Assets
    ```

    **Optimizations at this stage:**
    - Efficient database queries
    - Application-level caching
    - Proper indexing
    - HTTP caching headers
    - CDN for static assets

    ### Stage 2: Separate Database (10K-100K users)

    ```
    Users → Nginx → Application Servers
               ↓           ↓
             CDN      Database
    ```

    **Key improvements:**
    - Dedicated database server
    - Multiple application instances
    - Load balancing
    - Read replicas for databases

    ### Stage 3: Horizontal Scaling (100K-1M users)

    ```
    Users → CDN → Load Balancer
                      ↓
    ┌─────────────────────────────┐
    │ App Server → App Server → ... │
    └─────────────────────────────┘
              ↓
    ┌─────────────────────────────┐
    │ Primary DB → Read Replica → ... │
    └─────────────────────────────┘
              ↓
    ┌─────────────────────────────┐
    │ Cache → Cache → Cache       │
    └─────────────────────────────┘
    ```

    **Focus areas:**
    - Auto-scaling groups
    - Database sharding
    - Caching layers (Redis/Memcached)
    - Queue systems for async processing
    - Service-oriented architecture

    ### Stage 4: Distributed Systems (1M+ users)

    ```
    Users → Global CDN → Regional Load Balancers
                                ↓
    ┌───────────────────────────────────────┐
    │ Microservices / Serverless Functions  │
    └───────────────────────────────────────┘
                      ↓
    ┌───────────────────────────────────────┐
    │ Distributed Database / Data Services  │
    └───────────────────────────────────────┘
                      ↓
    ┌───────────────────────────────────────┐
    │ Distributed Caching / Message Queues  │
    └───────────────────────────────────────┘
    ```

    **Advanced techniques:**
    - Multi-region deployment
    - Database clustering
    - Event-driven architecture
    - Edge computing
    - Specialized storage solutions

    ## Core Scaling Concepts

    ### Vertical vs. Horizontal Scaling

    **Vertical Scaling (Scaling Up)**
    - Adding more resources to existing servers
    - Simpler to implement
    - Has physical/cost limits
    - Limited fault tolerance

    **Horizontal Scaling (Scaling Out)**
    - Adding more server instances
    - More complex architecture
    - Better fault tolerance
    - More cost-effective at scale

    ### Stateless Architecture

    Key to horizontal scaling:

    ```elixir
    # Stateless request handling
    def handle_request(conn, params) do
      # No reliance on local server state
      user = fetch_user_from_database(params["user_id"])

      # Process based on request data only
      result = perform_operation(user, params)

      # Return response
      json(conn, result)
    end
    ```

    Benefits:
    - Any server can handle any request
    - Easier to scale horizontally
    - Better resilience to server failures

    ### Caching Strategies

    **Client-Side Caching**
    ```
    Cache-Control: max-age=3600, must-revalidate
    ETag: "33a64df551425fcc55e4d42a148795d9f25f89d4"
    ```

    **Application Caching**
    ```elixir
    def get_user(id) do
      case Cachex.get(:user_cache, "user:" <> to_string(id)) do
        {:ok, user} when user != nil ->
          user
        _ ->
          user = Database.get_user(id)
          Cachex.put(:user_cache, "user:" <> to_string(id), user, ttl: :timer.minutes(15))
          user
      end
    end
    ```

    **Database Query Caching**
    ```sql
    CREATE MATERIALIZED VIEW trending_posts AS
    SELECT p.*, COUNT(l.id) as likes
    FROM posts p
    JOIN likes l ON p.id = l.post_id
    WHERE p.created_at > NOW() - INTERVAL '7 days'
    GROUP BY p.id
    ORDER BY likes DESC
    LIMIT 100;

    -- Refresh periodically
    REFRESH MATERIALIZED VIEW trending_posts;
    ```

    ### Database Scaling

    **Read Replicas**
    - Primary handles writes
    - Replicas handle reads
    - Increases read throughput

    **Sharding**
    ```
    ┌──────────┐ ┌──────────┐ ┌──────────┐
    │ Shard 1  │ │ Shard 2  │ │ Shard 3  │
    │ Users A-G│ │ Users H-N│ │ Users O-Z│
    └──────────┘ └──────────┘ └──────────┘
    ```

    **NoSQL Options**
    - Document stores (MongoDB)
    - Key-value stores (DynamoDB)
    - Column-family stores (Cassandra)
    - Graph databases (Neo4j)

    ## Advanced Scaling Techniques

    ### Microservices Architecture

    Breaking monolith into services:

    ```
    ┌────────────┐ ┌────────────┐ ┌────────────┐
    │  User      │ │  Content   │ │  Payment   │
    │  Service   │ │  Service   │ │  Service   │
    └────────────┘ └────────────┘ └────────────┘
           ↓             ↓              ↓
    ┌────────────┐ ┌────────────┐ ┌────────────┐
    │  User DB   │ │ Content DB │ │ Payment DB │
    └────────────┘ └────────────┘ └────────────┘
    ```

    Benefits:
    - Independent scaling
    - Team autonomy
    - Technology diversity
    - Failure isolation

    ### Content Delivery Networks (CDNs)

    ```
    User ──→ Edge Location ──→ Origin Server
      ↑            │
      └────────────┘
    (Cached Response)
    ```

    Benefits:
    - Reduced latency
    - Decreased origin load
    - DDoS protection
    - Global presence

    ### Load Testing

    Tools and techniques:
    - k6, Locust, JMeter for simulation
    - Gradual ramp-up testing
    - Identify bottlenecks before they affect users

    ```javascript
    // k6 load test script
    import http from 'k6/http';
    import { sleep } from 'k6';

    export const options = {
      stages: [
        { duration: '2m', target: 100 }, // Ramp up
        { duration: '5m', target: 100 }, // Stay at peak
        { duration: '2m', target: 0 },   // Ramp down
      ],
    };

    export default function() {
      http.get('https://example.com/api/users');
      sleep(1);
    }
    ```

    ## Discussion Questions

    - What scaling challenges have you encountered in your applications?
    - How do you decide between vertical and horizontal scaling?
    - What caching strategies have been most effective for your use cases?
    - How do you approach database scaling in your architecture?
    """
  },
  %{
    title: "TDD vs. BDD: When to Use Each Approach",
    body: """
    # TDD vs. BDD: When to Use Each Approach

    Test-Driven Development (TDD) and Behavior-Driven Development (BDD) are two popular methodologies for software development. Let's explore their differences, benefits, and when to apply each approach.

    ## Test-Driven Development (TDD)

    TDD follows a simple cycle:

    1. **Red**: Write a failing test
    2. **Green**: Write minimal code to make the test pass
    3. **Refactor**: Clean up the code while keeping tests passing

    ### TDD Example in Elixir

    ```elixir
    # 1. RED: Write a failing test
    defmodule CalculatorTest do
      use ExUnit.Case

      test "add two numbers" do
        assert Calculator.add(2, 3) == 5
      end
    end

    # 2. GREEN: Write minimal implementation
    defmodule Calculator do
      def add(a, b) do
        a + b
      end
    end

    # 3. REFACTOR: Improve code while keeping tests passing
    # (No refactoring needed for this simple example)
    ```

    ### Benefits of TDD

    - Ensures high test coverage
    - Prevents regressions
    - Forces modular, testable design
    - Provides fast feedback loop
    - Acts as documentation of code behavior
    - Reduces debugging time

    ## Behavior-Driven Development (BDD)

    BDD extends TDD by focusing on:

    - Business value and user stories
    - Collaboration between developers, QA, and business stakeholders
    - Using ubiquitous language that all stakeholders understand

    ### BDD Example with Gherkin Syntax

    ```gherkin
    Feature: User authentication
      As a user
      I want to log in to the system
      So that I can access my account

      Scenario: Successful login
        Given I am on the login page
        When I enter "user@example.com" as email
        And I enter "password123" as password
        And I click the login button
        Then I should be redirected to the dashboard
        And I should see a welcome message

      Scenario: Failed login
        Given I am on the login page
        When I enter "user@example.com" as email
        And I enter "wrongpassword" as password
        And I click the login button
        Then I should see an error message
        And I should remain on the login page
    ```

    ### BDD Implementation in Elixir (using Cabbage)

    ```elixir
    defmodule MyApp.AuthenticationFeature do
      use Cabbage.Feature, file: "features/authentication.feature"
      use MyAppWeb.ConnCase

      defgiven ~r/^I am on the login page$/, _vars, state do
        conn = get(state.conn, "/login")
        {:ok, state |> Map.put(:conn, conn)}
      end

      defwhen ~r/^I enter "(?<email>[^"]+)" as email$/, %{email: email}, state do
        {:ok, state |> Map.put(:email, email)}
      end

      defwhen ~r/^I enter "(?<password>[^"]+)" as password$/, %{password: password}, state do
        {:ok, state |> Map.put(:password, password)}
      end

      defwhen ~r/^I click the login button$/, _vars, state do
        conn = post(state.conn, "/session", %{
          "user" => %{"email" => state.email, "password" => state.password}
        })
        {:ok, state |> Map.put(:conn, conn)}
      end

      defthen ~r/^I should be redirected to the dashboard$/, _vars, state do
        assert redirected_to(state.conn) == "/dashboard"
        {:ok, state}
      end

      defthen ~r/^I should see a welcome message$/, _vars, state do
        conn = get(recycle(state.conn), "/dashboard")
        assert html_response(conn, 200) =~ "Welcome"
        {:ok, state}
      end

      # More step definitions for the failed login scenario...
    end
    ```

    ### Benefits of BDD

    - Bridges communication gap between technical and non-technical stakeholders
    - Focuses on business value and user experience
    - Creates living documentation
    - Reduces misunderstandings about requirements
    - Facilitates collaboration and shared understanding
    - Ensures testing from user perspective

    ## Comparing TDD and BDD

    | Aspect | TDD | BDD |
    |--------|-----|-----|
    | Focus | Code correctness | Business value |
    | Language | Technical (code) | Natural language |
    | Scope | Unit tests primarily | Often includes integration/acceptance tests |
    | Audience | Developers | All stakeholders |
    | Testing level | Bottom-up | Top-down |
    | Artifacts | Test code | Feature files + step definitions |

    ## When to Use TDD

    TDD is particularly valuable when:

    - Working on complex algorithms or calculations
    - Building technical libraries or frameworks
    - Working with code that has clear inputs and outputs
    - Refactoring existing code
    - In projects where the technical implementation is challenging
    - When working independently or in small technical teams

    ## When to Use BDD

    BDD shines when:

    - Building user-facing features
    - Working with complex business rules
    - In cross-functional teams with non-technical stakeholders
    - When requirements are unclear or evolving
    - In projects where customer satisfaction is critical
    - When documentation is important

    ## Combining Both Approaches

    Many teams use both approaches complementarily:

    1. **BDD for feature-level acceptance tests**
    2. **TDD for implementation-level unit tests**

    ```
    ┌─────────────────────────────┐
    │ BDD: Feature/Acceptance     │
    │ Tests (high-level)          │
    └─────────────────────────────┘
                 ↓
    ┌─────────────────────────────┐
    │ TDD: Unit/Integration       │
    │ Tests (low-level)           │
    └─────────────────────────────┘
    ```

    ## Discussion Questions

    - Which approach have you found more effective in your projects?
    - How do you balance the overhead of writing tests with development speed?
    - What tools or frameworks have you used for TDD or BDD?
    - How do you get stakeholders involved in the BDD process?
    """
  },
  %{
    title: "Modern CSS Architecture: BEM vs. Utility-First vs. CSS-in-JS",
    body: """
    # Modern CSS Architecture: BEM vs. Utility-First vs. CSS-in-JS

    Choosing the right CSS architecture is crucial for maintainable and scalable web applications. Let's compare three popular approaches and explore their strengths and weaknesses.

    ## BEM (Block Element Modifier)

    BEM is a naming convention that creates a clear, strict structure:

    - **Block**: Standalone entity (e.g., `card`)
    - **Element**: Part of a block (e.g., `card__title`)
    - **Modifier**: Variation of a block or element (e.g., `card--featured`)

    ### BEM Example

    ```html
    <div class="card card--featured">
      <h2 class="card__title">Article Title</h2>
      <p class="card__content">Article content goes here</p>
      <button class="card__button card__button--primary">Read More</button>
    </div>
    ```

    ```css
    /* Block */
    .card {
      border: 1px solid #ddd;
      border-radius: 4px;
      padding: 16px;
    }

    /* Modifier */
    .card--featured {
      border-color: gold;
      box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    }

    /* Elements */
    .card__title {
      font-size: 1.5rem;
      margin-bottom: 8px;
    }

    .card__content {
      color: #333;
      line-height: 1.5;
    }

    .card__button {
      padding: 8px 16px;
      border: none;
      border-radius: 4px;
    }

    /* Element modifier */
    .card__button--primary {
      background-color: #0066cc;
      color: white;
    }
    ```

    ### BEM Advantages

    - Clear relationship between HTML and CSS
    - Prevents style leakage and specificity issues
    - Makes components reusable
    - Works with standard CSS
    - Good for large, complex components

    ### BEM Disadvantages

    - Long class names
    - Can become verbose
    - Requires strict discipline
    - Duplication of properties across components

    ## Utility-First CSS (e.g., Tailwind)

    Utility-first CSS uses small, single-purpose classes:

    ### Tailwind Example

    ```html
    <div class="border border-gray-200 rounded p-4 hover:shadow-md dark:bg-gray-800 dark:border-gray-700">
      <h2 class="text-xl font-bold mb-2 text-gray-800 dark:text-white">Article Title</h2>
      <p class="text-gray-600 leading-relaxed mb-4 dark:text-gray-300">Article content goes here</p>
      <button class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded">Read More</button>
    </div>
    ```

    ### Utility-First Advantages

    - No need to invent class names
    - Reduces context switching between HTML and CSS files
    - Encourages consistency with predefined values
    - Smaller CSS bundle size (especially with PurgeCSS)
    - Fast development once you know the utilities

    ### Utility-First Disadvantages

    - HTML can become cluttered
    - Difficult to make global changes
    - Learning curve for the utility classes
    - Can be harder to understand component structure

    ## CSS-in-JS (e.g., styled-components, Emotion)

    CSS-in-JS colocates styles with JavaScript components:

    ### Styled-Components Example (React)

    ```jsx
    import styled from 'styled-components';

    const Card = styled.div`
      border: 1px solid #ddd;
      border-radius: 4px;
      padding: 16px;

      ${props => props.featured && `
        border-color: gold;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
      `}
    `;

    const CardTitle = styled.h2`
      font-size: 1.5rem;
      margin-bottom: 8px;
    `;

    const CardContent = styled.p`
      color: #333;
      line-height: 1.5;
    `;

    const Button = styled.button`
      padding: 8px 16px;
      border: none;
      border-radius: 4px;
      background-color: ${props => props.primary ? '#0066cc' : '#f0f0f0'};
      color: ${props => props.primary ? 'white' : '#333'};
    `;

    function ArticleCard({ title, content, featured }) {
      return (
        <Card featured={featured}>
          <CardTitle>{title}</CardTitle>
          <CardContent>{content}</CardContent>
          <Button primary>Read More</Button>
        </Card>
      );
    }
    ```

    ### CSS-in-JS Advantages

    - Component-scoped styles (no class name collisions)
    - Full access to JavaScript variables and logic
    - Dynamic styling based on props/state
    - Automatic critical CSS extraction
    - Colocated styles with component logic

    ### CSS-in-JS Disadvantages

    - Runtime performance cost
    - Increased bundle size
    - Requires JavaScript to render styles
    - Steeper learning curve
    - Framework-specific solutions

    ## When to Use Each Approach

    ### Consider BEM When:

    - Working with a traditional server-rendered application
    - Building a design system with complex components
    - Team is familiar with CSS but not JS frameworks
    - Need to support older browsers without additional tools
    - Projects with minimal build steps

    ### Consider Utility-First When:

    - Rapid prototyping or MVP development
    - Want to avoid context switching between files
    - Teams struggle with naming conventions
    - Need consistent design constraints
    - Building primarily static components

    ### Consider CSS-in-JS When:

    - Working with component-based frameworks (React, Vue)
    - Need dynamic styling based on props/state
    - Want strict component encapsulation
    - Building highly interactive applications
    - Team is comfortable with JavaScript

    ## Hybrid Approaches

    Many projects benefit from combining approaches:

    ### BEM + Utilities

    ```html
    <div class="card card--featured flex p-4">
      <div class="card__body flex-1">
        <h2 class="card__title mb-2">Title</h2>
        <p class="card__content text-gray-600">Content</p>
      </div>
    </div>
    ```

    ### CSS Modules + Utilities

    ```jsx
    import styles from './Card.module.css';

    function Card() {
      return (
        <div className={`${styles.card} p-4 flex`}>
          <h2 className={styles.title}>Title</h2>
        </div>
      );
    }
    ```

    ## Discussion Questions

    - Which CSS architecture have you found most maintainable for large projects?
    - How do you balance flexibility and consistency in your CSS approach?
    - What migration strategies have you used when switching between architectures?
    - How has your preferred approach changed as web technologies have evolved?
    """
  },
  %{
    title: "Creating a Robust API Versioning Strategy",
    body: """
    # Creating a Robust API Versioning Strategy

    API versioning is essential for evolving your services while maintaining backward compatibility. Let's explore different strategies and best practices for versioning APIs effectively.

    ## Why Version APIs?

    APIs need versioning to:

    - Make breaking changes without disrupting existing clients
    - Allow clients to migrate at their own pace
    - Provide a clear upgrade path
    - Maintain backward compatibility
    - Communicate changes effectively

    ## Common Versioning Strategies

    ### URL Path Versioning

    ```
    GET /api/v1/users
    GET /api/v2/users
    ```

    **Implementation in Phoenix:**

    ```elixir
    defmodule MyAppWeb.Router do
      use MyAppWeb, :router

      # V1 API routes
      scope "/api/v1", MyAppWeb.V1 do
        pipe_through :api
        resources "/users", UserController
      end

      # V2 API routes
      scope "/api/v2", MyAppWeb.V2 do
        pipe_through :api
        resources "/users", UserController
      end
    end
    ```

    **Pros:**
    - Simple to understand and implement
    - Works with caching
    - Clearly visible in documentation
    - Easy to test in browser/tools

    **Cons:**
    - URL should ideally represent resource, not API version
    - Requires maintaining multiple URL structures
    - Can lead to code duplication

    ### HTTP Header Versioning

    ```
    GET /api/users
    Accept: application/vnd.myapp.v1+json

    GET /api/users
    Accept: application/vnd.myapp.v2+json
    ```

    **Implementation in Phoenix:**

    ```elixir
    defmodule MyAppWeb.VersionPlug do
      def init(opts), do: opts

      def call(conn, _opts) do
        case get_version_from_header(conn) do
          "v1" -> assign(conn, :api_version, :v1)
          "v2" -> assign(conn, :api_version, :v2)
          _ -> assign(conn, :api_version, :v1) # Default to v1
        end
      end

      defp get_version_from_header(conn) do
        with ["application/vnd.myapp." <> version] <- get_req_header(conn, "accept"),
             [version_str | _] <- Regex.run(~r/v\d+/, version) do
          version_str
        else
          _ -> nil
        end
      end
    end

    # In the controller
    def index(conn, params) do
      case conn.assigns.api_version do
        :v1 -> render_v1(conn, params)
        :v2 -> render_v2(conn, params)
      end
    end
    ```

    **Pros:**
    - RESTful - URLs represent resources, not versions
    - Cleaner URLs
    - Easier to manage in load balancers/gateways

    **Cons:**
    - Less visible
    - Harder to test
    - May confuse developers unfamiliar with header-based versioning

    ### Query Parameter Versioning

    ```
    GET /api/users?version=1
    GET /api/users?version=2
    ```

    **Implementation in Phoenix:**

    ```elixir
    defmodule MyAppWeb.UserController do
      use MyAppWeb, :controller

      def index(conn, %{"version" => "1"} = params) do
        # V1 implementation
        users = Accounts.list_users_v1()
        render(conn, "index.v1.json", users: users)
      end

      def index(conn, %{"version" => "2"} = params) do
        # V2 implementation
        users = Accounts.list_users_v2()
        render(conn, "index.v2.json", users: users)
      end

      # Default to V1 if no version specified
      def index(conn, params) do
        index(conn, Map.put(params, "version", "1"))
      end
    end
    ```

    **Pros:**
    - Simple to implement
    - Easy to test
    - Doesn't require special headers

    **Cons:**
    - Pollutes the URL
    - Can conflict with other query parameters
    - Breaks resource caching (same URL, different responses)

    ### Content Negotiation

    ```
    GET /api/users
    Accept: application/json; version=1

    GET /api/users
    Accept: application/json; version=2
    ```

    **Pros:**
    - Standards-compliant HTTP content negotiation
    - Clean URLs

    **Cons:**
    - Complex to implement
    - Not widely adopted
    - Harder to document and test

    ## Handling API Evolution

    ### Breaking vs. Non-Breaking Changes

    **Non-breaking (no version change needed):**
    - Adding new endpoints
    - Adding optional parameters
    - Adding fields to responses
    - New resource types

    **Breaking (requires version change):**
    - Removing/renaming fields
    - Changing field types
    - Changing error codes/formats
    - Changing authentication mechanisms
    - Changing URL structures

    ### Deprecation Strategy

    1. **Announce deprecation with timeline**
    2. **Return deprecation warnings**
    3. **Monitor usage of deprecated features**
    4. **Provide migration guides**
    5. **Set end-of-life dates**

    Example deprecation header:

    ```
    Deprecation: true
    Sunset: Sat, 31 Dec 2023 23:59:59 GMT
    Link: <https://api.example.com/deprecation/v1>; rel="deprecation"
    Warning: 299 - "The 'sort_by' parameter will be removed in v2"
    ```

    ## Code Organization for Versioned APIs

    ### Phoenix-specific Approaches

    **Approach 1: Module Namespacing**

    ```elixir
    # lib/my_app_web/controllers/v1/user_controller.ex
    defmodule MyAppWeb.V1.UserController do
      # V1 implementation
    end

    # lib/my_app_web/controllers/v2/user_controller.ex
    defmodule MyAppWeb.V2.UserController do
      # V2 implementation
    end
    ```

    **Approach 2: View Versioning**

    ```elixir
    # A single controller with multiple views
    defmodule MyAppWeb.UserController do
      use MyAppWeb, :controller

      def index(conn, params) do
        users = Accounts.list_users()
        version = get_version(conn)
        render(conn, "index." <> version <> ".json", users: users)
      end
    end
    ```

    **Approach 3: Business Logic Versioning**

    ```elixir
    defmodule MyApp.Accounts do
      def list_users(version \\ :v1) do
        case version do
          :v1 -> list_users_v1()
          :v2 -> list_users_v2()
        end
      end

      defp list_users_v1 do
        # V1 implementation
      end

      defp list_users_v2 do
        # V2 implementation
      end
    end
    ```

    ## Best Practices

    1. **Default to the latest stable version**
    2. **Document all available versions**
    3. **Clearly communicate breaking changes**
    4. **Use semantic versioning principles**
    5. **Automate testing across versions**
    6. **Limit the number of active versions**
    7. **Provide migration tools when possible**

    ## Discussion Questions

    - What versioning strategy have you found most effective for your APIs?
    - How do you handle backward compatibility when making significant changes?
    - What tooling has helped you manage API versions?
    - How do you communicate API changes to your consumers?
    """
  }
]

IO.puts("Starting to seed topics...")

Enum.each(topics_data, fn topic_attrs ->
  case Content.create_topic(topic_attrs) do
    {:ok, topic} ->
      IO.puts("✓ Created topic: #{topic.title}")
    {:error, changeset} ->
      IO.puts("✗ Failed to create topic: #{topic_attrs.title}")
      IO.inspect(changeset.errors)
  end
end)

IO.puts("Finished seeding #{length(topics_data)} topics!")
