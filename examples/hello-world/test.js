const privateModule = require('private-module')
const should = require('chai').should();

describe('test.js', () => {
  it('say hello world', (done) => {
    expect("hello world").to.equal(privateModule.hello())
  });
});
