"use strict";

const { FakeTimers, assert } = require("./helpers/setup-tests");

const describe =
    typeof setImmediate === "undefined"
        ? global.describe
        : global.describe.skip;
describe("issue #sinonjs/2086 - don't install setImmediate in unsupported environment", function () {
    let clock;

    it("should not install setImmediate", function () {
        clock = FakeTimers.install();

        assert.isUndefined(global.setImmediate);
    });

    afterEach(function () {
        clock.uninstall();
    });
});
