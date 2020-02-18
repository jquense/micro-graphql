import { parse } from '../src';
import fs from 'fs';

describe('parsing', () => {
  it('should parse', () => {
    const schema = fs.readFileSync(
      `${__dirname}/fixtures/kitchen-sink.graphql`,
      'utf8',
    );

    expect(() => parse(schema)).not.toThrow();
  });

  it('should parse github', () => {
    const schema = fs.readFileSync(
      `${__dirname}/fixtures/github-public.graphql`,
      'utf8',
    );

    expect(() => parse(schema)).not.toThrow();
  });

  // it.only('should parse interface with directive', () => {
  //   parse(`

  //     extend interface Bar @onInterface

  //   `);
  // });
});
