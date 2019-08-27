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
