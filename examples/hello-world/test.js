const privateModule = require('private-module')
const expect = require('chai').expect;

describe('test.js', () => {
  it('say hello world', (done) => {
    expect("hello world").to.equal(privateModule.hello())
  });
});
