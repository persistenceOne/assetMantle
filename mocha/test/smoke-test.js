// "use strict";

// // require assert

// var assert = require('assert');

// // require the HelloWorld factory module

// const helloFactory = require('../src');

// describe('smoke test', () => {
//   it('should pass if mocha is working', done => {
//     done();
//   });
//   context('createHelloWorld', () => {
//     // factory method
//     it('should return an object that is not null', done => {
//       var hello = helloFactory.createHelloWorld();
//       assert.ok(hello, 'factory result should not be null');
//       done();
//     });
//   });
//   context('HelloWorld', () => {
//     context('greeting property', () => {
//       it('should have a greeting property', done => {
//         var hello = helloFactory.createHelloWorld();
//         assert.ok(hello.greeting,
//           'HelloWorld object should have a greeting property');
//         done();
//       });
//       it('should return default greeting if not set', done => {
//         var hello = helloFactory.createHelloWorld();
//         assert.equal(hello.greeting, 'Hello World!',
//           'HelloWorld greeting should be default if not set');
//         done();
//       });
//       it('should return set value', done => {
//         const TEST_GREETING = 'Yo World!'
//         var hello = helloFactory.createHelloWorld();
//         hello.greeting = TEST_GREETING;
//         assert.equal(hello.greeting, TEST_GREETING,
//           'HelloWorld greeting should return constructor greeting');
//         done();
//       });
//       it('should return constructor greeting if set', done => {
//         const TEST_GREETING = 'Yo World!'
//         const options = { greeting: TEST_GREETING };
//         var hello = helloFactory.createHelloWorld(options);
//         assert.equal(hello.greeting, TEST_GREETING,
//           'HelloWorld greeting should return constructor greeting');
//         done();
//       });
//     });
//     context('greet method', () => {
//       it('should have a greet method', done => {
//         var hello = helloFactory.createHelloWorld();
//         assert.ok(hello.greet,
//           'HelloWorld object should have a greet method');
//         done();
//       });
//       it('should be able to call greet method', done => {
//         var hello = helloFactory.createHelloWorld();
//         hello.greet();
//         done();
//       });
//       it('should be able to call greet method with new greeting', done => {
//         var hello = helloFactory.createHelloWorld();
//         hello.greeting = 'Yo World!';
//         hello.greet();
//         done();
//       });
//     });
//   });
// });