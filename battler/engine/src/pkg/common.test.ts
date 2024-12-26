import {Choice, Result} from './common';

test('Choice.decode', () => {
  expect(Choice.decode(0b0001_0001)).toEqual(Choice.move(4));
  expect(Choice.decode(0b0001_0110)).toEqual(Choice.switch(5));
});

test('Choice.encode', () => {
  expect(Choice.encode()).toBe(Choice.encode(Choice.pass));
  expect(Choice.encode(Choice.move(4))).toBe(0b0001_0001);
  expect(Choice.encode(Choice.switch(5))).toBe(0b0001_0110);
});

test('Choice.parse', () => {
  expect(() => Choice.parse('foo')).toThrow('Invalid choice');
  expect(Choice.parse('pass')).toEqual(Choice.pass);
  expect(() => Choice.parse('pass 2')).toThrow('Invalid choice');
  expect(Choice.parse('move 2')).toEqual(Choice.move(2));
  expect(Choice.parse('move 0')).toEqual(Choice.move(0));
  expect(() => Choice.parse('move 5')).toThrow('Invalid choice');
  expect(Choice.parse('switch 4')).toEqual(Choice.switch(4));
  expect(() => Choice.parse('switch 1')).toThrow('Invalid choice');
});

test('Choice.format', () => {
  expect(Choice.format(Choice.pass)).toBe('pass');
  expect(Choice.format(Choice.move(2))).toBe('move 2');
  expect(Choice.format(Choice.switch(4))).toBe('switch 4');
});

test('Result.decode', () => {
  expect(Result.decode(0b0101_0000)).toEqual({type: undefined, p1: 'move', p2: 'move'});
  expect(Result.decode(0b1000_0000)).toEqual({type: undefined, p1: 'pass', p2: 'switch'});
});

test('Result.encode', () => {
  expect(Result.encode({type: undefined, p1: 'move', p2: 'move'})).toBe(0b0101_0000);
  expect(Result.encode({type: undefined, p1: 'pass', p2: 'switch'})).toBe(0b1000_0000);
  expect(Result.encode({type: 'win', p1: 'pass', p2: 'pass'})).toBe(0b0000_0001);
});
