## First, a bit of terminology confusion

The bulk of the Arweave tests are written using the [eunit testing framework](https://www.erlang.org/doc/apps/eunit/chapter.html). However **most** of the tests are not true Unit Tests - in fact most are closer to full integration tests (they launch and interact with fully running Arweave nodes). This terminology issue regularly causes frustration and confusion when engineers first encounter the codebse. It is probably best to just consider them integration tests that run within the eunit framework.

## Next, a bit of test methodology debate

Broadly speaking there are 4 types of automated tests:

1. **Unit Tests**: tests which attempt to limit the scope of the code under test as much as possible. These tests often use mocking and dependency injection to limit the amount of dependent code that is invoked while running the test. In their purest form a unit test might test the inputs and outputs of a single function - but larger “units” (e.g. all the functions in a specific module or process) are common.
2. **Integration Tests**: tests which expand the scope of code under test to include multiple interacting units. These tests might also use mocking and dependency injection to restrict which dependent modules are pulled in, but they are explicitly looking to test the behavior of an integrated set of units. The scope of an integration test can include the fully loaded application.
3. **End-to-end Tests:** like integration tests, the scope of end-to-end tests includes the full application stack. What differentiates end-to-end tests from integration tests is often the configuration used: end-to-end tests aim to replicate a real-world or production configuration as much as is possible, while integration tests might limit certain parameters in the interest of improving test performance.
4. **Production Tests**: tests run against the live, Arweave mainnet. These tests make and post real transactions, mine real blocks, and query real data.

Each type of test has its own benefits and shortcomings. The arweave repo has tests of all types and generally it is left to individual engineers to decide what type of test is most helpful for their work.

It is helpful for all engineers to be familiar with the existing test suite - in particular the set of integration test utilities defined in [`ar_test_node`](https://github.com/ArweaveTeam/arweave/blob/master/apps/arweave/test/ar_test_node.erl). There have been attempts in the past to move the test suite off of `eunit`. Either to replace the integration tests with smaller-scoped unit test equivalents or to simply move the integration tests out of the `eunit` framework into a more integration-friendly framework. However to date all of those attempts have eventually fizzled when it came to reproducing the valuable functionality provided by [`ar_test_node`](https://github.com/ArweaveTeam/arweave/blob/master/apps/arweave/test/ar_test_node.erl). Arweave is a complex beast and testing it deterministically can be hard - [`ar_test_node`](https://github.com/ArweaveTeam/arweave/blob/master/apps/arweave/test/ar_test_node.erl) provides a lot of very helpful utilities (e.g. run a node and have it mine a single block, have 2 nodes gossip a single transection, etc…).

Currently @humaite has taken a new, promising approach: he has introduced [Common Test](https://www.erlang.org/doc/apps/common_test/introduction.html) not as a replacement for our existing tests, but as a framework for testing a new erlang app he is adding (the [`arweave_config`](https://github.com/ArweaveTeam/arweave/tree/master/apps/arweave_config) app). As this is a modular entity separate from the core [`arweave`](https://github.com/ArweaveTeam/arweave/tree/master/apps/arweave) app, it is provides a great opportunity for applying a new testing paradigm without having to replicate the functionality of the existing test suite.

As you familiarize yourself with the `eunit` test suite we expect you will have great ideas on how to improve it. This is welcomed and encouraged! We ask only that you spend some time to understand the strengths and weaknesses of the existing suite first as this will help avoid another aborted rewrite.

## Finally, the tests

To run the unit/integration test suite: `./bin/start test`

Of note: the full test run will take a while and, unfortunately, there are several flaky tests, so you may need to run it a few times to get everything to pass. The flakiness and long-runtime of integration tests are two of their biggest shortcomings - however the coverage we get from some of those flaky tests is important for preventing regressions in some critical and hard to manually tests code paths. Addressing the flakiness is a constant priority.

In general engineers will rely on the Github actions that run on PRs to confirm a code change passes the full body of tests. Locally engineers often run a subset of the testsuite as part of their iterative development cycle.

You can run also run a single module of tests: `./bin/start test MODULE_NAME`
