// label :
//    statement

// Syntax of switch...case in JS or C
// If we do not use break, all statements
// after the matching label are executed.
var expr = 'Baz';
switch (expr) {
  case 'Foo':
    console.log('foo');
    break;
  case 'Bar':
  case 'Baz':
    console.log('The letter B');
    break;
  default:
    console.log('Monkey');
}

// 

[3, 4, 5, 6].indexOf(5); // 2
[3, 4, 5, 6].indexOf(4); // 1
[3, 4, 5, 6].indexOf(3); // 0 is falsy in JS
[3, 4, 5, 6].indexOf(99); // -1

if ([3, 4, 5, 6].indexOf(4)) { // 1 => truthy
  console.log("number is in array")
} else {
  console.log("number is NOT in array")
} // number is in array

if ([3, 4, 5, 6].indexOf(3)) { // 0 => falsy
  console.log("number is in array")
} else {
  console.log("number is NOT in array")
} // number is NOT in array :scream:

if ([3, 4, 5, 6].indexOf(99)) { // -1 => truthy
  console.log("number is in array")
} else {
  console.log("number is NOT in array")
} // number is in array :scream:


if ([3, 4, 5, 6].indexOf(99) === -1) { // => true
  console.log("number is NOT in array")
} else {
  console.log("number is in array")
} // number is NOT in array


~[3, 4, 5, 6].indexOf(5); // -3
~[3, 4, 5, 6].indexOf(4); // -2
~[3, 4, 5, 6].indexOf(3); // -1
~[3, 4, 5, 6].indexOf(99); // 0 is falsy in JS :tada:

if (~[3, 4, 5, 6].indexOf(4)) { // -2 => truthy
  console.log("number is in array")
} else {
  console.log("number is NOT in array")
} // number is in array

if (~[3, 4, 5, 6].indexOf(3)) { // -1 => truthy
  console.log("number is in array")
} else {
  console.log("number is NOT in array")
} // number is in array :tada:

if (~[3, 4, 5, 6].indexOf(99)) { // 0 => falsy
  console.log("number is in array")
} else {
  console.log("number is NOT in array")
} // number is NOT in array :tada:

